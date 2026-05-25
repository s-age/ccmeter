cask "ccmeter" do
  version "1.0.0"
  sha256 "PLACEHOLDER"

  url "https://github.com/s-age/ccmeter/releases/download/v#{version}/CCMeter-#{version}.dmg"
  name "CCMeter"
  desc "Menu bar app that displays Claude Code usage"
  homepage "https://github.com/s-age/ccmeter"

  depends_on macos: ">= :sonoma"

  app "CCMeter.app"

  zap trash: [
    "~/Library/Preferences/com.ccmeter.app.plist",
    "~/Library/Application Support/CCMeter",
  ]
end
