# Webcryptobox
WebCrypto compatible encryption with Bash and OpenSSL.

This package implements the [Webcryptobox](https://github.com/jo/webcryptobox) encryption API.

Compatible packages:
* [Webcryptobox JavaScript](https://github.com/jo/webcryptobox-js)
* [Webcryptobox Rust](https://github.com/jo/webcryptobox-rs)

There is also a CLI tool: [wcb.sh](https://github.com/jo/wcb-sh)


## Requirements
This script relies the following packages:

* OpenSSL
* cat, grep and xxd

Make sure they're installed on your system and globally callable.


## Usage
Include the library in your script:

```
. webcryptobox.sh
```


## API
The Bash library provides the following functions.


## Symmetric Encryption
Functions for handling symmetric AES-256-CBC encryption.

#### `key`
Generate AES key.

#### `encrypt KEY FILENAME`
Encrypt file contents with AES key.

#### `decrypt KEY FILENAME`
Decrypt file contents with AES key.


## Asymmetric Encryption
Functions for handling asymmetric ECDH P-521 AES-256-CBC encryption.

#### `private_key`
Generate a private EC key PEM.

#### `public_key FILENAME`
Given a private EC key PEM, output the corresponding public EC key PEM.

#### `fingerprint FILENAME HASHFUNCTION`
Calculate a fingerprint of the public key from either a private key or a public key PEM. Hashfunction can either be `sha1` or `sha256`.

#### `derive_key PRIVATE_KEY PUBLIC_KEY`
Derive an AES key from private and public key pair provides as PEMs.

#### `derive_password PRIVATE_KEY PUBLIC_KEY LENGTH`
Derive a password from private and public key pair provides as PEMs with given length. Length must be less than 32 bytes.

#### `encrypt_private_key PASSPHRASE FILENAME`
Encrypts a private key PEM with a passphrase.

#### `decrypt_private_key PASSPHRASE FILENAME`
Decrypts an encrypted private key PEM with a passphrase.

#### `encrypt_private_key_to PRIVATE_KEY PUBLIC_KEY FILENAME`
Encrypts a private key PEM for private and public key pair given as PEMs.

#### `decrypt_private_key_from PRIVATE_KEY PUBLIC_KEY FILENAME`
Decrypts an encrypted private key PEM for private and public key pair given as PEMs.

#### `encrypt_to PRIVATE_KEY PUBLIC_KEY FILENAME`
Encrypts a message for rivate and public key pair given as PEMs.

#### `decrypt_from PRIVATE_KEY PUBLIC_KEY FILENAME`
Decrypts an encrypted message for private and public key pair given as PEMs.


## License
This project is licensed under the Apache 2.0 License.

© 2022 Johannes J. Schmidt
