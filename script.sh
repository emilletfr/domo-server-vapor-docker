
export PATH=/var/lib/jenkins/swift/usr/bin:"${PATH}"
pkill App || true
set -e
swift build || exit 0
BUILD_ID=dontKillMe nohup ./.build/debug/App >/dev/null 2>1 &
