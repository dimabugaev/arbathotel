# Use Amazon Corretto 8 as base image
FROM amazoncorretto:8

# Set working directory
WORKDIR /app

# Install Maven 3.8.6 (newer version)
RUN yum update -y && \
    yum install -y wget && \
    wget -O /tmp/maven.tar.gz https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz && \
    tar -xzf /tmp/maven.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.8.6 /opt/maven && \
    rm /tmp/maven.tar.gz && \
    yum clean all

# Set Maven environment
ENV PATH=/opt/maven/bin:$PATH

# Copy Maven files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Create a script to run the application with parameters
RUN echo '#!/bin/bash\n\
java -cp target/arbatSpringSoapClient-1.0-SNAPSHOT.jar SoapContainerRunner' > /app/run.sh && \
chmod +x /app/run.sh

# Set the entrypoint
ENTRYPOINT ["/app/run.sh"] 