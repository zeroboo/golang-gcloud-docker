FROM docker:20.10.16
#FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:alpine

RUN apk update
RUN apk add tar

# Install golang
ARG GOLANG_VERSION=1.19.4
# We need the go version installed from apk to bootstrap the custom version built from source
RUN apk add go gcc bash musl-dev openssl-dev ca-certificates && update-ca-certificates
RUN wget https://dl.google.com/go/go$GOLANG_VERSION.src.tar.gz && tar -C /usr/local -xzf go$GOLANG_VERSION.src.tar.gz
RUN cd /usr/local/go/src && ./make.bash
ENV PATH=$PATH:/usr/local/go/bin
RUN rm go$GOLANG_VERSION.src.tar.gz
# Delete the apk installed version to avoid conflict
RUN apk del go
RUN go version


# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

# Install jre
RUN apk add openjdk7-jre

# Install gcloud-cli
ARG GCLOUD_CLI_VERSION=412.0.0
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-$GCLOUD_CLI_VERSION-linux-x86_64.tar.gz
RUN tar -xzf google-cloud-cli-$GCLOUD_CLI_VERSION-linux-x86_64.tar.gz
RUN ./google-cloud-sdk/install.sh
ENV SDK_PATH="/google-cloud-sdk"
ENV PATH=$PATH:$SDK_PATH
RUN $SDK_PATH/bin/gcloud components install app-engine-java kubectl gke-gcloud-auth-plugin
