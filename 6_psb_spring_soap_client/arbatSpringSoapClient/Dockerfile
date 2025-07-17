# Use Amazon Corretto 8 as base image
FROM amazoncorretto:8

# Set working directory
WORKDIR /app

# Copy Maven files
COPY pom.xml .
COPY src ./src

# Install Maven
RUN yum install -y maven

# Build the application
RUN mvn clean package -DskipTests

# Create a script to run the application with parameters
RUN echo '#!/bin/bash\n\
java -cp target/arbatSpringSoapClient-1.0-SNAPSHOT.jar SoapContainerRunner' > /app/run.sh && \
chmod +x /app/run.sh

# Set the entrypoint
ENTRYPOINT ["/app/run.sh"] 