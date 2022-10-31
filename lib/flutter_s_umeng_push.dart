/*
 * @Author: Arno.su
 * @Date: 2022-10-28 13:10:23
 * @LastEditors: Arno.su
 * @LastEditTime: 2022-10-31 15:43:56
 */
import 'package:flutter/services.dart';

///定义回调
typedef Callback = void Function(String result);

class FlutterUmengPush {
  static const methodChannel = MethodChannel('flutter_s_umeng_push');

  static final _Callbacks _callback = _Callbacks(methodChannel);

  static const methodRegister = 'register';
  static const methodDeviceToken = 'getDeviceToken';
  static const methodPushEnable = 'enable';
  static const methodSetAlias = 'setAlias';
  static const methodRemoveAlias = 'removeAlias';
  static const methodAddTag = 'addTag';
  static const methodRemoveTag = 'removeTag';
  static const methodGetTags = 'getTags';

  /// 初始化um sdk
  /// appKey 友盟应用 appKey
  /// messageSecret 友盟应用 messageSecret 仅Android传
  /// channel 分享渠道
  /// logEnabled 是否开启日志
  /// notificationOnForeground 设置App处于前台时是否显示通知， 默认为true
  /// 在调用所有方法前必须调用
  ///
  static Future<dynamic> init({
    required String appKey,
    required String messageSecret,
    String channel = "umengpush",
    bool logEnabled = false,
    bool notificationOnForeground = true,
  }) async {
    Map<dynamic, dynamic> result = await methodChannel.invokeMethod('umInit', {
      "appKey": appKey,
      "messageSecret": messageSecret,
      "channel": channel,
      "notificationOnForeground": notificationOnForeground,
      "logEnabled": logEnabled,
    });
    return result;
  }

  /// 添加消息监听
  /// 需要获取App冷启动消息参数，需要在register方法前调用
  /// onReceiveNotification：接收到消息回调
  /// onOpenNotification：点击消息回调
  static void addEventHandler({
    Callback? onReceiveNotification,
    Callback? onOpenNotification,
  }) {
    _callback.receiveNotification = onReceiveNotification;
    _callback.openNotification = onOpenNotification;
  }

  /// 设置token回调
  /// 仅Android方法
  static void setTokenCallback(Callback? callback) {
    _callback.tokenCallback = callback;
  }

  /// 设置自定义消息回调
  /// 仅Android方法
  static void setMessageCallback(Callback? callback) {
    _callback.messageCallback = callback;
  }

  ///初始化推送
  static Future<void> register() async {
    return await methodChannel.invokeMethod(methodRegister);
  }

  ///获取推送id
  static Future<String?> getRegisteredId() async {
    return await methodChannel.invokeMethod(methodDeviceToken);
  }

  /// 设置推送的开关
  static Future<void> setPushEnable(bool enable) async {
    return await methodChannel.invokeMethod(methodPushEnable, enable);
  }

  /// 设置别名
  static Future<bool?> setAlias(String alias, String type) async {
    return await methodChannel.invokeMethod(methodSetAlias, {'alias': alias, 'type': type});
  }

  /// 删除别名
  static Future<bool?> removeAlias(String alias, String type) async {
    return await methodChannel.invokeMethod(methodRemoveAlias, {'alias': alias, 'type': type});
  }

  /// 添加标签
  static Future<bool?> addTags(List<String> tags) async {
    return await methodChannel.invokeMethod(methodAddTag, tags);
  }

  /// 删除标签
  static Future<bool?> removeTags(List<String> tags) async {
    return await methodChannel.invokeMethod(methodRemoveTag, tags);
  }

  /// 获取所有的标签
  static Future<List<dynamic>?> getTags() async {
    return await methodChannel.invokeMethod(methodGetTags);
  }
}

class _Callbacks {
  Callback? tokenCallback;
  Callback? messageCallback;
  Callback? receiveNotification;
  Callback? openNotification;

  _Callbacks(MethodChannel channel) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onReceiveNotification":
          if (receiveNotification != null) {
            receiveNotification!(call.arguments);
          }
          break;
        case "onOpenNotification":
          if (openNotification != null) {
            openNotification!(call.arguments);
          }
          break;
        case "onToken":
          var token = call.arguments;
          if (tokenCallback != null) {
            tokenCallback!(token);
          }
          break;
        case "onMessage":
          var message = call.arguments;
          if (messageCallback != null) {
            messageCallback!(message);
          }
          break;
        default:
      }
    });
  }
}
