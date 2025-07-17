#!/bin/bash

echo "=== Quick Build Test ==="

cd arbatSpringSoapClient

echo "Building JAR..."
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo "✅ JAR build successful!"
    echo "Testing Docker build..."
    docker build -t java-soap-client-test .
    
    if [ $? -eq 0 ]; then
        echo "✅ Docker build successful!"
    else
        echo "❌ Docker build failed!"
    fi
else
    echo "❌ JAR build failed!"
fi 