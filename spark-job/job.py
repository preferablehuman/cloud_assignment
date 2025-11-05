import argparse
from pyspark.sql import SparkSession, functions as F
from pyspark.sql.types import DoubleType


# helpers
AGG_FUNCS = {
    "mean": F.mean,
    "sum": F.sum,
    "count": F.count,
    "median": lambda col: F.expr(f"percentile_approx({col}, 0.5)"),
}


def build_spark(app_name="mr-job"):
    return (
        SparkSession.builder.appName(app_name).
        config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem").
        getOrCreate()
    )


def run_group_stat(df, group_col, value_col, stat):
    if stat not in AGG_FUNCS:
        raise ValueError(f"Unsupported stat '{stat}'. Choose from {list(AGG_FUNCS.keys())}")
    agg_func = AGG_FUNCS[stat]
    df_num = df.withColumn(value_col, F.col(value_col).cast(DoubleType()))
    out = df_num.groupBy(group_col).agg(agg_func(value_col).alias(f"{stat}_{value_col}"))
    return out.orderBy(F.col(f"{stat}_{value_col}").desc())


def run_corr(df, col1, col2):
    df2 = df.select(F.col(col1).cast(DoubleType()).alias(col1),
                    F.col(col2).cast(DoubleType()).alias(col2))
    corr = df2.corr(col1, col2)
    return corr


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True, help="s3a://bucket/path.csv or parquet dir")
    ap.add_argument("--output", required=True, help="s3a://bucket/output/prefix")
    ap.add_argument("--format", default="csv", choices=["csv", "parquet"], help="Input format")
    ap.add_argument("--header", action="store_true", help="CSV has header")
    ap.add_argument("--infer", action="store_true", help="Infer schema for CSV")
    ap.add_argument("--group_col", help="Grouping column for aggregation")
    ap.add_argument("--value_col", help="Numeric column for aggregation/correlation")
    ap.add_argument("--value_col2", help="Second numeric column for correlation")
    ap.add_argument("--stat", default="mean", help="Aggregation: mean/sum/count/median or 'corr'")
    args = ap.parse_args()


    spark = build_spark()


    if args.format == "csv":
        df = spark.read.csv(args.input, header=args.header, inferSchema=args.infer)
    else:
        df = spark.read.parquet(args.input)


    if args.stat == "corr":
        if not (args.value_col and args.value_col2):
            raise SystemExit("--stat corr requires --value_col and --value_col2")
        corr = run_corr(df, args.value_col, args.value_col2)
        spark.createDataFrame([(args.value_col, args.value_col2, corr)],
                              ["col1", "col2", "pearson_corr"]).write.mode("overwrite").csv(args.output, header=True)
    else:
        if not (args.group_col and args.value_col):
            raise SystemExit("Aggregation requires --group_col and --value_col")
        out = run_group_stat(df, args.group_col, args.value_col, args.stat)
        out.write.mode("overwrite").csv(args.output, header=True)


    spark.stop()


if __name__ == "__main__":
    main()