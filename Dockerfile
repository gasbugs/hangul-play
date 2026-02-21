# Stage 1: Build
FROM ghcr.io/cirruslabs/flutter:stable AS build-stage

WORKDIR /app

# Copy dependency files first for better caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source and assets
COPY . .
RUN flutter build web --release

# Stage 2: Production
FROM nginx:stable-alpine

# Use custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy build files from build stage
COPY --from=build-stage /app/build/web /usr/share/nginx/html

# Place configuration injection script into official nginx entrypoint directory
COPY 30-inject-config.sh /docker-entrypoint.d/30-inject-config.sh
RUN chmod +x /docker-entrypoint.d/30-inject-config.sh

# Setup non-root environment
RUN touch /var/run/nginx.pid && \
    mkdir -p /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    chown -R nginx:nginx /var/run/nginx.pid /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /usr/share/nginx/html /docker-entrypoint.d

# Give nginx user recursive write access to the specific assets folder for runtime injection
# We do this as root before switching users
RUN chown -R nginx:nginx /usr/share/nginx/html/assets/

USER nginx

EXPOSE 8080

# Default Nginx image ENTRYPOINT will run everything in /docker-entrypoint.d/ then start nginx
