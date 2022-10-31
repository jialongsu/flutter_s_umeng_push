import Flutter
import UIKit

public class SwiftFlutterSUmengPushPlugin: NSObject, FlutterPlugin {
  static var channel: FlutterMethodChannel?;
    
  var logEnabled = false; // 是否开启日志
  var notificationOnForeground = true; // 设置App处于前台时是否显示通知， 默认为true
  var initNotificationUserInfo: String?;

  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "flutter_s_umeng_push", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterSUmengPushPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel!)
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "umInit":
          umInit(call: call, result: result);
          break;
      case "register":
          register(result: result);
          break;
      case "getDeviceToken":
          getDeviceToken(call: call, result: result);
          break;
      case "enable":
         setPushEnable(call: call, result: result);
         break;
      case "setAlias":
          setAlias(call: call, result: result);
          break;
      case "removeAlias":
          removeAlias(call: call, result: result);
          break;
      case "addTag":
          addTags(call: call, result: result);
          break;
      case "removeTag":
          removeTags(call: call, result: result);
          break;
      case "getTags":
          getTags(call: call, result: result);
          break;
      default:
          result(FlutterMethodNotImplemented);
    }
  }
    
    public func umInit(call: FlutterMethodCall, result: @escaping FlutterResult) {
      let params = call.arguments as! Dictionary<String, Any>;
      let appKey = params["appKey"] as! String;
      let channel = params["channel"] as! String;
      logEnabled = params["logEnabled"] as! Bool;
      notificationOnForeground = params["notificationOnForeground"] as! Bool;
      UMConfigure.initWithAppkey(appKey, channel: channel);
      UMConfigure.setLogEnabled(logEnabled);
      result(["code": "200", "msg": "um init success"]);
    }
    
    public func register(result: @escaping FlutterResult) {
      // Push组件基本功能配置
      let entity = UMessageRegisterEntity.init();
      //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
      entity.types =  Int(UMessageAuthorizationOptions.badge.rawValue | UMessageAuthorizationOptions.sound.rawValue | UMessageAuthorizationOptions.alert.rawValue)
      UNUserNotificationCenter.current().delegate = self
      UMessage.registerForRemoteNotifications(launchOptions: nil, entity: entity) { granted, error in
        if granted {
          //点击允许
          //result(@(YES));
        } else {
          //点击不允许
          //result(@(NO));
        }
      }
      // 点击推送启动App，回调监听事件
      if(SwiftFlutterSUmengPushPlugin.channel != nil) {
          SwiftFlutterSUmengPushPlugin.channel?.invokeMethod("onOpenNotification", arguments: initNotificationUserInfo)
      }
      result(["code": "200", "msg": "um register success"]);
    }
    
    public func getDeviceToken(call: FlutterMethodCall, result: @escaping FlutterResult) {
      let deviceToken = UserDefaults.standard.object(forKey: "kUMessageUserDefaultKeyForDeviceToken") as? Data
      var resultStr: String? = nil
      if deviceToken != nil {
        resultStr = deviceToken!.map { String(format: "%02.2hhx", $0) }.joined()
      }else {
        resultStr = "";
      }
      result(resultStr);
    }
    
    public func setPushEnable(call: FlutterMethodCall, result: @escaping FlutterResult) {
      let enable = call.arguments as! Bool;
      if(!enable) {
        UMessage.unregisterForRemoteNotifications();
      }else {
        UMessage.registerForRemoteNotifications(entity: nil)
      }
    }
    
    public func setAlias(call: FlutterMethodCall, result: @escaping FlutterResult) {
      let params = call.arguments as! Dictionary<String, Any>;
      let alias = params["alias"] as! String;
      let type = params["type"] as! String;
      UMessage.setAlias(alias, type: type, response: {res, err in
        var msg = "";
        var isSuccess = false;
        if(err != nil) {
          msg = "setAlias success"
          isSuccess = true;
        }else {
          msg = "setAlias fail。error:\(String(describing: err))";
        }
        if(self.logEnabled) {
          print(msg);
        }
        result(isSuccess);
      })
    }
    
    public func removeAlias(call: FlutterMethodCall, result: @escaping FlutterResult) {
      let params = call.arguments as! Dictionary<String, Any>;
      let alias = params["alias"] as! String;
      let type = params["type"] as! String;
      UMessage.removeAlias(alias, type: type, response: {res, err in
        var msg = "";
        var isSuccess = false;
        if(err != nil) {
          msg = "removeAlias success"
          isSuccess = true;
        }else {
          msg = "removeAlias fail。error:\(String(describing: err))";
        }
        if(self.logEnabled) {
          print(msg);
        }
        result(isSuccess);
      })
    }
    
    public func addTags(call: FlutterMethodCall, result: @escaping FlutterResult) {
      let params = call.arguments as! Array<String>;
      UMessage.addTags(params, response: {res, remain, err  in
        var msg = "";
        var isSuccess = false;
        if(err != nil) {
          msg = "addTags success, 剩余可用的tag数\(remain)"
          isSuccess = true;
        }else {
          msg = "addTags fail。 error:\(String(describing: err))";
        }
        if(self.logEnabled) {
          print(msg);
        }
        result(isSuccess);
      })
    }
    
    public func removeTags(call: FlutterMethodCall, result: @escaping FlutterResult) {
      let params = call.arguments as! Array<String>;
      UMessage.deleteTags(params, response: {res, remain, err  in
        var msg = "";
        var isSuccess = false;
        if(err != nil) {
          msg = "removeTags success, 剩余可用的tag数\(remain)"
          isSuccess = true;
        }else {
          msg = "removeTags fail。error:\(String(describing: err))";
        }
        if(self.logEnabled) {
          print(msg);
        }
        result(isSuccess);
      })
    }
    
    public func groupInvokeMethodArgs(userInfo: [AnyHashable : Any]) -> String {
      var jsonStr = "";
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: userInfo, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        jsonStr = String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
      } catch {
        debugPrint("error")
      }
      return jsonStr;
    }
    
    public func getTags(call: FlutterMethodCall, result: @escaping FlutterResult) {
      UMessage.getTags { responseTags, remain, err in
        if(err != nil && remain != -1) {
          result(responseTags);
        }else {
          result([]);
        }
        if(self.logEnabled) {
          print("removeTags fail。error:\(String(describing: err))");
        }
      }
    }
    
    // 未启动时，点击通知的回调方法
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        let userInfo = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any]
        if(userInfo != nil) {
            initNotificationUserInfo = groupInvokeMethodArgs(userInfo: userInfo!);
        }
        return true;
    }
    
    // iOS10以下, 当APP处在启动状态时，点击通知栏的回调方法
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
      if(SwiftFlutterSUmengPushPlugin.channel != nil) {
          SwiftFlutterSUmengPushPlugin.channel?.invokeMethod("onOpenNotification", arguments: groupInvokeMethodArgs(userInfo: userInfo))
      }
      return true;
    }
    
    // iOS10以上，当APP处在启动状态时，处理前台收到通知的代理方法
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo;
      if(SwiftFlutterSUmengPushPlugin.channel != nil) {
          SwiftFlutterSUmengPushPlugin.channel?.invokeMethod("onOpenNotification", arguments: groupInvokeMethodArgs(userInfo: userInfo))
      }
    }
    
    // iOS10新增：处理前台收到通知的代理方法
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo;
        if(SwiftFlutterSUmengPushPlugin.channel != nil) {
           SwiftFlutterSUmengPushPlugin.channel?.invokeMethod("onReceiveNotification", arguments: groupInvokeMethodArgs(userInfo: userInfo))
        }
        // App处于前台时设置是否显示通知
        if(notificationOnForeground) {
            completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.sound.rawValue | UNNotificationPresentationOptions.alert.rawValue | UNNotificationPresentationOptions.badge.rawValue));
        }
    }

}
