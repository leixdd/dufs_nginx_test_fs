# File Server

A dual file server setup with both **Nginx** (simple static serving) and **Dufs** (advanced file server with uploads) for hosting static files like PDFs and images.

## Features

### Nginx Server
- 📁 Simple directory browsing with autoindex
- 🖼️ Optimized for PDFs and images
- 🚀 Fast and lightweight
- 📖 Read-only access
- 🔓 No authentication required
- 🔧 Configurable port via environment variable

### Dufs Server
- 📁 Beautiful modern directory browsing interface
- 🚀 Fast static file serving written in Rust
- 📤 Upload support enabled
- 🔐 Authentication required (configurable)
- 📦 Download folders as ZIP archives
- 🐳 Easy deployment with Docker Compose
- 🔧 Configurable port via environment variable

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. **Clone or navigate to this directory**

2. **Add your files**
   
   Place your PDFs, images, and other static files in the `files/` directory:
   ```bash
   cp /path/to/your/file.pdf files/
   cp /path/to/your/image.jpg files/
   ```

3. **Set required environment variables**
   ```bash
   export NGINX_PORT=8080
   export DUFS_PORT=5001
   export DUFS_AUTH="admin:password"
   ```

4. **Start the servers**
   ```bash
   docker-compose up -d
   ```

5. **Access your files**
   
   - **Nginx** (simple, no auth): http://localhost:8080
   - **Dufs** (advanced, with auth): http://localhost:5001

## Services

### Nginx Service
- **Port**: Configurable via `NGINX_PORT` environment variable (default: 8080)
- **Access**: http://localhost:${NGINX_PORT}
- **Features**: Directory listing, PDF/image serving, caching
- **Authentication**: None
- **Permissions**: Read-only

### Dufs Service
- **Port**: Configurable via `DUFS_PORT` environment variable (default: 5001)
- **Access**: http://localhost:${DUFS_PORT}
- **Features**: Upload, delete, ZIP download, search, authentication
- **Authentication**: Required via `DUFS_AUTH` environment variable
- **Permissions**: Read-write with uploads enabled

## Usage

### Starting the Servers

Start both services:
```bash
NGINX_PORT=8080 DUFS_PORT=5001 DUFS_AUTH="username:password" docker-compose up -d
```

Start only nginx:
```bash
NGINX_PORT=8080 docker-compose up -d nginx
```

Start only dufs:
```bash
DUFS_PORT=5001 DUFS_AUTH="username:password" docker-compose up -d fileserver
```

### Stopping the Servers
```bash
docker-compose down
```

### Viewing Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f nginx
docker-compose logs -f fileserver
```

### Rebuilding After Changes
```bash
docker-compose up -d --build
```

## Configuration

### Environment Variables

This project requires the following environment variables:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `NGINX_PORT` | Yes | - | Port for nginx server (e.g., 8080) |
| `DUFS_PORT` | Yes | - | Port for dufs server (e.g., 5001) |
| `DUFS_AUTH` | Yes | - | Authentication for dufs (format: `username:password`) |

Example:
```bash
export NGINX_PORT=8080
export DUFS_PORT=5001
export DUFS_AUTH="admin:secret"
docker-compose up -d
```

Or inline:
```bash
NGINX_PORT=8080 DUFS_PORT=5001 DUFS_AUTH="admin:secret" docker-compose up -d
```

**Note**: The `@/:rw` suffix is automatically added to `DUFS_AUTH` in the docker-compose.yml configuration to grant read-write access to the root path.

### Change Ports

Ports are configured via environment variables. Simply change the values:

```bash
# Use different ports
export NGINX_PORT=3000
export DUFS_PORT=3001
export DUFS_AUTH="admin:password"
docker-compose up -d
```

### Nginx Configuration

The nginx server is configured via `nginx.conf`:
- **Autoindex**: Enabled for directory browsing
- **PDF handling**: Served with inline content disposition
- **Image caching**: 1 year cache for images
- **Hidden files**: Access denied

Modify `nginx.conf` to customize behavior, then rebuild:
```bash
docker-compose up -d --build nginx
```

### Dufs Permissions

The dufs service currently has:
- **Read-write** volume mount
- **Upload** enabled (`-A --allow-upload`)
- **Authentication** required

To make it read-only, edit `docker-compose.yml`:
```yaml
volumes:
  - ./files:/data:ro  # Change :rw to :ro
```

## Directory Structure

```
nginx-fileserver/
├── Dockerfile              # Nginx Docker image definition
├── nginx.conf              # Nginx server configuration
├── docker-compose.yml      # Docker Compose configuration
├── .gitignore              # Git ignore rules
├── .dockerignore           # Docker ignore rules
├── files/                  # Your files go here (git ignored)
│   └── .gitkeep
└── README.md               # This file
```

## Important Notes

- The `files/` directory contents are **git ignored** - your files won't be committed to version control
- Files are **mounted as volumes** in Docker - they're not copied into the image
- This keeps your Docker images lightweight and your repository clean
- **Nginx** is read-only (`:ro` mount) for security
- **Dufs** has read-write (`:rw` mount) to enable uploads

## File Access

Files placed in the `files/` directory will be accessible at:

**Via Nginx:**
```
http://localhost:${NGINX_PORT}/your-file.pdf
http://localhost:${NGINX_PORT}/subfolder/image.jpg
```

**Via Dufs:**
```
http://localhost:${DUFS_PORT}/your-file.pdf
http://localhost:${DUFS_PORT}/subfolder/image.jpg
```

Replace `${NGINX_PORT}` and `${DUFS_PORT}` with the actual port numbers you configured.

## Security Notes

- **Nginx**: Read-only access, no authentication, suitable for public file serving
- **Dufs**: Authentication required via environment variable, read-write access for uploads
- Environment variables (`DUFS_AUTH`, `NGINX_PORT`, `DUFS_PORT`) should not be committed to version control
- Consider using a `.env` file for sensitive credentials (ensure it's in `.gitignore`)
- Avoid exposing ports to the internet without proper security measures

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs

# Check if ports are already in use (replace with your configured ports)
lsof -i :8080
lsof -i :5001
```

### Environment variable errors
Ensure all required environment variables are set:
```bash
export NGINX_PORT=8080
export DUFS_PORT=5001
export DUFS_AUTH="username:password"
docker-compose up -d
```

### Dufs authentication error
Ensure you've set the `DUFS_AUTH` environment variable:
```bash
export DUFS_AUTH="username:password"
export DUFS_PORT=5001
docker-compose up -d fileserver
```

### Files not showing up
- Ensure files are in the `files/` directory
- Check file permissions
- Restart the containers: `docker-compose restart`

### Permission issues
```bash
# Ensure files are readable
chmod -R 755 files/
```

### Nginx 404 errors
Check that:
- Files exist in the `files/` directory
- The nginx container is running: `docker-compose ps`
- The volume mount is correct in docker-compose.yml

## Use Cases

### Use Case 1: Simple Public File Hosting
Use the **nginx service** for:
- Public file sharing
- No authentication needed
- Read-only access
- Simple directory browsing

### Use Case 2: Authenticated Upload Server
Use the **dufs service** for:
- Authenticated file management
- Upload and delete capabilities
- Advanced search features
- Download folders as ZIP

### Use Case 3: Both Services
Run both services simultaneously:
- Public read-only access via nginx (configurable port)
- Authenticated uploads via dufs (configurable port)

## Examples

### Set up persistent environment variables
Create a shell script or add to your `.bashrc` / `.zshrc`:
```bash
echo 'export NGINX_PORT=8080' >> ~/.zshrc
echo 'export DUFS_PORT=5001' >> ~/.zshrc
echo 'export DUFS_AUTH="admin:mypassword"' >> ~/.zshrc
source ~/.zshrc
```

### Upload files via dufs web interface
1. Navigate to http://localhost:5001 (or your configured `DUFS_PORT`)
2. Log in with your credentials
3. Click the upload button or drag & drop files

### Use nginx for embedding
Since nginx doesn't require authentication, you can embed files directly:
```html
<!-- Replace 8080 with your NGINX_PORT -->
<img src="http://localhost:8080/image.jpg" />
<embed src="http://localhost:8080/document.pdf" />
```

## License

MIT

## Support

For issues and questions, please refer to:
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Dufs GitHub Repository](https://github.com/sigoden/dufs)
- [Dufs Documentation](https://github.com/sigoden/dufs#readme)
