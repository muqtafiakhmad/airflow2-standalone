FROM apache/airflow:2.2.4

EXPOSE 24

USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         gcc g++ libnfs-dev libsasl2-dev libsasl2-modules-gssapi-mit libkrb5-dev musl-dev openjdk-11-jdk \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# INSTALL DEPENDENCIES
RUN pip install --no-cache-dir pandas boto3 xlrd==1.2.0 && pip install --upgrade pip

ARG ARCHIVE_URL=http://archive.apache.org/dist
ARG SPARK_VERSION=3.2.1
ARG SPARK_HADOOP_VERSION=3.2
RUN curl -sL --retry 3 "${ARCHIVE_URL}/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz" | tar xz  \
    && mv spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION} /usr/local/spark-${SPARK_VERSION}

RUN mkdir extra

RUN groupadd --gid 999 docker \
    && usermod -aG docker airflow

USER airflow

ARG AIRFLOW_VERSION=2.2.4
ARG PYTHON_VERSION=3.7

# COPY SQL SCRIPT
COPY scripts/airflow/check_init.sql ./extra/check_init.sql
COPY scripts/airflow/set_init.sql ./extra/set_init.sql
COPY ./requirements.txt /requirements.txt

RUN pip install --no-cache-dir --user -r /requirements.txt --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-$AIRFLOW_VERSION/constraints-$PYTHON_VERSION.txt"

# ENTRYPOINT SCRIPT
COPY scripts/airflow/init.sh ./init.sh

ENTRYPOINT ["./init.sh"]