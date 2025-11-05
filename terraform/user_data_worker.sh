#!/usr/bin/env bash
set -euxo pipefail
MASTER_IP="${master_private_ip}"
REGION="${region}"


sudo apt-get update -y
sudo apt-get install -y openjdk-11-jdk curl unzip python3-pip awscli


SPARK_VERSION=3.5.1
HADOOP_TAG=hadoop3
cd /opt
sudo curl -L -o spark.tgz https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-${HADOOP_TAG}.tgz
sudo tar -xzf spark.tgz && sudo rm spark.tgz
sudo ln -s spark-${SPARK_VERSION}-bin-${HADOOP_TAG} spark
sudo chown -R ubuntu:ubuntu /opt/spark*


cat <<'EOF' | sudo tee /etc/profile.d/spark.sh
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
EOF
source /etc/profile.d/spark.sh


# Workers also need s3a defaults for any local file ops
sudo -u ubuntu mkdir -p /opt/spark/conf
cat <<'EOF' | sudo tee /opt/spark/conf/spark-defaults.conf
spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.InstanceProfileCredentialsProvider
spark.serializer=org.apache.spark.serializer.KryoSerializer
EOF


/opt/spark/sbin/start-worker.sh spark://$MASTER_IP:7077 --webui-port 8081 || true