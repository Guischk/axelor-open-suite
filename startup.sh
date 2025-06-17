#!/bin/bash

set -e  # Exit on any error

# Build and start the containers
echo "Building and starting the containers..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please create it with the required environment variables."
    exit 1
fi

# Build the app
if docker-compose up --build -d; then
    echo "✅ Containers started successfully"
    
    # Wait a moment for containers to initialize
    sleep 5
    
    # Check if the containers are running
    echo "📋 Container status:"
    docker ps --filter "name=axelor"
    
    # Show application URLs
    echo ""
    echo "🌐 Application URLs:"
    echo "   Axelor App: http://localhost:$(grep AXELOR_PORT .env | cut -d'=' -f2)"
    echo "   PgAdmin:    http://localhost:$(grep PGADMIN_PORT .env | cut -d'=' -f2)"
else
    echo "❌ Failed to start containers"
    exit 1
fi
