// ignore_for_file: avoid_print

/*
 * @Author: Arno.su
 * @Date: 2022-10-28 13:10:25
 * @LastEditors: Arno.su
 * @LastEditTime: 2023-08-15 10:48:55
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_s_umeng_push/flutter_s_umeng_push.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? msg;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    /// 初始化友盟推送
    await FlutterUmengPush.init(
      appKey: '友盟Appkey',
      messageSecret: '友盟messageSecret',
      logEnabled: false,
    );

    /// 监听推送事件，注：监听事件要声明在register方法前，否则无法接收到离线通知
    FlutterUmengPush.addEventHandler(
      onOpenNotification: (message) async {
        setState(() {
          msg = message.toJson().toString();
          print("获取点击的推送消息onOpenNotification: $msg");
        });
      },
      onReceiveNotification: (message) async {
        setState(() {
          msg = message.toJson().toString();
          print("获取收到的推送消息onReceiveNotification: $msg");
        });
      },
    );

    /// 友盟推送注册
    await FlutterUmengPush.register();
    String? registeredId = await FlutterUmengPush.getRegisteredId();
    print('======registeredId:$registeredId=====');
    FlutterUmengPush.setMessageCallback((message) {
      print('获取Android自定义推送消息===========${message.toJson()}');
    });
    FlutterUmengPush.setAlias('Alias', 'ios');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('推送消息数据：$msg'),
        ),
      ),
    );
  }
}
