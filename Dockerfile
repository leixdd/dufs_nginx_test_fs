FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create directory for files
RUN mkdir -p /usr/share/nginx/html/files

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
