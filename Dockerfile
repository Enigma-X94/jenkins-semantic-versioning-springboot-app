FROM openjdk:17-jdk-slim

WORKDIR /usr/app

COPY target/java-maven-app-1.0-SNAPSHOT.jar /usr/app/

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "java-maven-app-1.0-SNAPSHOT.jar"]
