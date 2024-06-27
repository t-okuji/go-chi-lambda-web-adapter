# Development for local
FROM golang:1.22.4-alpine AS dev
WORKDIR /app
RUN go install github.com/air-verse/air@latest

# Build for prod
FROM golang:1.22.4-alpine AS build
WORKDIR /app
COPY ./app/ /app/
RUN go build -tags lambda.norpc -o main

# Production for lambda
FROM public.ecr.aws/lambda/provided:al2023 AS prod
# change lambda-web-adapter listen port (default port 8080)
ENV PORT 3000
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.3 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=build /app/main ./main
ENTRYPOINT [ "./main" ]