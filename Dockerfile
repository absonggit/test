FROM centos:7 

ENV JAVA_HOME=/usr/local/java
ENV PATH=$JAVA_HOME/bin:$PATH
ENV CLASSPATH=$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV CATALINA_BASE=/usr/local/tomcat
ENV CATALINA_HOME=/usr/local/tomcat
ENV CATALINA_TMPDIR=/usr/local/tomcat/temp

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum install -y apr-devel openssl-devel tomcat-native wget make gcc tar expat-devel 

COPY jdk-8u144-linux-x64.tar.gz /root/jdk-8u144-linux-x64.tar.gz
RUN cd /root && tar -zxvf jdk-8u144-linux-x64.tar.gz -C /usr/local \
 && mv /usr/local/jdk1.8.0_144 /usr/local/java

COPY apache-tomcat-8.5.38.tar.gz /root/apache-tomcat-8.5.38.tar.gz
RUN cd /root && tar -zxvf apache-tomcat-8.5.38.tar.gz -C /usr/local \
 && mv /usr/local/apache-tomcat-8.5.38 /usr/local/tomcat

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
