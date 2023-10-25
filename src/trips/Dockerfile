# builder - first stage to build the application
FROM mcr.microsoft.com/oss/go/microsoft/golang:1.17 AS gobuild

WORKDIR /go/src/app
COPY . .

ENV GO111MODULE=on
RUN go get
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# runtime - build final runtime image
FROM mcr.microsoft.com/cbl-mariner/distroless/base:1.0 AS gorun

ARG IMAGE_CREATE_DATE
ARG IMAGE_VERSION
ARG IMAGE_SOURCE_REVISION

ENV PORT="80" \
    CONFIG_FILES_PATH="/secrets" \
    OPENAPI_DOCS_URI="http://changeme" \
    DEBUG_LOGGING="false"

# Metadata as defined in OCI image spec annotations - https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="Trip Insights - Trips API" \
    org.opencontainers.image.description="The Trips API component forms part of the Trip Insights application." \
    org.opencontainers.image.created=$IMAGE_CREATE_DATE \
    org.opencontainers.image.version=$IMAGE_VERSION \
    org.opencontainers.image.authors="Microsoft" \
    org.opencontainers.image.url="https://github.com/microsoft/secure-software-supply-chain-on-aks/blob/main/src/trips/Dockerfile" \
    org.opencontainers.image.documentation="https://github.com/microsoft/secure-software-supply-chain-on-aks/blob/main/src/trips/README.md" \
    org.opencontainers.image.vendor="Microsoft" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/microsoft/secure-software-supply-chain-on-aks.git" \
    org.opencontainers.image.revision=$IMAGE_SOURCE_REVISION

# add the application to the container
WORKDIR /app
COPY --from=gobuild /go/src/app/main .
COPY --from=gobuild /go/src/app/api ./api/

# run the application
EXPOSE $PORT
ENTRYPOINT ["/app/main"]
