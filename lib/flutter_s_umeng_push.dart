/*
 * @Author: Arno.su
 * @Date: 2022-10-28 13:10:23
 * @LastEditors: Arno.su
 * @LastEditTime: 2022-11-07 17:59:32
 */
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

///定义回调
typedef Callback = void Function(String result);
typedef CallbackMsg = void Function(MessageBody result);

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
  /// * appKey 友盟应用 appKey
  /// * messageSecret 友盟应用 messageSecret 仅Android传
  /// * channel 分享渠道
  /// * logEnabled 是否开启日志
  /// * notificationOnForeground 设置App处于前台时是否显示通知， 默认为true
  ///
  /// 推送厂商通道，传入对应的值将自动开启
  /// * xiaomiAppId 小米AppId
  /// * xiaomiAppKey 小米AppKey
  /// * meizuAppId 魅族AppId
  /// * meizuAppKey 魅族AppKey
  /// * oppoAppKey oppo应用AppKey
  /// * oppoAppMasterSecret oppo应用AppMasterSecret
  /// * 华为与vivo需在AndroidManifest.xml中配置
  ///
  /// 在调用所有方法前必须调用init方法
  ///
  static Future<dynamic> init({
    required String appKey,
    required String messageSecret,
    String channel = "umengpush",
    bool logEnabled = false,
    bool notificationOnForeground = true,
    String? xiaomiAppId,
    String? xiaomiAppKey,
    String? meizuAppId,
    String? meizuAppKey,
    String? oppoAppKey,
    String? oppoAppMasterSecret,
  }) async {
    Map<dynamic, dynamic> result = await methodChannel.invokeMethod('umInit', {
      "appKey": appKey,
      "messageSecret": messageSecret,
      "channel": channel,
      "notificationOnForeground": notificationOnForeground,
      "logEnabled": logEnabled,
      "xiaomi_app_id": xiaomiAppId,
      "xiaomi_app_key": xiaomiAppKey,
      "meizu_app_id": meizuAppId,
      "meizu_app_key": meizuAppKey,
      "oppo_app_key": oppoAppKey,
      "oppo_app_masterSecret": oppoAppMasterSecret,
    });
    return result;
  }

  /// 添加消息监听
  /// 需要获取App冷启动消息参数，需要在register方法前调用
  /// onReceiveNotification：接收到消息回调
  /// onOpenNotification：点击消息回调
  static void addEventHandler({
    CallbackMsg? onReceiveNotification,
    CallbackMsg? onOpenNotification,
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
  static void setMessageCallback(CallbackMsg? callback) {
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

class MessageBody {
  /// 消息标题
  String? title;

  /// 消息副标题，仅ios
  String? subtitle;

  /// 消息内容
  String? content;

  /// 消息id
  String? msgId;

  /// 自定义参数
  Map? extra;

  MessageBody({this.title, this.subtitle, this.content, this.msgId, this.extra});

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "subtitle": subtitle,
      "content": content,
      "msgId": msgId,
      "extra": extra,
    };
  }
}

class _Callbacks {
  Callback? tokenCallback;
  CallbackMsg? messageCallback;
  CallbackMsg? receiveNotification;
  CallbackMsg? openNotification;

  _Callbacks(MethodChannel channel) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onReceiveNotification":
          if (receiveNotification != null) {
            receiveNotification!(groupMessageBody(call));
          }
          break;
        case "onOpenNotification":
          if (openNotification != null) {
            openNotification!(groupMessageBody(call));
          }
          break;
        case "onToken":
          var token = call.arguments;
          if (tokenCallback != null) {
            tokenCallback!(token);
          }
          break;
        case "onMessage":
          if (messageCallback != null) {
            messageCallback!(groupMessageBody(call));
          }
          break;
        default:
      }
    });
  }

  MessageBody groupMessageBody(MethodCall call) {
    String? args = call.arguments;
    MessageBody messageBody = MessageBody();

    if (args != null && args.isNotEmpty) {
      Map json = jsonDecode(args);
      if (Platform.isIOS) {
        Map aps = json['aps'];
        Map alert = aps['alert'];
        Map extra = {};
        json.forEach((key, value) {
          if (key != 'aps' && key != 'd' && key != 'p') {
            extra[key] = value;
          }
        });
        messageBody = MessageBody(
          title: alert['title'],
          subtitle: alert['subtitle'],
          content: alert['body'],
          msgId: json['d'],
          extra: extra,
        );
      } else {
        Map body = json['body'];
        Map? extra = json['extra'];
        messageBody = MessageBody(
          title: body['title'],
          content: body['text'],
          msgId: json['msg_id'],
          extra: extra,
        );
      }
    }
    return messageBody;
  }
}
