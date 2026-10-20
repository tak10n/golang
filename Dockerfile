# ---- 開発用ステージ（ホットリロード） ----
FROM golang:1.27-alpine AS dev
WORKDIR /app
RUN apk add --no-cache git && go install github.com/air-verse/air@latest
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
CMD ["air", "-c", ".air.toml"]

# ---- ビルドステージ ----
FROM golang:1.27-alpine AS build
WORKDIR /app
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /bin/app .

# ---- 本番用ステージ（軽量） ----
FROM gcr.io/distroless/static-debian12 AS prod
COPY --from=build /bin/app /app
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/app"]
