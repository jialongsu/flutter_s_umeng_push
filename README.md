# flutter_umeng_push

友盟推送的flutter插件，支持Android和ios

## 安装

在pubspec.yaml 文件中添加flutter_umeng_push依赖:

```javascript

dependencies:
  flutter_umeng_push: ^${latestVersion}
  
```

## 使用

```javascript
import 'package:flutter_umeng_push/flutter_umeng_push.dart';

///初始化友盟sdk，在所有方法使用之前
FlutterUmengPush.init(
  appKey: '你的友盟应用appkey',
  messageSecret: '你的友盟应用messageSecret',
  logEnabled: false,
);

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
