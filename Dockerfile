FROM ubuntu:14.04
MAINTAINER Steven Wang <steven@urad.com.tw>

WORKDIR /root

# Install openssh-server and wget
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends software-properties-common && \
  apt-get install -y openssh-server wget

# Install java 8
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Install hadoop 2.7.3
RUN \
  wget http://ftp.twaren.net/Unix/Web/apache/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz && \
  tar -xzvf hadoop-2.7.3.tar.gz && \
  mv hadoop-2.7.3 /usr/local/hadoop && \
  rm hadoop-2.7.3.tar.gz

# Set environment variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin

# ssh without key
RUN \
  ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN \
  mkdir -p ~/hdfs/namenode && \
  mkdir -p ~/hdfs/datanode && \
  mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

RUN \
  mv /tmp/ssh_config ~/.ssh/config && \
  mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
  mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
  mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
  mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
  mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
  mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
  mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
  mv /tmp/run-wordcount.sh ~/run-wordcount.sh

RUN \
  chmod +x ~/start-hadoop.sh && \
  chmod +x ~/run-wordcount.sh && \
  chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
  chmod +x $HADOOP_HOME/sbin/start-yarn.sh

# Format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD ["sh", "-c", "service ssh start; bash"]
