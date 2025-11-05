#!/usr/bin/env bash
set -euxo pipefail
REGION="${region}"
S3_BUCKET="${s3_bucket}"


# Base deps
sudo apt-get update -y
sudo apt-get install -y openjdk-11-jdk curl unzip python3-pip awscli


# Spark
SPARK_VERSION=3.5.1
HADOOP_TAG=hadoop3
cd /opt
sudo curl -L -o spark.tgz https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-${HADOOP_TAG}.tgz
sudo tar -xzf spark.tgz && sudo rm spark.tgz
sudo ln -s spark-${SPARK_VERSION}-bin-${HADOOP_TAG} spark
sudo chown -R ubuntu:ubuntu /opt/spark*


# Env
cat <<'EOF' | sudo tee /etc/profile.d/spark.sh
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
EOF
source /etc/profile.d/spark.sh


# Configure Spark to use S3A
sudo -u ubuntu mkdir -p /opt/spark/conf
cat <<'EOF' | sudo tee /opt/spark/conf/spark-defaults.conf
spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.InstanceProfileCredentialsProvider
spark.hadoop.fs.s3a.multipart.size=104857600
spark.hadoop.fs.s3a.fast.upload=true
spark.hadoop.fs.s3a.path.style.access=true
spark.hadoop.fs.s3a.bucket.all.committer.magic.enabled=true
spark.serializer=org.apache.spark.serializer.KryoSerializer
EOF


# Start master
PRIVATE_IP=$(hostname -I | awk '{print $1}')
/opt/spark/sbin/start-master.sh --host $PRIVATE_IP --port 7077 --webui-port 8080 || true


# Copy job scaffold for convenience
sudo -u ubuntu mkdir -p /home/ubuntu/job
cat <<'PY' | sudo -u ubuntu tee /home/ubuntu/job/README.txt
Place your PySpark job(s) here and submit with spark-submit.
PY


# Convenience: print info on login
cat <<EOF | sudo tee /etc/motd
Spark Master running at spark://$PRIVATE_IP:7077
S3 bucket: s3://$S3_BUCKET
EOF