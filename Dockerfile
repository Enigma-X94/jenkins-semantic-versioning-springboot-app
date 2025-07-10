FROM openjdk:17-jdk-slim

WORKDIR /usr/app

COPY target/*.jar /usr/app/

EXPOSE 8080

CMD java -jar java-maven-app-*.jar
