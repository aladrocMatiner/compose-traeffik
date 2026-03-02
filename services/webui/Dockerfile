FROM alpine:latest

# Install nginx
RUN apk add --no-cache nginx

# Create a simple web page
RUN echo "<h1>WebUI Service</h1><p>This is a placeholder for the WebUI service.</p>" > /var/www/index.html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
