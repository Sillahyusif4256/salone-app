# Salone Digital Solutions

A simple, responsive static website for a fictional software company in Freetown, Sierra Leone. This assignment demonstrates serving static files with Docker and routing local browser traffic through an Nginx reverse proxy on Ubuntu under WSL2.

## Prerequisites

- Ubuntu running in WSL2.
- Git, Docker Engine (with the Docker service running), Nginx, and `curl`.
- A user with permission to run Docker and `sudo` access for host Nginx configuration.
- Ports 80 and 8080 available.

No application build step or external runtime dependency is used. This project does not install software or configure GitHub for you.

## Setup

1. Open an Ubuntu/WSL terminal and change to this project directory.
2. If you have created a GitHub repository, clone it into your chosen workspace. Otherwise, copy the project files into the repository directory you plan to push later.
3. Confirm Docker is running with `sudo systemctl status docker` and that Nginx is installed and running with `sudo systemctl status nginx`.
4. Make the scripts executable if needed: `chmod +x deploy.sh verify.sh`.
5. Deploy the site with `sudo ./deploy.sh`.
6. Open [http://localhost](http://localhost) in a browser. The direct container URL is [http://localhost:8080](http://localhost:8080).
7. Check the deployment with `sudo ./verify.sh`.

The deployment script builds `salone-app:v1`, replaces a previous `salone-container`, publishes the container on port 8080, installs the host Nginx site configuration and reloads Nginx. It removes the enabled default Nginx site so the `localhost` request reaches this app. If you rely on the default site for other work, review the script before running it.

## Using Docker Compose

Alternatively, start the app container with `docker compose up -d --build` and stop it with `docker compose down`. Compose uses the same image tag and container name as the deployment script; do not run both methods simultaneously.

## Troubleshooting

- **Docker permission denied:** Check `sudo systemctl status docker`. Try the Docker commands with `sudo`, or configure Docker group access according to Docker's official Linux post-installation instructions. Group changes may require signing out and back in.
- **Docker daemon not running:** Start it with `sudo systemctl start docker`, then check its status again.
- **Port 8080 already in use:** Stop the other service/container using that port, or deliberately change the published host port and update Nginx's `proxy_pass` to match.
- **Port 80 already in use:** Identify the service using it before proceeding. The host Nginx proxy needs port 80.
- **Nginx syntax error:** Run `sudo nginx -t` and correct the reported file/line before reloading. The deployment script tests the configuration before reload.
- **GitHub authentication failure:** Use GitHub's documented HTTPS authentication method, such as a personal access token in place of a password, or configure SSH authentication. Never put a token in project files or share it.
- **The site does not load:** Run `sudo ./verify.sh`, confirm the container is running and both ports are reachable, and inspect Nginx's error log if needed.
