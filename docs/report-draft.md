# Local Production-Like Web Deployment with Ubuntu, Docker and Nginx

**Module:** DCOM304 Web Hosting & Design  
**Student:** [Insert name]  
**Date:** [Insert submission date]

## Introduction

This report describes the design and local deployment of a small static website for Salone Digital Solutions, a fictional software company based in Freetown, Sierra Leone. The project demonstrates a production-like hosting pattern on a personal development computer: a web server running inside a Docker container is reached through a host-level Nginx reverse proxy. Ubuntu running in Windows Subsystem for Linux 2 (WSL2) provides the Linux environment, while Git supports source-code tracking and GitHub can be used as a remote repository.

The website is intentionally straightforward. It is built with plain HTML and CSS and includes a navigation header, hero section, service descriptions, company information, contact details and footer. The design uses a green-and-white palette, a responsive layout and a system font stack beginning with Tahoma. This keeps the deployment focused on hosting rather than on frameworks or a compilation process.

The main objective was to understand how a request travels through the hosting stack. A browser request to `http://localhost` reaches Nginx on port 80. Nginx forwards it to port 8080 on the Ubuntu host, where Docker has published the website container's port 80. A second URL, `http://localhost:8080`, allows a direct check of the container-published service. [INSERT SCREENSHOT: website home page in browser]

## Tools Used

**Ubuntu on WSL2.** WSL2 provides a Linux environment on a Windows computer. Running Linux command-line tools in Ubuntu makes it possible to practise common server administration tasks locally. It is useful for learning, although a local WSL installation is not itself a public internet server.

**Git and GitHub.** Git records project changes in local commits. GitHub can host a remote copy of the repository, making it easier to back up and share the source. The local project can be committed and connected to a GitHub repository after one is created. A GitHub password is generally not used for HTTPS Git operations; authentication should follow GitHub's current instructions for personal access tokens or SSH keys. Credentials must remain private.

**Docker.** Docker packages the web server and static files into an image and runs that image as a container. The Dockerfile starts from the small `nginx:alpine` image, copies `index.html` and `style.css` into Nginx's document directory, and declares the container's listening port. Publishing `8080:80` maps host port 8080 to the Nginx port 80 inside the container. This makes the app available to the host without exposing the container directly to the network.

**Nginx.** Nginx is used twice in this arrangement: the Nginx process in the container serves the static files, and a host Nginx server block acts as a reverse proxy. The host proxy forwards requests for `localhost` to `http://127.0.0.1:8080` and includes the original host and client IP forwarding headers. Keeping the app behind a proxy is a common web-hosting pattern and provides one place to manage routing or later add TLS.

**Shell scripts and curl.** `deploy.sh` automates repeatable build and configuration steps. `verify.sh` checks the running container, the Nginx service and HTTP response headers. Shell scripts reduce repeated typing but must be read before running because they can change system configuration. `curl -I` is a quick way to confirm that an HTTP endpoint responds without downloading the complete page.

## Deployment Steps

### Ubuntu and WSL2

The first step is to open the Ubuntu terminal in WSL2 and work from the project directory. Required components include Docker Engine, Nginx, Git and curl. They must be installed and configured before deployment; this project does not install packages automatically. Docker must be running, and the user needs permission to use Docker. Administrator privileges are needed to copy the Nginx site configuration into `/etc/nginx` and control the Nginx service.

WSL2 service management can depend on the Ubuntu and WSL configuration. If `systemctl` is unavailable or reports that the system was not booted with systemd, systemd needs to be enabled for that WSL distribution or Nginx must be managed using the supported service mechanism on that setup. This should be confirmed before running the deployment script.

### Git and GitHub

The project files can be tracked in a local Git repository and committed as the work progresses. If using GitHub, the student first creates an empty repository and then follows GitHub's instructions to connect and push the local project. No remote is created by the deployment files. Before pushing, `git status` helps check which files are included, and credentials should never be placed in HTML, shell scripts or documentation. [INSERT SCREENSHOT: Git status and project files]

### Docker

The Docker build reads the Dockerfile and website files from the repository root. It creates an image tagged `salone-app:v1`. The deployment script checks for and removes an old container called `salone-container`, then starts a new container with that name. Docker publishes host port 8080 to container port 80; accordingly, a browser or command-line check can access the app directly at `http://localhost:8080`.

The Compose file offers an alternative way to build and start the same image with a single command. It should not be used at the same time as the standalone deployment script because both specify the same container name and port. The container is not a permanent replacement for the source files: the Docker image is built from the project and can be rebuilt after edits.

### Nginx

The host reverse-proxy configuration is stored in `nginx/salone-app.conf`. The deployment script copies it to `/etc/nginx/sites-available/` and creates a symbolic link in `/etc/nginx/sites-enabled/`. It removes the enabled default-site link to avoid that site taking precedence for local HTTP requests. This is a system-level change, so anyone using the default site for another purpose should review the script before proceeding.

Before reloading, the script runs `nginx -t`. This validates the Nginx configuration and reports syntax or file access problems. Only after a successful test does it reload the Nginx service. The expected user-facing endpoint is `http://localhost` on port 80; the direct Docker endpoint on port 8080 remains useful for isolating issues. [INSERT SCREENSHOT: successful Nginx configuration test and deployment output]

The final verification runs `docker ps`, checks Nginx service status and sends header-only requests to both URLs with curl. A successful response from port 8080 but not from port 80 points toward the host proxy or Nginx service. If neither endpoint works, Docker startup, port availability and the container logs should be checked.

## Problems Encountered and Solutions

The following table summarises common problems that can arise during a local deployment and a practical response to each. The actual incident column should be updated to match what happened during the student's own deployment.

| Problem | Possible cause | Solution |
|---|---|---|
| Docker permission denied | The current user does not have permission to access the Docker socket. | Check the Docker service, use `sudo` for Docker commands if appropriate, or follow Docker's documented post-installation steps for group access. Sign out and back in after a group change. |
| Docker daemon not running | The Docker service is stopped or unavailable in the WSL setup. | Check its status and start it with the appropriate service command. Confirm Docker integration and systemd configuration for the specific WSL installation. |
| Port 80 in use | Another server or process is already listening on port 80. | Identify the existing listener and decide whether it can be stopped or reconfigured. Do not terminate an unknown service without checking its purpose. |
| GitHub token authentication | HTTPS authentication was attempted with an account password or an invalid/expired token. | Follow GitHub's current instructions for a personal access token or set up SSH authentication. Keep the token secret and out of the repository. |
| Nginx syntax errors | A directive, semicolon, brace or path in the configuration is incorrect. | Run `sudo nginx -t`, use the reported file and line to correct the error, and reload only after the test passes. |

During the practical work, record any problem that actually occurs, the diagnostic output and the successful solution here. [INSERT SCREENSHOT: relevant troubleshooting output]

## Local vs VPS Deployment

A local WSL2 deployment is low-cost and convenient for coursework. It can be started and tested without renting a server, and the developer has direct access to source files and logs. However, `localhost` refers to the local computer. The website is not automatically public or continuously available to other users. A laptop may be offline, asleep or disconnected, and local firewall and WSL networking rules can affect access.

A Virtual Private Server (VPS) is a remotely hosted virtual machine with a public IP address. To make the site available on the internet, the administrator configures the server, installs or enables Docker and Nginx, and deploys the application there. A domain can be registered and DNS records (commonly an A or AAAA record) pointed to the server's public IP. DNS changes may take time to propagate.

Public hosting also requires security measures. The server firewall should permit only the necessary traffic, typically SSH for administration and HTTP/HTTPS for the website. Nginx can be configured for HTTPS with a trusted TLS certificate, for example through a certificate authority and an automated renewal process. Administrative access should use strong authentication and updates should be applied regularly. The reverse proxy and application should be monitored and logs reviewed.

VPS hosting has a recurring cost, which depends on the provider, region, compute resources, storage, bandwidth and backups. It can offer much better public reachability and uptime than a personal laptop, but uptime is not guaranteed and may depend on the provider's service level, maintenance and the deployment design. Backups and recovery plans are still needed. Local development is suitable for learning and demonstration; public production hosting requires additional planning for security, DNS, TLS, firewall policy, monitoring, updates and cost.

## References

1. Ubuntu Documentation, “Windows Subsystem for Linux”: https://documentation.ubuntu.com/wsl/
2. Git Documentation, “Getting Started”: https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control
3. GitHub Docs, “About authentication to GitHub”: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-authentication-to-github
4. Docker Docs, “Dockerfile reference”: https://docs.docker.com/reference/dockerfile/
5. Docker Docs, “Port publishing and mapping”: https://docs.docker.com/get-started/docker-concepts/running-containers/publishing-ports/
6. Nginx Documentation, “Beginner's Guide”: https://nginx.org/en/docs/beginners_guide.html
7. Nginx Documentation, “ngx_http_proxy_module”: https://nginx.org/en/docs/http/ngx_http_proxy_module.html

Accessed: [Insert date accessed].
