# Installing Axelor Using Docker

This guide provides a step-by-step solution for installing Axelor using Docker. After extensive research, I found that the available documentation is limited, and errors are common. Therefore, I’m sharing this solution in case someone finds it helpful.

## Prerequisites

Ensure you have the following installed on your system:

- Docker
- Docker Compose

## Steps to Install

1. Clone this repository:

   ```bash
   git clone https://github.com/RAJI-Zakaria/axelor-open-suite
   ```

2. Navigate to the project directory:

   ```bash
   cd axelor-open-suite
   ```

3. Build and start the containers:

   ```bash
   sh ./startup.sh
   ```

4. Access the application in your browser at `http://localhost:7070` --> `user : admin | pass : admin`.

Note : `Please note that when you run the app for the first time, it will take ±10 minutes to create database and prepare files...`

## Stopping and Cleaning Up

1. To stop and remove the Axelor containers, run:

   ```bash
   ./shutdown.sh
   ```

2. To delete all data and start fresh, run:

   ```bash
   ./removeAll.sh
   ```

## Environment Variables

This project uses environment variables defined in the `.env` file. Here are the key variables you can configure:

### Database Configuration (Shared by PostgreSQL and Axelor containers)

- `DB_USER`: Database username (default: `postgres`)
- `DB_PASSWORD`: Database password (default: `admin`)
- `DB_NAME`: Database name (default: `public`)
- `DB_PORT`: Database port (default: `5432`)
- `DB_HOST`: Database hostname for connections (default: `postgres`)
- `POSTGRES_IMAGE`: PostgreSQL Docker image version (default: `postgres:15`)

### PgAdmin Configuration (PgAdmin Container)

- `PGADMIN_DEFAULT_EMAIL`: PgAdmin login email (default: `admin@admin.com`)
- `PGADMIN_DEFAULT_PASSWORD`: PgAdmin login password (default: `admin`)
- `PGADMIN_PORT`: PgAdmin web interface port (default: `5050`)
- `PGADMIN_IMAGE`: PgAdmin Docker image version (default: `dpage/pgadmin4:latest`)

### Axelor Application Configuration (Axelor Container)

- `AXELOR_PORT`: Application port (default: `7070`)
- `JAVA_OPTS`: JVM options (default: `-Xms1024m -Xmx2048m`)

_Note: Axelor automatically uses the database configuration variables (`DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_HOST`, `DB_PORT`) defined above._

### Build Configuration

- `GRADLE_VERSION`: Gradle version for building (default: `7.6`)
- `AXELOR_REPO`: Git repository URL for Axelor source code
- `AXELOR_VERSION`: Axelor version to build (default: `8.0`)

### Health Check Configuration

- `HEALTH_CHECK_INTERVAL`: Interval between health checks (default: `30s`)
- `HEALTH_CHECK_TIMEOUT`: Health check timeout (default: `10s`)
- `HEALTH_CHECK_RETRIES`: Number of health check retries (default: `5`)
- `HEALTH_CHECK_START_PERIOD`: Grace period before first health check (default: `120s`)

### Data Storage (Railway Deployment)

For Railway deployment, all data is stored in a single volume mounted at `/usr/local/tomcat/data` which includes:

- Application uploads
- Export files
- Search indexes

## Configuration Details

- PostgreSQL is configured with the credentials defined in your `.env` file
- Axelor application is exposed on the port defined by `AXELOR_PORT`
- All containers communicate through Docker's internal network

## Common Issues and Solutions

- **Database Connection Error**: Ensure the database container is running, and the credentials in `axelor-config.properties` match those in `docker-compose.yml`.

- **Port Conflict**: If port `7070` is already in use, update the port mapping in the `docker-compose.yml` file.

## Notes

This project includes three scripts for easier management:

1. `startup.sh` - Builds and starts the Axelor application.
2. `shutdown.sh` - Stops and removes the Axelor containers without affecting data.
3. `removeAll.sh` - Deletes all containers, volumes, and networks related to Axelor, allowing for a fresh start.

Feel free to adapt the scripts to your requirements. For any issues, please raise an issue in the repository.

## Guide: Connect pgAdmin to Axelor PostgreSQL Database

This guide explains step-by-step how to use **pgAdmin** to connect to the PostgreSQL database used by Axelor.

---

### Prerequisites

1. **pgAdmin** is installed and running.
2. PostgreSQL is running as a Docker container.
3. You have access to the pgAdmin credentials:

   - Email: `admin@admin.com`
   - Password: `admin`.

4. The database details:
   - **Hostname**: `postgres` (Docker service name).
   - **Port**: `5432`.
   - **Database Name**: `axelor`.
   - **Username**: `axelor`.
   - **Password**: `axelor`.

---

### Steps to Connect pgAdmin to the Database

1. **Log into pgAdmin**:

   - Open pgAdmin in your browser `http://localhost:5050`.
   - Use the credentials:
     - Email: `admin@admin.com`
     - Password: `admin`.

2. **Register the Server**:

   - Right-click on "Servers" and choose **Register → Server**.
   - Go to the **Connection** tab and fill in the following details:
     - **Host name/address**: `postgres`
     - **Port**: `5432`
     - **Maintenance database**: `postgres`
     - **Username**: `axelor`
     - **Password**: `axelor`
   - Click **Save**.

3. **Test the Connection**:
   - pgAdmin will attempt to connect to the database.
   - If successful, you will see the database tree under the registered server.

---

### Common Issues & Fixes

1. **Unable to Connect to Server**:

   - Verify the `docker-compose` file is running and PostgreSQL is active:

     ```bash
     docker-compose ps
     ```

     Look for the `axelor-postgres` service.

2. **Wrong Hostname**:

   - In a Docker network, use the service name `postgres` instead of `localhost`.

3. **Incorrect Credentials**:

   - Double-check the database username and password. Both should be `axelor`.

4. **Firewall Blocking Connections**:
   - Ensure port `5432` is open and accessible.
