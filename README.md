# StegoVault Pro

A cross-platform steganography app that hides files inside images, audio, video, and documents — invisibly and optionally password-protected.

## About

Hide any file inside a cover file without visibly changing it. Images use LSB (Least Significant Bit) encoding directly on pixel data; audio, video, and documents use payload-appending with magic-byte markers. Every hidden file can be optionally encrypted with a password before embedding, and extracted later only with the correct password.

## Skills

`LSB bit manipulation`, `SHA-256` key derivation, `XOR` encryption, byte-level binary parsing, `BytesBuilder`, generic config-driven screens (strategy pattern), `share_plus`

## Tech

- **Language:** Dart
- **Framework:** Flutter
- **Packages:** `image`, `crypto`, `file_picker`, `path_provider`

## Preview

🔗 [View on Telegram](https://t.me/sr_cpp_flutter_projects)