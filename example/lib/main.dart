import 'package:flutter/material.dart';
import 'dart:async';
import 'package:xf_speech_plugin/xf_speech_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String iflyResultString = '点击+开始，点击-结束';
  XFJsonResult xfResult;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final voice = XfSpeechPlugin.instance;
    voice.initWithAppId(iosAppID: '', androidAppID: '');
    final param = new XFVoiceParam();
    param.domain = 'iat';
    param.asr_ptt = '0';
    param.asr_audio_path = 'xme.pcm';
    param.result_type = 'plain';
    param.voice_name = 'xiaoyan';
    param.result_type = 'json'; //可以设置plain
    final map = param.toMap();
    map['dwa'] = 'wpgs';        //设置动态修正，开启动态修正要使用json类型的返回格式
    voice.setParameter(map);
    //voice.setParameter(param.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: GestureDetector(
            child: Text(iflyResultString),
          ),
        ),

        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
              onPressed: onTapDown,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: onTapUp,
              tooltip: 'Decrement',
              child: Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }

  onTapDown() {
    print("tap down");

    iflyResultString = '';
    final listen = XfSpeechListener(
        onVolumeChanged: (volume) {
          print("声音"+'$volume');
        },
        onResults: (String result, isLast) {
          if (result.length > 0) {
            setState(() {
              print('11111111111111'+result);
           /*   XfSpeechPlugin.instance.startSpeaking(
                  string: iflyResultString);*/
              if (xfResult == null) {
                xfResult = XFJsonResult(result);
              } else {
                final another = XFJsonResult(result);
                xfResult.mix(another);
              }
                   print('2222222'+xfResult.resultText());
            });
          }
        },
        printResult: (String p){
          setState(() {
            iflyResultString=p;
          });

        },
        onCompleted: (Map<dynamic, dynamic> errInfo, String filePath) {
          setState(() {
            print('完成');
          });
        }
    );
    XfSpeechPlugin.instance.startListening(listener: listen);
  }

  onTapUp() {
    print("tap up");
    XfSpeechPlugin.instance.stopListening();
  }
}