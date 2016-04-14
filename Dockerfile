FROM alpine
MAINTAINER Nacho Cañón <nachete.canon@gmail.com>


# Install cURL, tar, etc
RUN apk --update add bash  tar wget alpine-sdk  openssl-dev \
    && cd /tmp \
    && wget -q --no-check-certificate "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk"  \
    && wget -q --no-check-certificate "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk"  \
    && apk add --allow-untrusted glibc-bin-2.21-r2.apk \
    && ldconfig /lib /usr/glibc/usr/lib \
    && apk add --allow-untrusted /tmp/glibc-2.21-r2.apk

# fix known bug about jndi lookup and alpine image.
RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

# Java Version
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 45
ENV JAVA_VERSION_BUILD 14
ENV JAVA_PACKAGE       jdk

# Download and unarchive Java
RUN mkdir /opt && curl --progress-bar -jkLH "Cookie: oraclelicense=accept-securebackup-cookie"\
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
    | tar -xzf - -C /opt &&\
    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk &&\
    rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so


# Set JAVA and maven environment
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin


##### ENV VARIABLES ######
# tomcat variables
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.0.11
ENV TOMCAT_HTTP_PORT 80
ENV TOMCAT_HTTPS_PORT 443
ENV TOMCAT_JPDA_PORT=5005
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

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
