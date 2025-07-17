# Use Amazon Corretto 8 as base image
FROM amazoncorretto:8

# Set working directory
WORKDIR /app

# Install Maven 3.8.6 (newer version)
RUN yum update -y && \
    yum install -y wget && \
    wget https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz && \
    tar -xzf apache-maven-3.8.6-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.8.6 /opt/maven && \
    echo 'export PATH=$PATH:/opt/maven/bin' >> /etc/profile && \
    echo 'export PATH=$PATH:/opt/maven/bin' >> ~/.bashrc && \
    rm apache-maven-3.8.6-bin.tar.gz && \
    yum clean all

# Set Maven environment
ENV PATH=$PATH:/opt/maven/bin

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