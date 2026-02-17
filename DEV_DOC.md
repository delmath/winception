This project has been created as part of the 42 curriculum by madelvin
# Developer Guide

This guide explains how a developer can set up, run, and manage the project.

## Project Overview

This project uses Docker to run a set of web services, including:
- **NGINX**: Web server.
- **WordPress**: Content Management System (CMS).
- **MariaDB**: Database.
- **Redis**: Cache for performance.
- **FTP**: Server for file transfers.
- **Adminer**: Web-based database management tool.
- **Static Site**: A simple static website.
- **Portainer**: An interface to manage Docker.

## Prerequisites

Before you start, install:
- **Docker**
- **Docker Compose**
- **make**

## Environment Setup

### 1. Clone the Repository

```sh
git clone <repository-url>
cd winception
```

### 2. Configure Environment Variables

The project uses a `.env` file for passwords and configurations. This file is ignored by Git, so you must create it yourself.

1.  Go to the `srcs` directory:
    ```sh
    cd srcs
    ```
2.  Copy the example configuration file to a new `.env` file:
    ```sh
    cp .env.example .env
    ```
3.  Open the new `.env` file and customize the variables (e.g., `DOMAIN_NAME`, `MYSQL_ROOT_PASSWORD`, etc.) with your own secure values.

**Important**: Do not commit the `.env` file to Git.

### 3. Configure Your `hosts` File

To access services using the domain name, you need to edit your `/etc/hosts` file.

1.  Open the file with admin rights:
    ```sh
    sudo nano /etc/hosts
    ```
2.  Add these lines (replace `DOMAIN_NAME` from your domain name in your `.env` file):
    ```
    127.0.0.1 DOMAIN_NAME.42.fr
    ```

## Build and Launch

The `Makefile` at the project root makes management easy.

### First-Time Setup

To build the Docker images and launch all services for the first time:
```sh
make all
```

### Common Commands

-   **Start the services:**
    ```sh
    make up
    ```
-   **Stop the services:**
    ```sh
    make stop
    ```

## Container and Volume Management

### `Makefile` Commands

-   `make all`: Builds and starts everything.
-   `make build`: Builds the Docker images.
-   `make up`: Starts the services.
-   `make stop`: Stops the containers without removing them.
-   `make down`: Stops and removes containers and networks.
-   `make clean`: Runs `down` and removes the data directories (`/home/madelvin/data/*`).
-   `make fclean`: Full cleanup. Removes everything: containers, networks, volumes, images, and data.
-   `make re`: Runs `fclean` then `all`. Rebuilds everything from scratch.
-   `make logs`: Shows the logs from all services.
-   `make ps`: Shows the status of the containers.

## Data Persistence

### Where is data stored?

Important data (database, WordPress files) is stored on your host machine so it isn't lost. The main folder is `/home/madelvin/data`, as defined in the `Makefile`.

It contains:
-   `mariadb`: Database files.
-   `wordpress`: WordPress files (themes, plugins, uploads).

### Docker Volumes

The `docker-compose.yml` file uses volumes to link host folders to containers:
-   `mariadb_volume`: Links the container's `/var/lib/mysql` to `/home/madelvin/data/mariadb` on the host.
-   `wordpress_volume`: Links the container's `/var/www/html` to `/home/madelvin/data/wordpress` on the host.
-   `adminer_volume` and `portainer_volume`: Docker-managed volumes for their own data.

To delete this data, you must use `make clean` or `make fclean`.
