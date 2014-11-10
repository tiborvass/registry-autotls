FROM debian:jessie
MAINTAINER Tibor Vass <tibor@docker.com>

COPY generate_cert /usr/bin/
COPY wrapper.sh /

VOLUME ["/ssl", "/certs.d"]

ENTRYPOINT ["/wrapper.sh"]
