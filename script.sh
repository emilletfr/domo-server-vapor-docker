
export PATH=/var/lib/jenkins/swift/usr/bin:"${PATH}"
rm -rf ./.build/debug || true
pkill App || true
swift build
BUILD_ID=dontKillMe nohup ./.build/debug/App >/dev/null 2>1 &
