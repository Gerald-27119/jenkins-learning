FROM maven:3.9.9-eclipse-temurin-21-alpine AS builder
WORKDIR /app

COPY ./pom.xml .
RUN mvn dependency:go-offline -B

COPY ./src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/app.jar"]
