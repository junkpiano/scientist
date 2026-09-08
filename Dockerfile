# Development environment for building and testing Scientist on Linux.
# CI builds on macOS; this image is for local work and reproduces the
# Swift 6 toolchain without depending on whatever is installed on the host.
FROM docker.io/library/swift:6.1

# swift-format ships with the toolchain from Swift 6.0 onward, so `swift format`
# (used by CI) works here without extra installation.
WORKDIR /workspace

CMD ["swift", "test"]
