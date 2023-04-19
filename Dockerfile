FROM ubuntu:18.04

RUN \
    apt update && \
    apt -y upgrade && \
    apt install -y build-essential && \
    apt install -y software-properties-common && \
    apt install -y man unzip vim wget sudo

WORKDIR /app
