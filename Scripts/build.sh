#!/bin/bash
set -euo pipefail

PRODUCT="CCMeter"
BUILD_DIR=".build/release"
APP_BUNDLE="${PRODUCT}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS="${CONTENTS}/MacOS"
RESOURCES="${CONTENTS}/Resources"
ENTITLEMENTS="Resources/CCMeter.entitlements"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Build ${PRODUCT}.app from Swift Package

Options:
  --clean       Clean build artifacts before building
  --test        Run tests before building
  --install     Install to /Applications after building
  --skip-icon   Skip icon generation
  --no-sign     Skip code signing
  -h, --help    Show this help
EOF
}

DO_CLEAN=false
DO_TEST=false
DO_INSTALL=false
SKIP_ICON=false
NO_SIGN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --clean)     DO_CLEAN=true;  shift ;;
        --test)      DO_TEST=true;   shift ;;
        --install)   DO_INSTALL=true; shift ;;
        --skip-icon) SKIP_ICON=true; shift ;;
        --no-sign)   NO_SIGN=true; shift ;;
        -h|--help)   usage; exit 0 ;;
        *) error "Unknown option: $1"; usage; exit 1 ;;
    esac
done

cd "${PROJECT_DIR}"

if ${DO_CLEAN}; then
    info "Cleaning build artifacts..."
    swift package clean
    rm -rf "${APP_BUNDLE}"
fi

if ${DO_TEST}; then
    info "Running tests..."
    swift test
fi

info "Building ${PRODUCT} (release)..."
swift build -c release

info "Assembling ${APP_BUNDLE}..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS}" "${RESOURCES}"
cp "${BUILD_DIR}/${PRODUCT}" "${MACOS}/"
cp Resources/Info.plist "${CONTENTS}/"

if ! ${SKIP_ICON}; then
    ICONSET_DIR="${RESOURCES}/AppIcon.iconset"
    ICNS_FILE="${RESOURCES}/AppIcon.icns"
    info "Generating app icon..."
    if swift "${SCRIPT_DIR}/generate_icon.swift" "${ICONSET_DIR}"; then
        if iconutil -c icns "${ICONSET_DIR}" -o "${ICNS_FILE}"; then
            rm -rf "${ICONSET_DIR}"
            info "Icon created: AppIcon.icns"
        else
            warn "iconutil failed; app will use default icon"
            rm -rf "${ICONSET_DIR}"
        fi
    else
        warn "Icon generation failed; app will use default icon"
    fi
fi

if ! ${NO_SIGN}; then
    info "Code signing ${APP_BUNDLE}..."
    IDENTITY=$(security find-identity -v -p codesigning | head -1 | sed -E 's/.*"(.*)"/\1/')
    if [[ -n "${IDENTITY}" && "${IDENTITY}" != *"0 valid"* ]]; then
        codesign --force --sign "${IDENTITY}" \
            --entitlements "${ENTITLEMENTS}" \
            --options runtime \
            "${APP_BUNDLE}"
        info "Signed with: ${IDENTITY}"
    else
        warn "No signing identity found; using ad-hoc signature"
        codesign --force --sign - \
            --entitlements "${ENTITLEMENTS}" \
            "${APP_BUNDLE}"
        info "Signed with ad-hoc identity"
    fi
fi

if ${DO_INSTALL}; then
    info "Installing to /Applications..."
    cp -R "${APP_BUNDLE}" /Applications/
    info "Installed to /Applications/${APP_BUNDLE}"
fi

info "Built ${APP_BUNDLE}"
