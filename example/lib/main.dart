// ignore_for_file: avoid_print

/*
 * @Author: Arno.su
 * @Date: 2022-10-28 13:10:25
 * @LastEditors: Arno.su
 * @LastEditTime: 2022-10-31 11:00:43
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
      appKey: '你的友盟应用appkey',
      messageSecret: '你的友盟应用messageSecret',
      logEnabled: false,
    );

    /// 监听推送事件
    FlutterUmengPush.addEventHandler(
      onOpenNotification: (String message) async {
        setState(() {
          msg = message;
        });
        print("获取点击的推送消息onOpenNotification: $message");
      },
      onReceiveNotification: (String message) async {
        setState(() {
          msg = message;
        });
        print("获取收到的推送消息onReceiveNotification: $message");
      },
    );

    /// 友盟推送注册
    await FlutterUmengPush.register();
    String? registeredId = await FlutterUmengPush.getRegisteredId();
    print('======registeredId:$registeredId=====');
    FlutterUmengPush.setMessageCallback((result) {
      print('获取Android自定义推送消息===========$result');
    });
    FlutterUmengPush.setAlias('13002115118', 'ios');
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
