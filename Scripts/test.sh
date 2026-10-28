#!/usr/bin/env bash
set -euo pipefail

# 调用方显式指定可用的 iOS Simulator，避免依赖某一机器的设备名称。
if [[ $# -ne 1 ]]; then
    echo "用法: bash Scripts/test.sh 'platform=iOS Simulator,id=模拟器UDID'" >&2
    exit 64
fi
if [[ "$1" != platform=iOS\ Simulator,* ]]; then
    echo "请指定 iOS Simulator destination。" >&2
    exit 64
fi

cd "$(dirname "$0")/.."
grid_test_output=$(mktemp -d "${TMPDIR:-/tmp}/UIKitGridLayouts-tests.XXXXXX")
echo "测试结果: $grid_test_output/Tests.xcresult"
xcodebuild -scheme UIKitGridLayouts \
    -destination "$1" \
    -parallel-testing-enabled NO \
    -resultBundlePath "$grid_test_output/Tests.xcresult" \
    test
