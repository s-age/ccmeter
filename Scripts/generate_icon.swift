#!/usr/bin/env swift

import AppKit

let iconSizes: [(name: String, pixels: Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024),
]

let outerPercent: CGFloat = 65
let innerPercent: CGFloat = 85

func colorForValue(_ value: CGFloat) -> CGColor {
    if value < 50 {
        return CGColor(srgbRed: 0.20, green: 0.78, blue: 0.35, alpha: 1)
    } else if value < 75 {
        return CGColor(srgbRed: 1.0, green: 0.58, blue: 0.0, alpha: 1)
    } else {
        return CGColor(srgbRed: 1.0, green: 0.23, blue: 0.19, alpha: 1)
    }
}

func render(pixels: Int) -> Data {
    let size = CGFloat(pixels)
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!

    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)!
    let cg = NSGraphicsContext.current!.cgContext

    cg.clear(CGRect(x: 0, y: 0, width: size, height: size))

    let center = CGPoint(x: size / 2, y: size / 2)
    let padding = size * 0.08
    let ringWidth = max(size * 0.20, 2)
    let outerRadius = size / 2 - padding - ringWidth / 2
    let innerDiscRadius = outerRadius - ringWidth / 2 - size * 0.01

    let bgGray = CGColor(gray: 0.5, alpha: 0.3)
    let startAngle = CGFloat.pi / 2

    cg.setStrokeColor(bgGray)
    cg.setLineWidth(ringWidth)
    cg.setLineCap(.butt)
    cg.addArc(center: center, radius: outerRadius,
              startAngle: 0, endAngle: .pi * 2, clockwise: false)
    cg.strokePath()

    let outerFrac = outerPercent / 100
    cg.setStrokeColor(colorForValue(outerPercent))
    cg.setLineWidth(ringWidth)
    cg.setLineCap(.round)
    cg.addArc(center: center, radius: outerRadius,
              startAngle: startAngle,
              endAngle: startAngle - 2 * .pi * outerFrac,
              clockwise: true)
    cg.strokePath()

    cg.setFillColor(bgGray)
    cg.addArc(center: center, radius: innerDiscRadius,
              startAngle: 0, endAngle: .pi * 2, clockwise: false)
    cg.fillPath()

    let innerFrac = innerPercent / 100
    cg.setFillColor(colorForValue(innerPercent))
    cg.move(to: center)
    cg.addArc(center: center, radius: innerDiscRadius,
              startAngle: startAngle,
              endAngle: startAngle - 2 * .pi * innerFrac,
              clockwise: true)
    cg.closePath()
    cg.fillPath()

    NSGraphicsContext.current = nil
    return rep.representation(using: .png, properties: [:])!
}

let outputDir = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "Resources/AppIcon.iconset"

let fm = FileManager.default
try fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

for (name, pixels) in iconSizes {
    let data = render(pixels: pixels)
    try data.write(to: URL(fileURLWithPath: "\(outputDir)/\(name).png"))
}

print("Generated iconset: \(outputDir)")
