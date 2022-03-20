#!/usr/bin/env bash

# WebCrypto compatible cryptography library
# Version: 2.0.0

set -eo pipefail

# cipher config
CURVE=secp521r1
KEY_LENGTH=256
CIPHER=aes-${KEY_LENGTH}-cbc
IV_BYTES_LENGTH=16
ITERATIONS=64000
PASSPHRASE_LENGTH=32


KEY_BYTES_LENGTH=$( expr ${KEY_LENGTH} / 8 )


key () {
  openssl rand -hex ${KEY_BYTES_LENGTH}
}


encrypt () {
  key="${1}"
  filename="${2}"
  
  iv=$( openssl rand -hex ${IV_BYTES_LENGTH} )
  {
    ( echo -n "${iv}" | xxd -r -p ) &
    ( cat "${filename}" | openssl enc -nosalt -${CIPHER} -in - -K "${key}" -iv "${iv}" );
  } \
    | openssl base64
}

decrypt () {
  key="${1}"
  filename="${2}"

  tmpfile=$( mktemp /tmp/wcb.XXXXXX )
  exec 3> "${tmpfile}"
  exec 4< "${tmpfile}"
  exec 5< "${tmpfile}"
  
  cat "${filename}" \
    | openssl base64 -d \
    >&3

  iv=$( cat <&4 | xxd -p -l ${IV_BYTES_LENGTH} )

  cat <&5 \
    | xxd -p -s ${IV_BYTES_LENGTH} \
    | xxd -r -p \
    | openssl enc -nosalt -${CIPHER} -d -in - -K "${key}" -iv "${iv}"

  rm "${tmpfile}"
  exec 3>&-
}


private_key () {
  openssl ecparam -genkey -name ${CURVE} -noout \
    | openssl pkey -in -
}

public_key () {
  filename="${1}"
  openssl pkey -in "${filename}" -pubout
}

fingerprint () {
  filename="${1}"
  hashfunction="${2}"
  
  pubin=""
  if grep PUBLIC "${filename}" > /dev/null; then
    pubin="-pubin"
  fi
  
  cat "${filename}" \
    | openssl pkey ${pubin} -in - -pubout -outform DER \
    | openssl "${hashfunction}"
}

derive_key () {
  private_key="${1}"
  public_key="${2}"

  openssl pkeyutl -derive -kdflen ${KEY_BYTES_LENGTH} \
    -inkey "${private_key}" -peerkey "${public_key}" \
    | xxd -p -l ${KEY_BYTES_LENGTH} -c ${KEY_BYTES_LENGTH}
}

derive_password () {
  private_key="${1}"
  public_key="${2}"
  length="${3}"

  total_bytes_length=$( expr "${length}" + ${KEY_BYTES_LENGTH} )
  openssl pkeyutl -derive -kdflen "${total_bytes_length}" \
    -inkey "${private_key}" -peerkey "${public_key}" \
    | xxd -p -s ${KEY_BYTES_LENGTH} -l "${length}" -c "${length}"
}


encrypt_private_key () {
  passphrase="${1}"
  filename="${2}"

  PASSPHRASE="${passphrase}" \
    openssl pkcs8 -topk8 -inform PEM -outform PEM -iter ${ITERATIONS} -v2 ${CIPHER} -passout env:PASSPHRASE -in "${filename}"
}

decrypt_private_key () {
  passphrase="${1}"
  filename="${2}"

  PASSPHRASE="${passphrase}" \
    openssl pkcs8 -topk8 -inform PEM -outform PEM -passin env:PASSPHRASE -in "${filename}" --nocrypt
}


encrypt_private_key_to () {
  private_key="${1}"
  public_key="${2}"
  filename="${3}"

  passphrase=$( derive_password "${private_key}" "${public_key}" ${PASSPHRASE_LENGTH} )
  encrypt_private_key "${passphrase}" "${filename}"
}

decrypt_private_key_from () {
  private_key="${1}"
  public_key="${2}"
  filename="${3}"

  passphrase=$( derive_password "${private_key}" "${public_key}" ${PASSPHRASE_LENGTH} )
  decrypt_private_key "${passphrase}" "${filename}"
}


encrypt_to () {
  private_key="${1}"
  public_key="${2}"
  filename="${3}"

  key=$( derive_key "${private_key}" "${public_key}" )
  encrypt "${key}" "${filename}"
}

decrypt_from () {
  private_key="${1}"
  public_key="${2}"
  filename="${3}"

  key=$( derive_key "${private_key}" "${public_key}" )
  decrypt "${key}" "${filename}"
}
