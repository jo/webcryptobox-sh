# Changelog

# v3.0.0 - Binary default
Don't base64 encode encrypted messages by default.

**Breaking change:**
* `encrypt` and `encrypt_to` do not encode its output as base64 anymore
* `decrypt` and `decrypt_from` do not expect its inputs base64 encoded anymore

To encode it as base64, pipe the result to either `base64` or `openssl base64`.


## v2.0.0
Getting mature. This is a library now. CLI is here: [wcb.sh](https://github.com/jo/wcb-sh).

Includes breaking changes:
* no configurable ciphers anymore. Cipher is set to ECDH P-521 AES 256 GCM.
* include iv in ciphertext

New Features:
* encrypt and decrypt private key PEMs
* derive password from key pair


## v1.0.0
Initial version.
