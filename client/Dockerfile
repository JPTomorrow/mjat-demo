# Stage 1: Build the Angular app
FROM node:18-alpine AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build -- --configuration=production --output-path=dist/mjat-demo

# Stage 2: Serve the app using NGINX
FROM nginx:1.25-alpine

# Clear default content and set permissions
RUN rm -rf /usr/share/nginx/html/* && \
    chown -R nginx:nginx /usr/share/nginx/html
COPY --from=build --chown=nginx:nginx /app/dist/mjat-demo /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]