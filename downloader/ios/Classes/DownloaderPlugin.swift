import Flutter
import UIKit

public class DownloaderPlugin: NSObject, FlutterPlugin {

    private var channel: FlutterMethodChannel? = nil

  public static func register(with registrar: FlutterPluginRegistrar) {
      let channel  = FlutterMethodChannel(name: "iOSDownloadChannelName", binaryMessenger: registrar.messenger())
    let instance = DownloaderPlugin()
      instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
     switch call.method {
    case "iOSStartDownload":
    let arguments = call.arguments as! [String: String]
                       let fileURL = arguments["url"]
                       let fileName = arguments["fileName"]
                       let destinationPath = arguments["destinationPath"]

                       DownloadServices.download(fileURLString: fileURL!, destinationPath: destinationPath!, fileName: fileName!) { destinationURL, fileURL, error, progress in
                           if let progress = progress {
                               self.channel?.invokeMethod("iOSDownloadProgress", arguments: ["progress": progress, "url": fileURL!.absoluteString])
                             }
                           if let _ = destinationURL {
                               self.channel?.invokeMethod("iOSDownloadCompleted", arguments: ["url": fileURL!.absoluteString])
                           }
                           if let error = error {
                               self.channel?.invokeMethod("iOSDownloadError", arguments: ["error": error.localizedDescription, "url": fileURL!.absoluteString])
                           }
                       }
    case "cancelDownloads":
      DownloadServices.cancelDownloading()
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
