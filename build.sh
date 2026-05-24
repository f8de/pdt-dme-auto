#!/usr/bin/env bash
# Usage:
#   ./build.sh                   Build with current VERSION
#   ./build.sh patch             Bump patch then build
#   ./build.sh minor             Bump minor then build
#   ./build.sh major             Bump major then build
#   ./build.sh --no-package      Build EXE, skip deploy packaging
#   ./build.sh patch --no-package

set -e

BUMP=""
EXTRA_FLAGS=""

for arg in "$@"; do
    case "$arg" in
        patch|minor|major) BUMP="--bump $arg" ;;
        --no-package)      EXTRA_FLAGS="--no-package" ;;
    esac
done

echo ""
echo "=================================================="
echo "  DME Auto  |  Build"
echo "=================================================="
echo "  Started: $(date)"
echo ""

python build.py $BUMP $EXTRA_FLAGS
EXIT_CODE=$?

echo ""
echo "=================================================="

if [ $EXIT_CODE -ne 0 ]; then
    echo "  [FAILED]  Exit code: $EXIT_CODE"
    echo "=================================================="
    echo ""
    exit $EXIT_CODE
fi

if [ ! -f "dist/dme-auto.exe" ]; then
    echo "  [FAILED]  dist/dme-auto.exe not found after build"
    echo "=================================================="
    echo ""
    exit 1
fi

EXE_SIZE=$(stat -c%s "dist/dme-auto.exe" 2>/dev/null || stat -f%z "dist/dme-auto.exe")
EXE_MB=$((EXE_SIZE / 1048576))
echo "  [OK]  dist/dme-auto.exe  (${EXE_MB} MB)"

if [ -f "deploy/dme-auto.exe" ]; then
    DEPLOY_SIZE=$(stat -c%s "deploy/dme-auto.exe" 2>/dev/null || stat -f%z "deploy/dme-auto.exe")
    DEPLOY_MB=$((DEPLOY_SIZE / 1048576))
    echo "  [OK]  deploy/dme-auto.exe  (${DEPLOY_MB} MB)"
fi

echo "  Finished: $(date)"
echo "=================================================="
echo ""
