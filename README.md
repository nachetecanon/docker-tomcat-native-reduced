# docker-java-reduced
Docker image based in Alpine and with java 8.45.14 jdk from Oracle installed along with maven 3.3.9

# Overview
This image is intended to provide a small docker base image fully functional in terms of Java development and Maven.

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
MAVEN_OPTS=-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true
JAVA_HOME=/opt/jdk
M2_HOME=/opt/apache-maven-3.3.9
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jdk/bin:/opt/apache-maven-3.3.9/bin
```
# Use

For specific maven configuration, it's recommended to add a COPY instruction for substituting the settins.xml file.

It's also recommended if this image is to be used as a base image for other docker projects, to make some cleanup after
 
 building, removing dependencies loaded from ${HOME}/.m2/repository along with the maven installation ${M2_HOME}.
 
# Size

The size of the built image is about 379M.