# User Guide

This guide explains how to use the project.

## What's Inside?

This project runs several services:
- **NGINX**: The web server that directs traffic.
- **WordPress**: To create your website.
- **MariaDB**: The database for WordPress.
- **Redis**: A cache to speed up the site.
- **FTP**: To transfer files.
- **Adminer**: To manage the database.
- **Static Site**: A simple website.
- **Portainer**: To see and manage the Docker containers.

## Setup

Before you can start the services, you need to create a configuration file for your secrets and domain name.

1.  Navigate to the `srcs` directory:
    ```sh
    cd srcs
    ```
2.  Copy the example file `.env.example` to a new file named `.env`:
    ```sh
    cp .env.example .env
    ```
3.  Open the `.env` file and fill in your own passwords and `DOMAIN_NAME`.

## Starting and Stopping

### Start
To launch everything, open a terminal at the project root and run:
```sh
make all
```
If everything is already built, you can just run:
```sh
make up
```

### Stop
- To **stop** the services without deleting anything:
  ```sh
  make stop
  ```
- To **stop and remove the containers and networks** (your data will be safe):
  ```sh
  make down
  ```
- To **delete everything**, including your data (database, WordPress files):
  ```sh
  make clean
  ```
  Or for a more thorough cleanup that also removes Docker images:
  ```sh
  make fclean
  ```

## Accessing Services

To access the sites, use the domain name you set up in your `srcs/.env` file (`DOMAIN_NAME`).

- **WordPress Site**: `https://<your_domain_name>`
- **Static Site**: `https://<your_domain_name>/static/`
- **Adminer (DB Management)**: `https://<your_domain_name>/adminer/`
- **Portainer (Docker Management)**: `https://<your_domain_name>/portainer/`

## Managing Passwords

All passwords and credentials are in the `srcs/.env` file, which you created from `.env.example`. Keep this file secure and do not share it.

## Checking if Everything Works

To see the status of the services:
```sh
make ps
```
This command lists the containers and shows if they are running (`Up`).

To see the logs (live output) from the services:
```sh
make logs
```
This is useful for finding errors.
