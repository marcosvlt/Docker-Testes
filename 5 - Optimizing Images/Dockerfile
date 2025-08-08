# First stage: build
FROM node:22 AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY src/ src/

# Stage 2: Final Image using Distroless
FROM gcr.io/distroless/nodejs
WORKDIR /app
COPY --from=build /app/node_modules node_modules
COPY --from=build /app/src src


CMD ["src/index.js"]