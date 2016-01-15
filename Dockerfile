FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update

# Update Ubuntu itself.
RUN apt-get upgrade -y -o Dpkg::Options::="--force-confold"

# Install s3fs-fuse build dependencies.
# Install curl for Filebeat.
# Install ubuntu-make to install Golang toolchain.
RUN apt-get install -y automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config git curl

# Build and install s3fs-fuse
# Reference: https://github.com/s3fs-fuse/s3fs-fuse/blob/master/README.md
WORKDIR /tmp
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git
WORKDIR /tmp/s3fs-fuse
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# Create directory for bucket mounted by s3fs-fuse.
RUN mkdir /mnt/s3

# Download and install Filebeat.
# Reference: https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-getting-started.html
RUN curl -L -O https://download.elastic.co/beats/filebeat/filebeat_1.0.1_amd64.deb
RUN dpkg -i filebeat_1.0.1_amd64.deb

# Install Golang.
WORKDIR /usr/local
RUN curl -O https://storage.googleapis.com/golang/go1.5.1.linux-amd64.tar.gz
RUN tar -xvf go1.5.1.linux-amd64.tar.gz
# Add Golang bin folder to path.
ENV PATH=$PATH:/usr/local/go/bin

# Create build dir for logreplay.
RUN mkdir -p /root/golang/src/github.com/hellofresh
WORKDIR /root/golang/src/github.com/hellofresh
# Clone logreplay Git repository.
RUN git clone https://github.com/hellofresh/logreplay.git
# Set GOPATH so build dependencies are resolvable.
ENV GOPATH=/root/golang
# Change into build dir.
WORKDIR /root/golang/src/github.com/hellofresh/logreplay
# Build logreplay binary.
RUN go build -o logreplay logreplay.go

# Execute logreplay.linux which handles:
# - writing of config files (aws_creds and filebeat.yml) based on environment variables,
# - mounting S3 bucket using s3fs-fuse,
# - starting filebeat agent.
WORKDIR /root/golang/src/github.com/hellofresh/logreplay
CMD /root/golang/src/github.com/hellofresh/logreplay/logreplay
