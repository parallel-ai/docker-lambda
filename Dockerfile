

ARG FUNCTION_DIR="/home/app/"
ARG RUNTIME_VERSION="3.9"
ARG DISTRO_VERSION="3.12"

# Stage 1 - bundle base image + runtime
# Grab a fresh copy of the image and install GCC
FROM python:${RUNTIME_VERSION}-alpine${DISTRO_VERSION} AS python-alpine
# Install GCC (Alpine uses musl but we compile and link dependencies with GCC)
RUN apk add --no-cache \
    libstdc++

# Stage 2 - build function and dependencies
FROM python-alpine AS build-image
# Install aws-lambda-cpp build 
RUN apk add --update python3-dev
RUN apk add --no-cache \
    build-base \
    libtool \
    autoconf \
    automake \
    libexecinfo-dev \
    gcc \
    make \
    cmake \
    libcurl




# Include global args in this stage of the build
ARG FUNCTION_DIR
ARG RUNTIME_VERSION
# Create function directory
RUN mkdir -p ${FUNCTION_DIR}
# Copy handler function
COPY . ${FUNCTION_DIR}
# Optional – Install the function's dependencies



COPY requirements.txt .

# RUN python${RUNTIME_VERSION} -m pip install -r requirements.txt --target ${FUNCTION_DIR}
# Install Lambda Runtime Interface Client for Python

RUN python${RUNTIME_VERSION} -m pip install awslambdaric --target ${FUNCTION_DIR}

# Stage 3 - final runtime image
# Grab a fresh copy of the Python image
# FROM ubuntu:18.04
# FROM  debian:latest
FROM python-alpine
# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}
# Copy in the built dependencies
RUN ls -lrta
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}


ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie

RUN chmod 755 /usr/bin/aws-lambda-rie


COPY entry.sh .
RUN apk add --no-cache jpeg-dev zlib-dev

COPY requirements.txt .
RUN apk add build-base
# RUN pip install httpclien
RUN apk add postgresql-client \
  && apk add libxml2-dev libxslt-dev
# RUN pip install lxml==3.1.2
RUN apk add --update --no-cache --virtual .build-deps \
        g++ \
        libxslt-dev \
        libxml2 \
        libxml2-dev && \
    apk add libxslt-dev && \
    apk del .build-deps

RUN pip install textract

RUN pip install -r requirements.txt 

RUN ["chmod", "+x", "entry.sh"]

ENTRYPOINT [ "/home/app/entry.sh" ]
CMD [ "app.handler" ]
