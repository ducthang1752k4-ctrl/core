#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

if [ -z "${ANDROID_HOME:-}" ] && [ -z "${ANDROID_SDK_ROOT:-}" ]; then
  echo "[ERROR] ANDROID_HOME or ANDROID_SDK_ROOT is not set."
  echo "Example:"
  echo "  export ANDROID_SDK_ROOT=\$HOME/Android/Sdk"
  echo "  export ANDROID_HOME=\$ANDROID_SDK_ROOT"
  exit 1
fi

SDK_ROOT="${ANDROID_HOME:-${ANDROID_SDK_ROOT}}"

if [ -d "${SDK_ROOT}/ndk" ]; then
  NDK_DIR="$(find "${SDK_ROOT}/ndk" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
else
  NDK_DIR=""
fi

if [ -z "${NDK_DIR}" ] || [ ! -d "${NDK_DIR}" ]; then
  echo "[ERROR] Android NDK not found in ${SDK_ROOT}/ndk"
  echo "Install Android NDK 27-29 and try again."
  exit 1
fi

echo "[INFO] SDK root: ${SDK_ROOT}"
echo "[INFO] NDK root: ${NDK_DIR}"

echo "[INFO] Running LibreOffice Android configure..."
./autogen.sh \
  --enable-dbgutil \
  --enable-werror \
  --with-distro=LibreOfficeAndroid \
  --with-android-sdk="${SDK_ROOT}" \
  --with-android-ndk="${NDK_DIR}" \
  --with-android-api-level=28

echo "[INFO] Building Word/PowerPoint Android flavor..."
cd android
./gradlew assembleWordImpressRelease

echo "[INFO] Build finished. APK output is typically under android/app/build/outputs/apk/wordImpress/release/"
