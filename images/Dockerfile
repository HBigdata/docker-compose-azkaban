FROM registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/centos-jdk:7.7.1908

# 添加 azkaban 包
ENV AZKABAN_VERSION 3.91.0-313
RUN mkdir /opt/apache/azkaban-${AZKABAN_VERSION}
ADD ./azkaban-${AZKABAN_VERSION}/azkaban-db.tar.gz /opt/apache/azkaban-${AZKABAN_VERSION}/
ADD ./azkaban-${AZKABAN_VERSION}/azkaban-exec-server.tar.gz /opt/apache/azkaban-${AZKABAN_VERSION}/
ADD ./azkaban-${AZKABAN_VERSION}/azkaban-web-server.tar.gz /opt/apache/azkaban-${AZKABAN_VERSION}/
ENV AZKABAN_HOME /opt/apache/azkaban
RUN ln -s /opt/apache/azkaban-${AZKABAN_VERSION} $AZKABAN_HOME

# copy bootstrap.sh
COPY bootstrap.sh /opt/apache/
RUN chmod +x /opt/apache/bootstrap.sh

RUN chown -R hadoop:hadoop /opt/apache

WORKDIR $AZKABAN_HOME

