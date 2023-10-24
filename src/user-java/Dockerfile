# builder - first stage to build the application
FROM mcr.microsoft.com/openjdk/jdk:11-mariner AS build-env
RUN yum -y install maven
ADD ./pom.xml pom.xml
ADD ./src src/
RUN mvn clean package

# runtime - build final runtime image
FROM mcr.microsoft.com/openjdk/jdk:11-mariner

ARG IMAGE_CREATE_DATE
ARG IMAGE_VERSION
ARG IMAGE_SOURCE_REVISION

ENV PORT=80

# Metadata as defined in OCI image spec annotations - https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="Trip Insights - User (Java) API" \
    org.opencontainers.image.description="The User (Java) API component forms part of the Trip Insights application." \
    org.opencontainers.image.created=$IMAGE_CREATE_DATE \
    org.opencontainers.image.version=$IMAGE_VERSION \
    org.opencontainers.image.authors="Microsoft" \
    org.opencontainers.image.url="https://github.com/microsoft/secure-software-supply-chain-on-aks/blob/main/src/user-java/Dockerfile" \
    org.opencontainers.image.documentation="https://github.com/microsoft/secure-software-supply-chain-on-aks/blob/main/src/user-java/README.md" \
    org.opencontainers.image.vendor="Microsoft" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/microsoft/secure-software-supply-chain-on-aks.git" \
    org.opencontainers.image.revision=$IMAGE_SOURCE_REVISION 

# add the application's jar to the container
COPY --from=build-env target/swagger-spring-1.0.0.jar app.jar

# run application
EXPOSE $PORT
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom", "-Dspring.cloud.kubernetes.secrets.enabled=true", "-Dspring.cloud.kubernetes.secrets.paths=/secrets", "-jar","/app.jar"]
