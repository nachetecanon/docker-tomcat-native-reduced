FROM nachetecanon/java8-alpine-maven3
MAINTAINER Nacho Cañón <nachete.canon@gmail.com>

##### ENV VARIABLES ######
# tomcat variables
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.0.11
ENV TOMCAT_HTTP_PORT 80
ENV TOMCAT_HTTPS_PORT 443
ENV TOMCAT_JPDA_PORT=5005
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

RUN apk --update add bash ca-certificates tar curl openssl unzip  alpine-sdk  openssl-dev;
# tomcat download and install
RUN curl --progress-bar -jkL https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz -o apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz  \
    && curl --progress-bar -jkL https://build.shibboleth.net/nexus/service/local/repositories/releases/content/net/shibboleth/utilities/trustany-ssl/1.0.0/trustany-ssl-1.0.0.jar -o trustany-ssl-1.0.0.jar \
    && curl --progress-bar -jkL https://build.shibboleth.net/nexus/service/local/repositories/thirdparty/content/javax/servlet/jstl/1.2/jstl-1.2.jar -o jstl-1.2.jar \
    && tar zxf apache-tomcat-*.tar.gz \
    && rm apache-tomcat-*.tar.gz \
    && mv apache-tomcat* $CATALINA_HOME \
    && mv trustany-ssl*jar $CATALINA_HOME/lib \
    && mv jstl-*jar $CATALINA_HOME/lib \
    && mkdir -p $CATALINA_HOME/certs

# adding The Apache Tomcat Native Library
RUN cd /tmp; \
   curl --progress-bar -jkL http://apache.rediris.es/tomcat/tomcat-connectors/native/1.2.5/source/tomcat-native-1.2.5-src.tar.gz -o tomcat-native-1.2.5-src.tar.gz \
    && curl --progress-bar -jkL http://apache.rediris.es/apr/apr-1.5.2.tar.gz -o apr-1.5.2.tar.gz \
    && tar zxvf apr-1.5.2.tar.gz \
    && cd apr-1.5.2 \
    && ./configure \
    && make && make install \
    && cd /tmp \
    && tar zxvf tomcat-native-1.2.5-src.tar.gz \
    && cd tomcat-native-1.2.5-src/native \
    && ./configure --with-apr=/usr/local/apr/bin \
                   --with-java-home=$JAVA_HOME \
                   --with-ssl=yes\
                   --prefix=$CATALINA_HOME ; \
     make && make install \
     && sudo ln -sv $CATALINA_HOME/lib/libtcnative-1.so /usr/lib/ \
     && sudo ln -sv /lib/libz.so.1 /usr/lib/libz.so.1 \
     && sudo rm -f /usr/lib/libc.musl-x86_64.so.1 \
     && sudo ln -s /lib/libc.musl-x86_64.so.1 /usr/lib/libc.musl-x86_64.so.1





# some cleanup
RUN apk del alpine-sdk  openssl-dev \
    && rm -fR /tmp/* 2> /dev/null
