#!/bin/bash

set -e  # Exit on any error

echo "🧹 Stopping and removing Axelor containers..."

# Stop and remove containers with volumes
if docker-compose down -v; then
    echo "✅ Containers and volumes removed via docker-compose"
else
    echo "⚠️  docker-compose down failed, trying manual cleanup..."
fi

# Remove the Axelor-specific containers if they still exist
echo "🗑️  Removing Axelor containers..."
docker rm -f axelor-app axelor-postgres axelor-pgadmin 2>/dev/null || echo "ℹ️  Containers already removed."

# Remove the Axelor-specific images
echo "🗑️  Removing Axelor-specific images..."
POSTGRES_IMAGE=$(grep POSTGRES_IMAGE .env 2>/dev/null | cut -d'=' -f2 || echo "postgres:15")
docker rmi -f $(docker images -q axelor-open-suite_axelor) $POSTGRES_IMAGE dpage/pgadmin4 2>/dev/null || echo "ℹ️  Images already removed."

# Remove dangling volumes
echo "🗑️  Removing unused volumes..."
docker volume prune -f

# Remove dangling images
echo "🗑️  Removing dangling images..."
docker image prune -f

echo "✅ Axelor application and related containers/images removed successfully."
