# Webcryptobox
WebCrypto compatible encryption with Bash and OpenSSL.

This little script shows how to do WebCrypto compatible encryption using the OpenSSL CLI.

Compatible with the [JavaScript Webcryptobox](https://github.com/jo/webcryptobox-js).

Note that `GCM` is not supported by the usual OpenSSL installation, though.

## Requirements
This script relies the following packages:

* OpenSSL
* cat, grep and xxd

Make sure they're installed on your system and globally callable.

## Configuration
Cipher selection is done via environment variables:

* `CURVE`: ecdh curve name. Can be
  - `prime256v1` (aka `P-256`)
  - `secp384r1` (aka `P-384`)
  - `secp521r1` (aka `P-521`, the default)
* `LENGTH`: AES key length in bits. Can be
  - `128`
  - `256` (default)

Eg:

```sh
$ CURVE=prime256v1 ./webcryptobox.sh generate-key-pair
$ LENGTH=128 ./webcryptobox.sh generate-key
```

## Usage
Most operations operate on `STDIN` and `STDOUT`.

### `generate-key-pair`
Generate ecdh private key and outputs it as PEM:

```sh
$ ./webcryptobox.sh generate-key-pair
-----BEGIN PRIVATE KEY-----
MIHuAgEAMBAGByqGSM49AgEGBSuBBAAjBIHWMIHTAgEBBEIAZJn5ciyGYcK2Rd1N
+hNylB7Icf3u6m8aGyMQbcIpH/hWpK7MQJ2RYyywTY6DNevgGpmGpH6wxzJBSpvn
Dv1FKxahgYkDgYYABABx7Ljh5kDyblVsVbsdCovpfp5MCpK/BZHbUbItL+4uZQDW
dW4ephE1u1bh7e6oCJIP+XDH7aH+fM4prVwhHS1BOgEZc5RwnhCBneNMqXvoeUxt
O/RAjq5lZJDIjbx7X//BM51wL3Peqgs5lbyE66Uu0FPnujdCT7/esvB907f/PNaP
oA==
-----END PRIVATE KEY-----
```

### `derive-public-key`
Given a private key via `STDIN`, outputs the corresponding public key in PEM format:

```sh
$ echo "-----BEGIN PRIVATE KEY-----
MIHuAgEAMBAGByqGSM49AgEGBSuBBAAjBIHWMIHTAgEBBEIAZJn5ciyGYcK2Rd1N
+hNylB7Icf3u6m8aGyMQbcIpH/hWpK7MQJ2RYyywTY6DNevgGpmGpH6wxzJBSpvn
Dv1FKxahgYkDgYYABABx7Ljh5kDyblVsVbsdCovpfp5MCpK/BZHbUbItL+4uZQDW
dW4ephE1u1bh7e6oCJIP+XDH7aH+fM4prVwhHS1BOgEZc5RwnhCBneNMqXvoeUxt
O/RAjq5lZJDIjbx7X//BM51wL3Peqgs5lbyE66Uu0FPnujdCT7/esvB907f/PNaP
oA==
-----END PRIVATE KEY-----
" | ./webcryptobox.sh derive-public-key
-----BEGIN PUBLIC KEY-----
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAcey44eZA8m5VbFW7HQqL6X6eTAqS
vwWR21GyLS/uLmUA1nVuHqYRNbtW4e3uqAiSD/lwx+2h/nzOKa1cIR0tQToBGXOU
cJ4QgZ3jTKl76HlMbTv0QI6uZWSQyI28e1//wTOdcC9z3qoLOZW8hOulLtBT57o3
Qk+/3rLwfdO3/zzWj6A=
-----END PUBLIC KEY-----
```

### `sha1-fingerprint`
Create a fingerprint from either public or private key as hex. This is done by hashing the DER public key data:

```sh
$ echo "-----BEGIN PUBLIC KEY-----
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAcey44eZA8m5VbFW7HQqL6X6eTAqS
vwWR21GyLS/uLmUA1nVuHqYRNbtW4e3uqAiSD/lwx+2h/nzOKa1cIR0tQToBGXOU
cJ4QgZ3jTKl76HlMbTv0QI6uZWSQyI28e1//wTOdcC9z3qoLOZW8hOulLtBT57o3
Qk+/3rLwfdO3/zzWj6A=
-----END PUBLIC KEY-----
" | ./webcryptobox.sh sha1-fingerprint
(stdin)= 7d3a3f74f210ea6324e36fdd222751965b77c6d1
```

### `sha256-fingerprint`
Similar to the `sha1-fingerprint` above, but computes a SHA-256 fingerprint:

```sh
$ echo "-----BEGIN PUBLIC KEY-----
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAcey44eZA8m5VbFW7HQqL6X6eTAqS
vwWR21GyLS/uLmUA1nVuHqYRNbtW4e3uqAiSD/lwx+2h/nzOKa1cIR0tQToBGXOU
cJ4QgZ3jTKl76HlMbTv0QI6uZWSQyI28e1//wTOdcC9z3qoLOZW8hOulLtBT57o3
Qk+/3rLwfdO3/zzWj6A=
-----END PUBLIC KEY-----
" | ./webcryptobox.sh sha256-fingerprint
(stdin)= f929e62b67a316d29f89fcb7eb4d88df00afb9d7725b66b8896c114d31f5e237
```

### `derive-key <private key> <peer key>`
Derives AES key from private and public key and output as hex string:

```sh
./webcryptobox.sh derive-key \
  my-private-key.pem \
  her-public-key.pem
0034465e46272dc8c074a9ec34372119533cd2d546d08d0e2c48a90baa44e6d2
```

### `generate-key`
Generate AES key and output as hex string:

```sh
$ ./webcryptobox.sh generate-key
6eb01eadcaf825a21a22ce6fc2587f0350c22e09a3108803005ab8eacd19a76d
```

### `generate-iv`
Generate initialization vector and output as hex string:

```sh
$ ./webcryptobox.sh generate-iv
8830eb285d6903307aa8fd0ab3b9b389
```

### `encrypt <key> <iv>`
Takes data from `STDIN` and `key` as well as `iv` as hex string from arguments, encrypts it and outputs the encrypted data as base64:

```sh
$ echo "my secret message" \
  | ./webcryptobox.sh encrypt \
    6eb01eadcaf825a21a22ce6fc2587f0350c22e09a3108803005ab8eacd19a76d \
    8830eb285d6903307aa8fd0ab3b9b389
CL0rvTbRrygW5Y5pGOKjqr885/G1FPkszuZkHlIg9mg=
```

### `decrypt <key> <iv>`
Takes encrypted data as base64 via `STDIN` and `key` as well as `iv` as hex string from arguments and decrypts the message:

```sh
$ echo "CL0rvTbRrygW5Y5pGOKjqr885/G1FPkszuZkHlIg9mg=" \
  | ./webcryptobox.sh decrypt \
    6eb01eadcaf825a21a22ce6fc2587f0350c22e09a3108803005ab8eacd19a76d \
    8830eb285d6903307aa8fd0ab3b9b389
my secret message
```

### `derive-and-encrypt <private key> <peer key> <iv>`
Derives a shared key from private key and peer key pem files and `iv` hex string from arguments and encrypts the data from `STDIN` and outputs base64:

```sh
$ echo "my secret message" \
  | ./webcryptobox.sh derive-and-encrypt \
    private-key.pem \
    her-public-key.pem \
    74dcbe5d1af04b99d389786f551e276d
FeD8WcdY2SqvS3HuxHesfkgHx4beOweNLI4Bbxy4k88=
```

### `derive-and-decrypt <private key> <peer key> <iv>`
Derives a shared key from private key and peer key pem files and `iv` hex string from arguments and decrypts the base64 encoded data from `STDIN` and outputs the message:

```sh
$ echo "FeD8WcdY2SqvS3HuxHesfkgHx4beOweNLI4Bbxy4k88=" \
  | ./webcryptobox.sh derive-and-decrypt \
    private-key.pem \
    her-public-key.pem \
    74dcbe5d1af04b99d389786f551e276d
my secret message
```


## License
This project is licensed under the Apache 2.0 License.

© 2022 Johannes J. Schmidt
