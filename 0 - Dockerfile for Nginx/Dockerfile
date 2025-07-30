FROM nginx:1.29

RUN apt-get update && \
    apt-get install -y vim && \
    apt-get clean

COPY index.html /usr/share/nginx/html/index.html
RUN chown -R nginx:nginx /usr/share/nginx/html/index.html