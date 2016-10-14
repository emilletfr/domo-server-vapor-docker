
export PATH=/var/lib/jenkins/swift/usr/bin:"${PATH}"
rm -rf ./.build/debug/App.build || true
rm ./.build/debug/App.swiftmodule || true
rm ./.build/debug/App.swiftdoc || true
pkill App || true

