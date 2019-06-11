FROM centos:7 

ENV JAVA_HOME=/usr/local/java
ENV PATH=$JAVA_HOME/bin:$PATH
ENV CATALINA_BASE=/usr/local/tomcat
ENV CATALINA_HOME=/usr/local/tomcat
ENV CATALINA_TMPDIR=/usr/local/tomcat/temp

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum install -y apr-devel openssl-devel wget make gcc tar expat-devel 

RUN wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
RUN tar -zxvf openjdk-11.0.2_linux-x64_bin.tar.gz -C /usr/local \
 && mv /usr/local/jdk-11.0.2 /usr/local/java

RUN wget http://mirror.rise.ph/apache/tomcat/tomcat-8/v8.5.42/bin/apache-tomcat-8.5.42.tar.gz
RUN tar -zxvf apache-tomcat-8.5.42.tar.gz -C /usr/local \
 && mv /usr/local/apache-tomcat-8.5.42 /usr/local/tomcat

RUN tar -zxvf /usr/local/tomcat/bin/tomcat-native.tar.gz -C /usr/local/tomcat/bin/ \
 && cd /usr/local/tomcat/bin/tomcat-native-1.2.21-src/native \
 && ./configure --with-apr=/usr/bin/apr-1-config --with-java-home="/usr/local/java" --with-ssl=yes \
 && make && make install

RUN mkdir -p /usr/java/packages/lib/amd64
RUN ln -s /usr/local/apr/lib/libtcnative-1.so.0 /usr/java/packages/lib/amd64/libtcnative-1.so.0
RUN ln -s /usr/local/apr/lib/libtcnative-1.so /usr/java/packages/lib/amd64/libtcnative-1.so

WORKDIR /usr/local/tomcat
EXPOSE 8080
ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run" ]
