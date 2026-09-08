#!/usr/bin/env bash
# Run a Swift command inside the project's container image.
#
#   scripts/swift-container.sh                # swift test
#   scripts/swift-container.sh swift build -v
#   scripts/swift-container.sh bash           # interactive shell
#
# Uses docker if present, otherwise podman. Build artifacts live in a named
# volume so they never collide with the host's own .build directory.
set -euo pipefail

IMAGE="scientist-dev"
VOLUME="scientist-build"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ENGINE_FLAGS=()
if command -v docker >/dev/null 2>&1; then
  ENGINE=docker
elif command -v podman >/dev/null 2>&1; then
  ENGINE=podman
  # Rootless podman without a systemd user session (e.g. WSL) cannot use the
  # systemd cgroup manager or the journald events backend.
  if [ ! -S "/run/user/$(id -u)/bus" ]; then
    ENGINE_FLAGS=(--cgroup-manager=cgroupfs --events-backend=file)
  fi
else
  echo "error: neither docker nor podman is installed." >&2
  exit 1
fi

if ! "$ENGINE" "${ENGINE_FLAGS[@]}" image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "==> building $IMAGE with $ENGINE"
  "$ENGINE" "${ENGINE_FLAGS[@]}" build -t "$IMAGE" "$ROOT"
fi

if [ "$#" -eq 0 ]; then
  set -- swift test
fi

# -t only when attached to a terminal, so CI and pipes keep working.
TTY_FLAGS=(-i)
[ -t 0 ] && TTY_FLAGS+=(-t)

exec "$ENGINE" "${ENGINE_FLAGS[@]}" run --rm "${TTY_FLAGS[@]}" \
  -v "$ROOT:/workspace:z" \
  -v "$VOLUME:/workspace/.build" \
  -w /workspace \
  "$IMAGE" \
  "$@"
