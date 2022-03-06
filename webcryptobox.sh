#!/usr/bin/env bash
set -eo pipefail

# set the curve name via `CURVE` environment variable. Can be
# * `prime256v1` also known as P-256
# * `secp384r1` also know as P-384
# * `secp521r1` (default) aka P-521
: "${CURVE:=secp521r1}"

# set the key length via `LENGTH` environment variable. Can be
# * `128`
# * `256` (default)
: "${LENGTH:=256}"

CIPHER="aes-$LENGTH-cbc"
BYTES=`expr $LENGTH / 8`
IVLENGTH=16

CMD=$1
ARG1=$2
ARG2=$3
ARG3=$4

case $CMD in
  generate-key-pair)
    openssl ecparam -genkey -name $CURVE -noout | openssl pkey -in  -
    ;;

  derive-public-key)
    openssl pkey -in - -pubout
    ;;

  sha1-fingerprint)
    pem="$(cat)"
    pubin=""
    if echo "$pem" | grep PUBLIC > /dev/null; then
      pubin="-pubin"
    fi
    echo "$pem" | openssl pkey $pubin -in - -pubout -outform DER | openssl sha1
    ;;

  sha256-fingerprint)
    pem="$(cat)"
    pubin=""
    if echo "$pem" | grep PUBLIC > /dev/null; then
      pubin="-pubin"
    fi
    echo "$pem" | openssl pkey $pubin -in - -pubout -outform DER | openssl sha256
    ;;

  derive-key)
    openssl pkeyutl -derive -inkey $ARG1 -peerkey $ARG2 -kdflen $BYTES | xxd -p -c $BYTES
    ;;

  generate-key)
    openssl rand -hex $BYTES
    ;;

  generate-iv)
    openssl rand -hex $IVLENGTH
    ;;

  encrypt)
    openssl enc -nosalt -$CIPHER -in - -base64 -K $ARG1 -iv $ARG2
    ;;

  decrypt)
    openssl enc -nosalt -$CIPHER -d -in - -base64 -K $ARG1 -iv $ARG2
    ;;

  derive-and-encrypt)
    openssl enc -nosalt -$CIPHER -in - -base64 -K `openssl pkeyutl -derive -inkey $ARG1 -peerkey $ARG2 -kdflen $BYTES | xxd -p -c $BYTES` -iv $ARG3
    ;;

  derive-and-decrypt)
    openssl enc -nosalt -$CIPHER -d -in - -base64 -K `openssl pkeyutl -derive -inkey $ARG1 -peerkey $ARG2 -kdflen $BYTES | xxd -p -c $BYTES` -iv $ARG3
    ;;

  *)
    echo "unsupported command: '$CMD'"
    ;;
esac
