ARG IMG_TAG=latest

# Compile the gaiad binary
FROM golang:1.18-alpine AS gaiad-builder
WORKDIR /src/app/
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
ENV KO_DOCKER_REPO=ghcr.io/cosmos
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3
RUN apk add --no-cache $PACKAGES
RUN make install

# Add to a distroless container
FROM distroless.dev/ko:$IMG_TAG
ARG IMG_TAG
COPY --from=gaiad-builder /go/bin/gaiad /usr/local/bin/
EXPOSE 26656 26657 1317 9090
USER 0

ENTRYPOINT ["gaiad", "start"]
