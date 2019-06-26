import 'dart:async';

import 'package:aria2/aria2_config.dart';
import 'package:flutter/material.dart';
import 'package:aria2/aria2.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'aria2 test',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'aria2 test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Aria2 aria2;

  String responseContext = "";

  String _completedLength = "";
  String _length = "";
  String _path = "";
  String _downloadSpeed = "";
  String _errorCode ="";
  String _errorMessage = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Aria2Config aria2config = new Aria2Config("1.0.0", "assets/data/aria2c",
        "assets/data/aria2c.conf", "123456", "ws://127.0.0.1:2869/jsonrpc");

    aria2 = new Aria2(aria2config);

    aria2.createAria2();
  }

  void _incrementCounter() {
    setState(() {});
  }

  getVersion() async {
    print("getVersion");
    var version = await aria2.aria2jsonRpc.getVersion();

    setState(() {
      responseContext += version.toString();
    });

    print(version);
  }

  addUrl() async {
    setState(() {
      _errorCode = "";
      _errorMessage = "";
    });
    var response =
        await aria2.aria2jsonRpc.addUri(["http://104.192.87.1/test200mb.zip"]);


    const oneSec = const Duration(seconds: 1);
    new Timer.periodic(oneSec, (Timer t) => query(t, response));
  }

  query(Timer t, String uuid) async {
    var response = await aria2.aria2jsonRpc.tellStatus(uuid);

    if (response["errorCode"] != null) {
      setState(() {
        _errorCode = response["errorCode"];
        _errorMessage = response["errorMessage"];
      });
      t.cancel();
    }

    String completedLength =
        (int.parse(response["files"][0]["completedLength"]) / 1024 / 1024)
            .toString();
    String length =
        (int.parse(response["files"][0]["length"]) / 1024 / 1024).toString();
    String path = response["files"][0]["path"].toString();
    String downloadSpeed =
        (int.parse(response["downloadSpeed"]) / 1024 / 1024).toString();

    setState(() {
      this._completedLength = completedLength;
      this._length = length;
      this._path = path;
      this._downloadSpeed = downloadSpeed;
    });
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                aria2.reConnectRpc();
              },
              child: new Text("连接RPC"),
            ),
            RaisedButton(
              onPressed: () {
                getVersion();
              },
              child: new Text("获取版本号"),
            ),
            RaisedButton(
              onPressed: () {
                addUrl();
              },
              child: new Text("添加下载链接"),
            ),
            new Text(_completedLength + "MB"),
            new Text(_length + "MB"),
            new Text(_path),
            new Text(_downloadSpeed + "mb/1s"),
            new Text("错误code:" +_errorCode),
            new Text("错误message:" + _errorMessage)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
