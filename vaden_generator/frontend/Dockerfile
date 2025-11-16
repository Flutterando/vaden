FROM ghcr.io/cirruslabs/flutter:3.38.1 AS build

WORKDIR /app

COPY . .
RUN echo "resolution:" > pubspec_overrides.yaml
RUN flutter pub get
RUN flutter build web --release --dart-define-from-file .env_prod 

FROM nginx:stable-alpine

RUN rm -rf /usr/share/nginx/html/*

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]