#!/bin/sh

[ -z "$REGISTRY_HOST" ] && REGISTRY_HOST="0.0.0.0"
[ -z "$REGISTRY_PORT" ] && REGISTRY_PORT="5000"
[ -z "$REGISTRY_DOMAIN" ] && REGISTRY_DOMAIN="localhost"

certsd="/certs.d/$REGISTRY_DOMAIN:$REGISTRY_PORT"

set -e

generate_cert --cert "/ssl/ca.crt" --key "/ssl/ca.key" >/dev/null
mkdir -p "$certsd" && cp /ssl/ca.crt "$certsd/"

generate_cert --host "$REGISTRY_DOMAIN" --ca "/ssl/ca.crt" --ca-key "/ssl/ca.key" --cert "/ssl/registry.cert" --key "/ssl/registry.key" >/dev/null

generator_cid="$(grep ':/docker/' /proc/1/cgroup | head -1 | cut -d/ -f3)"

echo docker run -d \
	-e REGISTRY_HOST="$REGISTRY_HOST" \
	-e REGISTRY_PORT="$REGISTRY_PORT" \
	-e GUNICORN_OPTS="['--certfile','/ssl/registry.cert','--keyfile','/ssl/registry.key','--ca-certs','/ssl/ca.crt','--ssl-version',3]" \
	--volumes-from "$generator_cid" \
	-p 127.0.0.1:$REGISTRY_PORT:$REGISTRY_PORT \
	$@ registry
