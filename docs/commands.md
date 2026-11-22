# Command Reference

This guide explains the commands used by the setup and deployment. Commands that change host Nginx configuration or control system services require administrator privileges, usually by running the script with `sudo`.

## Git and GitHub

- `git clone <repository-url>` downloads a remote repository and its files into a new local directory. Replace the placeholder with your own GitHub repository URL.
- `git status` reports which files are new, modified, or staged in the local repository.
- `git add <file>` stages a file so it can be included in the next commit.
- `git commit -m "message"` saves staged changes in the local Git history with a short description.
- `git push` sends local commits to a configured remote repository. This project setup does not run this command or create a remote.

GitHub HTTPS authentication may ask for a personal access token instead of an account password. Do not store a token in the repository.

## Docker

- `docker build -t salone-app:v1 .` builds an image from the `Dockerfile` in the current directory and tags it `salone-app:v1`.
- `docker run -d --name salone-container -p 8080:80 salone-app:v1` starts a container in the background. `--name` gives it a convenient name; `-p 8080:80` maps host port 8080 to container port 80.
- `docker ps` lists containers that are currently running. Add `-a` to include stopped containers.
- `docker rm -f salone-container` force-removes a container with that name, including stopping it if necessary. The deployment script first checks whether the container exists.
- `docker compose up -d --build` builds and starts the services described in `docker-compose.yml` in the background.
- `docker compose down` stops and removes the containers created by that Compose project.

The port mapping `8080:80` is written as `host-port:container-port`. Visitors connecting to `localhost:8080` reach port 80 inside the container.

## Nginx and system services

- `proxy_pass http://127.0.0.1:8080;` is an Nginx directive that forwards a matching request to the app listening on host loopback port 8080.
- `proxy_set_header` adds request headers. The configuration preserves the requested host and sends client IP information to the upstream service.
- `sudo nginx -t` checks the Nginx configuration for syntax errors and whether referenced files can be read. It does not reload Nginx.
- `sudo systemctl status nginx` reports whether the Nginx system service is running and displays recent status information.
- `sudo systemctl reload nginx` asks a running Nginx service to load its configuration again without a full stop/start.
- `sudo systemctl status docker` checks the Docker service; `sudo systemctl start docker` starts it.
- `sudo cp source destination` copies the site configuration into the system-managed `sites-available` directory.
- `sudo ln -sf target link` creates or replaces a symbolic link. Nginx uses the link in `sites-enabled` to decide which available site configuration is active.
- `sudo rm -f /etc/nginx/sites-enabled/default` removes the enabled default-site link if present. Review this before deploying if the default site is needed.

## Shell, permissions, and HTTP checks

- `chmod +x deploy.sh verify.sh` marks each script as executable so it can be started as `./deploy.sh` or `./verify.sh`.
- `sudo ./deploy.sh` runs the deployment script with administrator privileges. The script builds the image, replaces the named container, configures Nginx, tests its configuration, and reloads the service.
- `sudo ./verify.sh` runs the verification script with permissions to inspect Nginx service status.
- `curl -I http://localhost:8080` sends an HTTP request and displays response headers from the container-published port. `-I` requests headers only.
- `curl -I http://localhost` checks the same site through Nginx on port 80.
- `set -e` in the scripts makes the shell exit when a command fails, preventing later deployment steps from being treated as successful.
