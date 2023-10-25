FROM mcr.microsoft.com/cbl-mariner/base/nodejs:16

ARG IMAGE_CREATE_DATE
ARG IMAGE_VERSION
ARG IMAGE_SOURCE_REVISION

ENV PORT=80 \
  CONFIG_FILES_PATH="/secrets"

# Metadata as defined in OCI image spec annotations - https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="Trip Insights - User Profile API" \
  org.opencontainers.image.description="The User Profile API component forms part of the TripInsights application." \
  org.opencontainers.image.created=$IMAGE_CREATE_DATE \
  org.opencontainers.image.version=$IMAGE_VERSION \
  org.opencontainers.image.authors="Microsoft" \
  org.opencontainers.image.url="https://github.com/microsoft/secure-software-supply-chain-on-aks/blob/main/src/userprofile/Dockerfile" \
  org.opencontainers.image.documentation="https://github.com/microsoft/secure-software-supply-chain-on-aks/blob/main/src/userprofile/README.md" \
  org.opencontainers.image.vendor="Microsoft" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.source="https://github.com/microsoft/secure-software-supply-chain-on-aks.git" \
  org.opencontainers.image.revision=$IMAGE_SOURCE_REVISION 

# add debugging utilities
RUN yum -y install \
  curl \
  ca-certificates \
  jq \
  less \
  vim

# bundle app and install dependencies 
COPY . /app
WORKDIR /app
RUN npm install

# run application
EXPOSE $PORT
CMD npm start
