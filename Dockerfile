FROM nginx:latest
RUN sed -i 's/nginx/Push_registry/g' /usr/share/nginx/html/index.html
EXPOSE 80
