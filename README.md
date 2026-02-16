# Inception - SysAdmin with Docker

## Description
The **Inception** project is a practical introduction to system administration using **Docker**. The goal is to set up a small infrastructure of different services, all running in their own isolated containers, managed by **Docker Compose**.

infrastructure :
* A **NGINX** container serving as the only entry point via port 443 with TLS v1.2/v1.3.
* A **WordPress** container running with `php-fpm`.
* A **MariaDB** container for database management.
* A **Docker Network** for secure inter-container communication.
* **Operating System:** All containers are built from **Debian BookWorm**.
* **Init Process:** To avoid "hacky" patches like `tail -f`, each service is configured to run in the foreground, respecting the **PID 1** philosophy and allowing proper signal handling.
* **Security:** No passwords are hardcoded in Dockerfiles. All sensitive data is handled via `.env` files and **Docker Secrets**.

---

## Technical Comparisons

| Feature | Comparison & Choice |
| :--- | :--- |
| **Virtual Machines vs Docker** | VMs emulate an entire hardware stack including a kernel, making them resource-heavy. **Docker** shares the host kernel, providing lightweight and fast isolation. |
| **Secrets vs Env Variables** | **Environment variables** are easier to implement but can be leaked in logs or process lists. **Secrets** are more secure as they are mounted as files and are only available to the specific service. |
| **Docker Network vs Host** | Using the `host` network bypasses isolation. We use a custom **Docker Bridge Network** to allow containers to communicate by service name while remaining isolated from the host. |
| **Docker Volumes vs Bind Mounts** | **Bind mounts** depend on the host's directory structure. **Named Volumes** are managed by Docker, ensuring better performance and portability while keeping data in `/home/[login]/data`. |

---

## Instructions

### Prerequisites
* Docker and Docker Compose installed.
* Update your `/etc/hosts` file to map the domain to your local IP:
    ```bash
    127.0.0.1  [your_login].42.fr
    ```

### Execution
The project is entirely managed through a `Makefile` located at the root of the repository.

1.  **Build and Start:**
    ```bash
    make up
    ```
2.  **Stop Containers:**
    ```bash
    make down
    ```
3.  **Full Cleanup (Containers, Images, and Volumes):**
    ```bash
    make clean
    ```

The website will be accessible at `https://[your_login].42.fr`.

---

## Resources

* [Docker Documentation](https://docs.docker.com/)
* [NGINX SSL/TLS Official Guide](https://nginx.org/en/docs/http/configuring_https_servers.html)
* [mariaDB Basic Official Guide](https://mariadb.com/docs/server/mariadb-quickstart-guides/basics-guide)

### AI Usage
AI (Gemini) was utilized during this project for the following tasks:
* **Structure & Documentation:** Assisting in formatting of this README.
* **Debugging:** Troubleshooting specific PHP-FPM socket connection and FTP port issues.
* **Best Practices:** Clarifying the implementation of Docker Secrets vs Environment Variables.
* *Note: All Dockerfiles and service configurations were manually written and tested.*

---
