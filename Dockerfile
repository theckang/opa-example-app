FROM golang:alpine as builder
COPY main.go .
RUN go build -o /app .

FROM alpine:latest
CMD ["./app"]
COPY --from=builder /app .
