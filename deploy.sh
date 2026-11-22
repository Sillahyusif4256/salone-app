#!/usr/bin/env bash
set -e

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="salone-app:v1"
CONTAINER_NAME="salone-container"
CONFIG_NAME="salone-app.conf"

echo "Building Docker image ${IMAGE_NAME}..."
docker build -t "$IMAGE_NAME" "$APP_DIR"

echo "Removing any old ${CONTAINER_NAME} container..."
if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  docker rm -f "$CONTAINER_NAME"
fi

echo "Starting the website container on port 8080..."
docker run -d --name "$CONTAINER_NAME" -p 8080:80 "$IMAGE_NAME"

echo "Installing the Nginx reverse-proxy configuration..."
cp "$APP_DIR/nginx/$CONFIG_NAME" "/etc/nginx/sites-available/$CONFIG_NAME"
ln -sf "/etc/nginx/sites-available/$CONFIG_NAME" "/etc/nginx/sites-enabled/$CONFIG_NAME"
rm -f /etc/nginx/sites-enabled/default

echo "Checking Nginx configuration..."
nginx -t

echo "Reloading Nginx..."
systemctl reload nginx

echo "Deployment complete. Test the website at:"
echo "  Through the Nginx reverse proxy: http://localhost"
echo "  Directly from the Docker container: http://localhost:8080"
