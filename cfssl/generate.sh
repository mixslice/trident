#!/bin/bash

SECRETS_DIR=$PWD/secrets
CFSSL_DIR=$(dirname "${BASH_SOURCE[0]}")

cfssl gencert -ca=$SECRETS_DIR/ca.pem \
    -ca-key=$SECRETS_DIR/ca-key.pem \
    -config=$CFSSL_DIR/ca-config.json \
    -hostname="$3" \
    -profile=$1 \
    $CFSSL_DIR/$2.json | \
    cfssljson -bare $SECRETS_DIR/$2
