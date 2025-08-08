# 1 Build production
FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# 2 serve the bundle
FROM nginx:1.27.0
COPY --from=build /app/build /usr/share/nginx/html
