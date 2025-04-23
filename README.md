# flutter_s_umeng_push

友盟推送的flutter插件，支持Android和ios

## 安装

在pubspec.yaml 文件中添加flutter_s_umeng_push依赖:

```javascript

dependencies:
  flutter_s_umeng_push: ^${latestVersion}
  
```

## 使用

```javascript
import 'package:flutter_s_umeng_push/flutter_s_umeng_push.dart';

///初始化友盟sdk，在所有方法使用之前
await FlutterUmengPush.init(
  appKey: '你的友盟应用appkey',
  messageSecret: '你的友盟应用messageSecret',
  logEnabled: false,
  // Android离线通知配置，华为与vivo需在AndroidManifest.xml中配置，具体请查看实例项目的AndroidManifest.xml文件
  xiaomiAppId: '小米AppId',
  xiaomiAppKey: '小米AppKey',
  meizuAppId: '魅族AppId',
  meizuAppKey: '魅族AppKey',
  oppoAppKey: 'oppo应用AppKey',
  oppoAppMasterSecret: 'oppo应用AppMasterSecret',
);

/// 友盟推送注册
await FlutterUmengPush.register();
```
华为与vivo需在AndroidManifest.xml中配置：
```javascript
<meta-data android:name="com.vivo.push.app_id" android:value="app_id" />
<meta-data android:name="com.vivo.push.api_key" android:value="api_key" />
<meta-data android:name="com.huawei.hms.client.appid" android:value="appid=xxx" />
```
如何获取这些配置信息，请查看[友盟官方文档](https://developer.umeng.com/docs/67966/detail/98589)。

当使用厂商通道发送离线通知时，需要填写打开指定系统弹窗页面acitivity的完整包路径，请使用：
```javascript
com.um.push.flutter_s_umeng_push.MfrMessageActivity
```


## 方法

|Method|Description  |Result|
|--|--|--|
| init | 友盟sdk初始化方法，需在调用任何方法前调用 |Future|
| register | 友盟初始化注册 |Future|
| addEventHandler | 添加消息监听 |void|
| setTokenCallback | 设置token回调，仅Android方法 |void|
| setMessageCallback | 设置自定义消息回调，仅Android方法 |void|
| getRegisteredId | 获取推送id |Future<String?>|
| setPushEnable | 设置推送的开关 |Future|
| setAlias | 设置别名 |Future<bool?>|
| removeAlias | 删除别名 |Future<bool?>|
| removeTags | 删除标签 |Future<bool?>|
| getTags | 获取所有的标签 |Future<List<dynamic>?>|
