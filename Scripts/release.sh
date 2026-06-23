#!/bin/bash
set -euo pipefail

PRODUCT="CCMeter"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_BUNDLE="${PRODUCT}.app"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }
die()   { error "$1"; exit 1; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Build, sign, notarize, and publish a GitHub release for ${PRODUCT}.

Options:
  --version X.Y.Z   Version string (default: reads CFBundleShortVersionString from Info.plist)
  --profile NAME    Keychain notarization profile name
  --dry-run         Build and sign, but skip notarization and GitHub release
  -h, --help        Show this help

Notarization credentials — provide one of:
  --profile NAME     Keychain profile (created once with 'xcrun notarytool store-credentials')
  Env vars:          NOTARIZE_KEY_ID, NOTARIZE_ISSUER_ID, NOTARIZE_KEY_PATH

First-time setup (Apple ID + App-specific password — recommended for individual accounts):
  xcrun notarytool store-credentials ccmeter-notarize \\
    --apple-id YOUR_APPLE_ID@example.com \\
    --password xxxx-xxxx-xxxx-xxxx \\
    --team-id XXXXXXXXXX
  App-specific password: https://appleid.apple.com → App-Specific Passwords
  Team ID: https://developer.apple.com/account → Membership details
  Then run:
    ./Scripts/release.sh --profile ccmeter-notarize

First-time setup (App Store Connect API key — for team accounts):
  xcrun notarytool store-credentials ccmeter-notarize \\
    --key /path/to/AuthKey_XXXXXXXX.p8 \\
    --key-id XXXXXXXX \\
    --issuer xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  Then run:
    ./Scripts/release.sh --profile ccmeter-notarize
EOF
}

VERSION=""
NOTARIZE_PROFILE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)  VERSION="$2"; shift 2 ;;
        --profile)  NOTARIZE_PROFILE="$2"; shift 2 ;;
        --dry-run)  DRY_RUN=true; shift ;;
        -h|--help)  usage; exit 0 ;;
        *) error "Unknown option: $1"; usage; exit 1 ;;
    esac
done

cd "${PROJECT_DIR}"

# Resolve version from Info.plist if not provided
if [[ -z "${VERSION}" ]]; then
    VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" \
        "${PROJECT_DIR}/Resources/Info.plist")
    info "Version: ${VERSION} (from Info.plist)"
fi

DMG_NAME="${PRODUCT}-${VERSION}.dmg"
DMG_PATH="${PROJECT_DIR}/${DMG_NAME}"

# Require Developer ID Application certificate for notarization
IDENTITY=$(security find-identity -v -p codesigning | \
    grep "Developer ID Application" | head -1 | sed -E 's/.*"(.*)"/\1/')
[[ -n "${IDENTITY}" ]] || \
    die "No 'Developer ID Application' certificate found. Open Keychain Access and check your certificates."
info "Signing identity: ${IDENTITY}"

# Build (release, no signing — we sign below with the correct options)
info "Building ${PRODUCT}..."
"${SCRIPT_DIR}/build.sh" --clean --no-sign

# Sign with Developer ID + Hardened Runtime + secure timestamp
info "Code signing with Hardened Runtime..."
codesign --force --sign "${IDENTITY}" \
    --entitlements "${PROJECT_DIR}/Resources/CCMeter.entitlements" \
    --options runtime \
    --timestamp \
    "${PROJECT_DIR}/${APP_BUNDLE}"

codesign --verify --deep --strict --verbose=2 "${PROJECT_DIR}/${APP_BUNDLE}"
info "Signature verified"

# Create DMG
info "Creating ${DMG_NAME}..."
rm -f "${DMG_PATH}"
STAGING=$(mktemp -d)
cp -R "${PROJECT_DIR}/${APP_BUNDLE}" "${STAGING}/"
ln -s /Applications "${STAGING}/Applications"

hdiutil create \
    -volname "${PRODUCT} ${VERSION}" \
    -srcfolder "${STAGING}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"
rm -rf "${STAGING}"
info "Created ${DMG_PATH}"

if ${DRY_RUN}; then
    SHA256=$(shasum -a 256 "${DMG_PATH}" | awk '{print $1}')
    warn "DRY RUN — skipped notarization and GitHub release"
    info "DMG:    ${DMG_PATH}"
    info "SHA256: ${SHA256}"
    exit 0
fi

# Notarize
info "Submitting for notarization (this may take a few minutes)..."
NOTARIZE_ARGS=("${DMG_PATH}" --wait)

if [[ -n "${NOTARIZE_PROFILE}" ]]; then
    NOTARIZE_ARGS+=(--keychain-profile "${NOTARIZE_PROFILE}")
elif [[ -n "${NOTARIZE_KEY_ID:-}" && -n "${NOTARIZE_ISSUER_ID:-}" && -n "${NOTARIZE_KEY_PATH:-}" ]]; then
    NOTARIZE_ARGS+=(
        --key "${NOTARIZE_KEY_PATH}"
        --key-id "${NOTARIZE_KEY_ID}"
        --issuer "${NOTARIZE_ISSUER_ID}"
    )
else
    die "Provide --profile or set NOTARIZE_KEY_ID / NOTARIZE_ISSUER_ID / NOTARIZE_KEY_PATH"
fi

xcrun notarytool submit "${NOTARIZE_ARGS[@]}"

# Staple ticket into DMG
info "Stapling notarization ticket..."
xcrun stapler staple "${DMG_PATH}"

# Verify Gatekeeper accepts the app inside the DMG
# (DMGs themselves don't carry a primary signature; check the .app)
VERIFY_STAGING=$(mktemp -d)
hdiutil attach "${DMG_PATH}" -mountpoint "${VERIFY_STAGING}/mnt" -quiet -nobrowse
spctl --assess --type open --context context:primary-signature -v \
    "${VERIFY_STAGING}/mnt/${APP_BUNDLE}" || true
hdiutil detach "${VERIFY_STAGING}/mnt" -quiet
rm -rf "${VERIFY_STAGING}"
info "Notarization confirmed by Gatekeeper"

# SHA256 for Homebrew Cask
SHA256=$(shasum -a 256 "${DMG_PATH}" | awk '{print $1}')
info "SHA256: ${SHA256}"

# Publish GitHub Release
TAG="v${VERSION}"
info "Creating GitHub Release ${TAG}..."
gh release create "${TAG}" \
    --title "${PRODUCT} ${VERSION}" \
    --generate-notes \
    "${DMG_PATH}"

DOWNLOAD_URL="https://github.com/s-age/ccmeter/releases/download/${TAG}/${DMG_NAME}"
info "Release published: ${DOWNLOAD_URL}"

# Print values needed to update the Homebrew Cask formula
cat <<EOF

Update Casks/ccmeter.rb in the homebrew-ccmeter tap:
  version "${VERSION}"
  sha256 "${SHA256}"
  url "${DOWNLOAD_URL}"

Or run:
  cd ../homebrew-ccmeter
  sed -i '' \\
    -e 's/version ".*"/version "${VERSION}"/' \\
    -e 's/sha256 ".*"/sha256 "${SHA256}"/' \\
    -e 's|url ".*"|url "${DOWNLOAD_URL}"|' \\
    Casks/ccmeter.rb
  git commit -am "Update ccmeter to ${VERSION}" && git push
EOF

info "Done!"
