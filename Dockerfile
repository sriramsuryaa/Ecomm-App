# BASE IMAGE
FROM nginx:alpine

# IMAGE LABELING
LABEL maintainer="developers@ecomm-app.com" \
      org.opencontainers.image.title="ECOMM-APP" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.description="ECOMM-APP"

# PORT EXPOSING
EXPOSE 80

# APP_BUILD COPYING
COPY build/. /usr/share/nginx/html/.