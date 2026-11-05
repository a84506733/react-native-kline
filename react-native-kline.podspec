require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-kline"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-kline
                   DESC
  s.homepage     = "https://github.com/472647301/react-native-kline"
  s.license      = "MIT"
  s.authors      = { "Byron" => "472647301@qq.com" }
  s.platforms    = { :ios => "15.1" }
  s.source       = { :git => "https://github.com/472647301/react-native-kline.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.public_header_files = "ios/RNKline.h", "ios/KLineChart/**/*.h"
  s.exclude_files = "ios/ByronKline.xcodeproj/**/*", "ios/ByronKline.xcworkspace/**/*"
  s.resources = ['ios/**/*.xib']
  s.requires_arc = true

  s.module_name = "RNKline"
  s.swift_version = "5.0"

  # The Swift compiler emits `#import "RNKline/RNKline.h"` into the generated
  # RNKline-Swift.h. CocoaPods places public headers under
  # Pods/Headers/Public/<pod name>, but the module lookup expects
  # <module name>/<module name>.h; this phase makes that file exist for any
  # consumer of the pod.
  s.script_phases = [
    {
      :name => "RNKline Module Umbrella Header",
      :script => 'set -e
mkdir -p "${PODS_ROOT}/Headers/Public/RNKline"
cp "${PODS_TARGET_SRCROOT}/ios/RNKline.h" "${PODS_ROOT}/Headers/Public/RNKline/RNKline.h"',
      :execution_position => :before_compile,
      :output_files => ["${PODS_ROOT}/Headers/Public/RNKline/RNKline.h"]
    }
  ]

  install_modules_dependencies(s)
end
