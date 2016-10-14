
export PATH=/var/lib/jenkins/swift/usr/bin:"${PATH}"
rm ./.build/debug/App.build || true
pkill App || true
swift build
BUILD_ID=dontKillMe nohup ./.build/debug/App >/dev/null 2>1 &
