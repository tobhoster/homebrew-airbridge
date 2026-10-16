# homebrew-airbridge

Homebrew tap for [airbridge](https://github.com/tobhoster/airbridge), which gives older network printers and scanners native AirScan and AirPrint for Macs, iPhones and iPads.

```sh
brew install tobhoster/airbridge/airbridge
brew services start airbridge
```

This is Linux only (Homebrew on Linux): airbridge runs on the Linux machine that sits on the same network as the printers. To use backends installed with the system's SANE, such as Brother's brscan4, point airbridge at the system library before starting the service:

```sh
export AIRBRIDGE_LIBSANE=/usr/lib64/libsane.so.1   # Fedora; Debian/Ubuntu: /usr/lib/x86_64-linux-gnu/libsane.so.1
```
