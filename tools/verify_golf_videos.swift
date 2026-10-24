import Foundation
import AVFoundation
import ImageIO
import UniformTypeIdentifiers

let folder = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.fileSizeKey]).filter { $0.pathExtension == "mp4" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
for file in files {
  let asset = AVURLAsset(url: file)
  let duration = try await asset.load(.duration).seconds
  let tracks = try await asset.loadTracks(withMediaType: .video)
  let size = try await tracks[0].load(.naturalSize)
  let bytes = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
  let gen = AVAssetImageGenerator(asset: asset); gen.appliesPreferredTrackTransform = true
  let image = try gen.copyCGImage(at: CMTime(seconds: 4.6, preferredTimescale: 600), actualTime: nil)
  let png = folder.appendingPathComponent(file.deletingPathExtension().lastPathComponent + "_preview.png")
  let dest = CGImageDestinationCreateWithURL(png as CFURL, UTType.png.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(dest, image, nil); CGImageDestinationFinalize(dest)
  print("\(file.lastPathComponent) | \(String(format:"%.2f",duration))s | \(Int(size.width))x\(Int(size.height)) | \(bytes) bytes")
}
