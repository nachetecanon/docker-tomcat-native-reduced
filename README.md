# docker-tomcat-native-reduced
Docker image based in Alpine and with java 8.45.14 jdk from Oracle installed along with tomcat 8 and native library loaded

# Overview
This image is intended to provide a small docker base image for using tomcat 8 with APR native library, useful for production environment

The idea behind installing maven is to provide to the developer the facility of pulling her artifacts from a nexus repository specifying the version.

i.e:
```
mvn org.apache.maven.plugins:maven-dependency-plugin:2.4:get \
        -Dartifact=mygroupid:myartifactId:1.0-SNAPSHOT:jar -Dtransitive=false -Ddest=myartifact-1.0-SNAPSHOT.jar
```

# Build instructions

The original image can be built this way

```
docker build -t <org_id>/<image_name>
```

# Environment variables

The image create the next environment variables
```
JAVA_VERSION_BUILD=14
HOSTNAME=3c49fa1415a1
CATALINA_HOME=/opt/tomcat
JAVA_VERSION_MAJOR=8
TOMCAT_HTTPS_PORT=443
TOMCAT_MAJOR_VERSION=8
MAVEN_OPTS=-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jdk/bin:/opt/apache-maven-3.3.9/bin:/opt/tomcat/bin
JAVA_HOME=/opt/jdk
TOMCAT_HTTP_PORT=8080
HOME=/root
M2_HOME=/opt/apache-maven-3.3.9
JAVA_PACKAGE=jdk
TOMCAT_MINOR_VERSION=8.0.11
TOMCAT_JPDA_PORT=5005
JAVA_VERSION_MINOR=45
```
# Use

For specific maven configuration, it's recommended to add a COPY instruction for substituting the settins.xml file.

It's also recommended if this image is to be used as a base image for other docker projects, to make some cleanup after
 
 building, removing dependencies loaded from ${HOME}/.m2/repository along with the maven installation ${M2_HOME}.
 
 For customizing Tomcat installation, its recommended to use this image as a base and ADD or COPY the customized configuration files.
 
```
FROM nachetecanon/tomcat-native-alpine


##### ENV VARIABLES ######
ENV TOMCAT_HTTP_PORT 8080

ADD tomcatconf/server.xml $CATALINA_HOME/conf/

EXPOSE $TOMCAT_HTTP_PORT


# run
CMD ["/opt/tomcat/bin/catalina.sh","run" ]
```
# Size

The size of the built image is about 402M.