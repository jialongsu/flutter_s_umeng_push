// ignore_for_file: avoid_print

/*
 * @Author: Arno.su
 * @Date: 2022-10-28 13:10:25
 * @LastEditors: Arno.su
 * @LastEditTime: 2022-10-31 16:08:06
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
      appKey: '635a1553d76a2d6aba4bbb67',
      messageSecret: '23bb88a433adff723fdee493a2341a19',
      // appKey: '60519766b8c8d45c13a16fa0',
      // messageSecret: 'eup7wbxgnmlglk6s2xbdumdxwkl3tmwc',
      notificationOnForeground: true,
      logEnabled: true,
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
