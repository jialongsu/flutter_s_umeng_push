// ignore_for_file: avoid_print

/*
 * @Author: Arno.su
 * @Date: 2022-10-28 13:10:25
 * @LastEditors: Arno.su
 * @LastEditTime: 2022-11-02 17:12:07
 */
import 'dart:async';
import 'dart:io';

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
      appKey: Platform.isIOS ? '60519766b8c8d45c13a16fa0' : '635a1553d76a2d6aba4bbb67',
      messageSecret: '23bb88a433adff723fdee493a2341a19',
      // appKey: '友盟Appkey',
      // messageSecret: '友盟messageSecret',
      logEnabled: false,
    );

    /// 监听推送事件
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
