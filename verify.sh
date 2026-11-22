#!/usr/bin/env bash
set -e

echo "Running containers:"
docker ps

echo
echo "Nginx service status:"
systemctl status nginx --no-pager

echo
echo "Checking the Docker-published website:"
curl -I http://localhost:8080

echo
echo "Checking the Nginx reverse proxy:"
curl -I http://localhost
