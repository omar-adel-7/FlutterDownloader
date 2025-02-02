import Flutter
import UIKit
import Alamofire

public class DownloaderPlugin: NSObject, FlutterPlugin {

    private var channel: FlutterMethodChannel? = nil

  public static func register(with registrar: FlutterPluginRegistrar) {
      let channel  = FlutterMethodChannel(name: "download", binaryMessenger: registrar.messenger())
    let instance = DownloaderPlugin()
      instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
     switch call.method {
    case "start":
    let arguments = call.arguments as! [String: String]
                       let fileURL = arguments["url"]
                       let fileName = arguments["fileName"]
                       let destinationPath = arguments["destinationPath"]

                       DownloadServices.download(fileURLString: fileURL!, destinationPath: destinationPath!, fileName: fileName!) { destinationURL, fileURL, error, progress in
                           if let progress = progress {
                               self.channel?.invokeMethod("resultProgress", arguments: ["progress": progress, "url": fileURL!.absoluteString])
                             }
                           if let _ = destinationURL {
                               self.channel?.invokeMethod("resultCompleted", arguments: ["url": fileURL!.absoluteString])
                           }
                           if let error = error {
                               if case AFError.explicitlyCancelled = error {
                                   self.channel?.invokeMethod("resultCanceled", arguments: ["url": fileURL!.absoluteString])
                                }
                                else{
                                    self.channel?.invokeMethod("resultError", arguments: ["error": error.localizedDescription, "url": fileURL!.absoluteString])
                                 }
                           }
                       }
    case "cancelSingle":
        let arguments = call.arguments as! [String: String]
             let fileURL = arguments["url"]
            DownloadServices.cancelDownload(fileURL!)
     case "cancelAll":
         DownloadServices.cancelDownloads()
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
