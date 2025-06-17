#!/bin/bash

set -e  # Exit on any error

echo "Stopping Axelor application containers..."

if docker-compose down; then
    echo "✅ Axelor application containers stopped successfully."
else
    echo "❌ Error stopping containers"
    exit 1
fi
