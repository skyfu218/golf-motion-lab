import Foundation
import AVFoundation
import CoreGraphics
import CoreText

let width = 1280
let height = 720
let fps: Int32 = 30
let duration = 8.0

struct V { var x: Double; var y: Double }
func +(a: V, b: V) -> V { V(x: a.x+b.x, y: a.y+b.y) }
func *(a: V, b: Double) -> V { V(x: a.x*b, y: a.y*b) }
func mix(_ a: Double, _ b: Double, _ t: Double) -> Double { a+(b-a)*t }
func mix(_ a: V, _ b: V, _ t: Double) -> V { V(x: mix(a.x,b.x,t), y: mix(a.y,b.y,t)) }
func ease(_ t: Double) -> Double { let u = max(0,min(1,t)); return u*u*(3-2*u) }

struct Key { let t, hx, hy, club, tilt, shift, knee: Double; let phase: String }
struct Shot {
  let slug, title, subtitle: String
  let keys: [Key]
  let ballX: Double
  let flight: Double
}

let shots = [
  Shot(slug:"driver", title:"Driver 開球木桿", subtitle:"寬站距・球位靠前・完整轉體", keys:[
    Key(t:0,hx:710,hy:425,club:75,tilt:4,shift:0,knee:10,phase:"ADDRESS  瞄球"),
    Key(t:1,hx:710,hy:425,club:75,tilt:4,shift:0,knee:10,phase:"ADDRESS  穩定準備"),
    Key(t:3,hx:535,hy:245,club:210,tilt:-18,shift:-22,knee:13,phase:"BACKSWING  完整上桿"),
    Key(t:3.55,hx:570,hy:285,club:195,tilt:-12,shift:-10,knee:16,phase:"TRANSITION  轉換"),
    Key(t:4.45,hx:705,hy:432,club:72,tilt:8,shift:22,knee:8,phase:"IMPACT  擊球"),
    Key(t:5.7,hx:800,hy:245,club:-30,tilt:18,shift:35,knee:5,phase:"FOLLOW-THROUGH  送桿"),
    Key(t:8,hx:785,hy:230,club:-38,tilt:16,shift:30,knee:4,phase:"FINISH  平衡收桿")], ballX:748, flight:1.0),
  Shot(slug:"seven_iron", title:"7 號鐵桿", subtitle:"中等站距・球位略靠前・先球後地", keys:[
    Key(t:0,hx:690,hy:430,club:78,tilt:3,shift:0,knee:9,phase:"ADDRESS  瞄球"),
    Key(t:1,hx:690,hy:430,club:78,tilt:3,shift:0,knee:9,phase:"ADDRESS  穩定準備"),
    Key(t:2.8,hx:550,hy:275,club:205,tilt:-15,shift:-16,knee:12,phase:"BACKSWING  上桿"),
    Key(t:3.45,hx:590,hy:315,club:188,tilt:-9,shift:-5,knee:15,phase:"TRANSITION  轉換"),
    Key(t:4.35,hx:690,hy:438,club:79,tilt:7,shift:18,knee:8,phase:"IMPACT  手位領先"),
    Key(t:5.6,hx:785,hy:270,club:-25,tilt:16,shift:28,knee:5,phase:"FOLLOW-THROUGH  延伸"),
    Key(t:8,hx:770,hy:250,club:-32,tilt:14,shift:25,knee:4,phase:"FINISH  平衡收桿")], ballX:718, flight:0.78),
  Shot(slug:"pitch", title:"Pitch 劈桿", subtitle:"窄站距・短上桿・控制落點", keys:[
    Key(t:0,hx:680,hy:438,club:80,tilt:2,shift:5,knee:7,phase:"ADDRESS  重心微靠前"),
    Key(t:1.3,hx:680,hy:438,club:80,tilt:2,shift:5,knee:7,phase:"ADDRESS  手腕自然"),
    Key(t:3,hx:610,hy:345,club:160,tilt:-7,shift:0,knee:8,phase:"BACKSWING  短上桿"),
    Key(t:3.7,hx:635,hy:370,club:145,tilt:-4,shift:6,knee:9,phase:"TRANSITION  平順轉換"),
    Key(t:4.5,hx:680,hy:443,club:80,tilt:5,shift:14,knee:6,phase:"IMPACT  維持節奏"),
    Key(t:5.7,hx:740,hy:345,club:5,tilt:9,shift:20,knee:5,phase:"FOLLOW-THROUGH  對稱送桿"),
    Key(t:8,hx:735,hy:340,club:0,tilt:8,shift:18,knee:5,phase:"FINISH  穩定停住")], ballX:704, flight:0.5),
  Shot(slug:"putter", title:"推桿", subtitle:"肩膀帶動・手腕穩定・小幅鐘擺", keys:[
    Key(t:0,hx:675,hy:455,club:88,tilt:0,shift:0,knee:6,phase:"ADDRESS  桿面對正"),
    Key(t:1.4,hx:675,hy:455,club:88,tilt:0,shift:0,knee:6,phase:"ADDRESS  眼睛在球線上"),
    Key(t:3.1,hx:635,hy:450,club:98,tilt:-3,shift:0,knee:6,phase:"BACKSTROKE  小幅後擺"),
    Key(t:3.8,hx:650,hy:452,club:94,tilt:-2,shift:0,knee:6,phase:"TRANSITION  不急加速"),
    Key(t:4.55,hx:680,hy:455,club:87,tilt:1,shift:0,knee:6,phase:"IMPACT  桿面方正"),
    Key(t:5.8,hx:725,hy:448,club:78,tilt:4,shift:0,knee:6,phase:"FOLLOW-THROUGH  穿過球位"),
    Key(t:8,hx:720,hy:449,club:79,tilt:3,shift:0,knee:6,phase:"HOLD  保持桿面")], ballX:704, flight:0.08)
]

func state(_ s: Shot, _ t: Double) -> Key {
  for i in 0..<(s.keys.count-1) where t <= s.keys[i+1].t {
    let a=s.keys[i], b=s.keys[i+1], u=ease((t-a.t)/(b.t-a.t))
    return Key(t:t,hx:mix(a.hx,b.hx,u),hy:mix(a.hy,b.hy,u),club:mix(a.club,b.club,u),tilt:mix(a.tilt,b.tilt,u),shift:mix(a.shift,b.shift,u),knee:mix(a.knee,b.knee,u),phase:u < 0.55 ? a.phase : b.phase)
  }
  return s.keys.last!
}

func line(_ c: CGContext, _ a: V, _ b: V, _ w: CGFloat, _ color: CGColor) {
  c.setStrokeColor(color); c.setLineWidth(w); c.setLineCap(.round); c.move(to:CGPoint(x:a.x,y:Double(height)-a.y)); c.addLine(to:CGPoint(x:b.x,y:Double(height)-b.y)); c.strokePath()
}
func dot(_ c: CGContext, _ p: V, _ r: Double, _ color: CGColor) { c.setFillColor(color); c.fillEllipse(in:CGRect(x:p.x-r,y:Double(height)-p.y-r,width:r*2,height:r*2)) }
func text(_ c: CGContext, _ s: String, _ x: Double, _ y: Double, _ size: Double, _ color: CGColor, bold: Bool=false) {
  let font=CTFontCreateWithName((bold ? "PingFangTC-Semibold" : "PingFangTC-Regular") as CFString,size,nil)
  let attrs:[NSAttributedString.Key:Any]=[NSAttributedString.Key(kCTFontAttributeName as String):font,NSAttributedString.Key(kCTForegroundColorAttributeName as String):color]
  let ln=CTLineCreateWithAttributedString(NSAttributedString(string:s,attributes:attrs)); c.textPosition=CGPoint(x:x,y:y); CTLineDraw(ln,c)
}

func draw(_ c: CGContext, _ shot: Shot, _ t: Double) {
  let navy=CGColor(red:0.035,green:0.075,blue:0.12,alpha:1), green=CGColor(red:0.16,green:0.73,blue:0.48,alpha:1)
  let white=CGColor(gray:0.96,alpha:1), muted=CGColor(red:0.55,green:0.64,blue:0.70,alpha:1), cyan=CGColor(red:0.22,green:0.79,blue:0.92,alpha:1)
  c.setFillColor(navy); c.fill(CGRect(x:0,y:0,width:width,height:height))
  c.setFillColor(CGColor(red:0.05,green:0.12,blue:0.16,alpha:1)); c.fill(CGRect(x:0,y:0,width:width,height:150))
  c.setStrokeColor(CGColor(red:0.12,green:0.30,blue:0.28,alpha:1)); c.setLineWidth(2)
  for x in stride(from:80,through:1200,by:80) { c.move(to:CGPoint(x:x,y:150)); c.addLine(to:CGPoint(x:x+45,y:0)) }; c.strokePath()
  text(c,shot.title,56,640,34,white,bold:true); text(c,shot.subtitle,56,605,20,muted); text(c,"動作示意｜非個人化技術診斷",930,650,15,muted)
  let k=state(shot,t), hip=V(x:640+k.shift,y:420), torso=V(x:0,y:-145)
  let rad=k.tilt*Double.pi/180, neck=hip+V(x:sin(rad)*145,y:-cos(rad)*145), head=neck+V(x:0,y:-38)
  let sw=68.0, shoulderL=neck+V(x:-cos(rad)*sw,y:-sin(rad)*sw), shoulderR=neck+V(x:cos(rad)*sw,y:sin(rad)*sw)
  let hand=V(x:k.hx,y:k.hy), elbowL=mix(shoulderL,hand,0.52)+V(x:-24,y:18), elbowR=mix(shoulderR,hand,0.5)+V(x:22,y:12)
  let ankleL=V(x:shot.slug=="driver" ? 540:570,y:565), ankleR=V(x:shot.slug=="driver" ? 740:710,y:565)
  let kneeL=mix(hip,ankleL,0.55)+V(x:-18,y:k.knee), kneeR=mix(hip,ankleR,0.55)+V(x:18,y:k.knee)
  line(c,hip,neck,18,white); line(c,shoulderL,shoulderR,14,white); dot(c,head,28,white)
  line(c,shoulderL,elbowL,13,cyan); line(c,elbowL,hand,12,cyan); line(c,shoulderR,elbowR,13,green); line(c,elbowR,hand,12,green)
  line(c,hip,kneeL,17,white); line(c,kneeL,ankleL,15,white); line(c,hip,kneeR,17,white); line(c,kneeR,ankleR,15,white); line(c,V(x:ankleL.x-22,y:566),V(x:ankleL.x+28,y:566),10,white); line(c,V(x:ankleR.x-22,y:566),V(x:ankleR.x+28,y:566),10,white)
  dot(c,hip,12,green); dot(c,shoulderL,8,green); dot(c,shoulderR,8,green); dot(c,hand,9,cyan)
  let ca=k.club*Double.pi/180, clubEnd=hand+V(x:cos(ca)*190,y:sin(ca)*190)
  line(c,hand,clubEnd,7,CGColor(red:0.82,green:0.88,blue:0.90,alpha:1)); let perp=V(x:-sin(ca)*18,y:cos(ca)*18); line(c,clubEnd+perp*(-0.35),clubEnd+perp,12,green)
  let ball=V(x:shot.ballX,y:557); dot(c,ball,9,white)
  if t>4.45 {
    let u=min(1,(t-4.45)/2.2), dist=shot.flight*420*u
    let moving=V(x:shot.ballX+dist,y:557-shot.flight*150*sin(Double.pi*u))
    c.setStrokeColor(CGColor(red:0.22,green:0.79,blue:0.92,alpha:0.35)); c.setLineWidth(3); c.move(to:CGPoint(x:ball.x,y:Double(height)-ball.y)); c.addQuadCurve(to:CGPoint(x:moving.x,y:Double(height)-moving.y),control:CGPoint(x:shot.ballX+dist/2,y:Double(height)-(557-shot.flight*180))); c.strokePath(); dot(c,moving,8,white)
  }
  c.setFillColor(CGColor(red:0.06,green:0.16,blue:0.21,alpha:0.92)); c.fill(CGRect(x:45,y:45,width:430,height:70)); text(c,k.phase,70,72,24,green,bold:true)
  let progress=min(1,max(0,t/duration)); c.setFillColor(CGColor(red:0.15,green:0.24,blue:0.29,alpha:1)); c.fill(CGRect(x:70,y:35,width:1140,height:5)); c.setFillColor(green); c.fill(CGRect(x:70,y:35,width:1140*progress,height:5))
}

func makeVideo(_ shot: Shot, outDir: URL) throws {
  let url=outDir.appendingPathComponent("golf_\(shot.slug)_motion.mp4"); try? FileManager.default.removeItem(at:url)
  let writer=try AVAssetWriter(outputURL:url,fileType:.mp4)
  let settings:[String:Any]=[AVVideoCodecKey:AVVideoCodecType.h264,AVVideoWidthKey:width,AVVideoHeightKey:height,AVVideoCompressionPropertiesKey:[AVVideoAverageBitRateKey:3_200_000,AVVideoProfileLevelKey:AVVideoProfileLevelH264HighAutoLevel]]
  let input=AVAssetWriterInput(mediaType:.video,outputSettings:settings); input.expectsMediaDataInRealTime=false
  let attrs:[String:Any]=[kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA,kCVPixelBufferWidthKey as String:width,kCVPixelBufferHeightKey as String:height]
  let adaptor=AVAssetWriterInputPixelBufferAdaptor(assetWriterInput:input,sourcePixelBufferAttributes:attrs); writer.add(input); writer.startWriting(); writer.startSession(atSourceTime:.zero)
  let frames=Int(duration*Double(fps))
  for i in 0..<frames {
    while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval:0.002) }
    var px:CVPixelBuffer?; CVPixelBufferCreate(nil,width,height,kCVPixelFormatType_32BGRA,attrs as CFDictionary,&px); let p=px!
    CVPixelBufferLockBaseAddress(p,[])
    let ctx=CGContext(data:CVPixelBufferGetBaseAddress(p),width:width,height:height,bitsPerComponent:8,bytesPerRow:CVPixelBufferGetBytesPerRow(p),space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.noneSkipFirst.rawValue|CGBitmapInfo.byteOrder32Little.rawValue)!
    draw(ctx,shot,Double(i)/Double(fps)); CVPixelBufferUnlockBaseAddress(p,[])
    adaptor.append(p,withPresentationTime:CMTime(value:Int64(i),timescale:fps))
  }
  input.markAsFinished(); let sem=DispatchSemaphore(value:0); writer.finishWriting { sem.signal() }; sem.wait()
  if writer.status != .completed { throw writer.error ?? NSError(domain:"GolfVideo",code:1) }
  print(url.path)
}

let out=URL(fileURLWithPath:CommandLine.arguments.count>1 ? CommandLine.arguments[1] : "輸出/高爾夫四種擊球示意影片",isDirectory:true)
try FileManager.default.createDirectory(at:out,withIntermediateDirectories:true)
for shot in shots { try makeVideo(shot,outDir:out) }
