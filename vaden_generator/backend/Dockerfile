FROM dart:3.6.0 AS build

WORKDIR /app
COPY pubspec.* ./
RUN echo "resolution:" > pubspec_overrides.yaml
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart run build_runner build --delete-conflicting-outputs
RUN dart compile exe bin/backend.dart -o bin/server

FROM scratch
WORKDIR /app
COPY --from=build /runtime/ /
COPY --from=build /app/assets/ /app/assets/
COPY --from=build /app/bin/server /app/
EXPOSE 8080
CMD ["./server"]

