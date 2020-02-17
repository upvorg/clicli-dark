import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloaderPage extends StatefulWidget {
  @override
  _DownloaderPageState createState() => _DownloaderPageState();
}

class _DownloaderPageState extends State<DownloaderPage> {
  ReceivePort _port = ReceivePort();

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();
    loadTask();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      loadTask();
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  List<DownloadTask> _tasks = [];
  final Map<dynamic, IconData> downloadStatusIcons = {
    DownloadTaskStatus.running: Icons.pause,
    DownloadTaskStatus.paused: Icons.play_arrow,
    DownloadTaskStatus.complete: Icons.done,
    DownloadTaskStatus.failed: Icons.error,
    DownloadTaskStatus.canceled: Icons.pause,
    DownloadTaskStatus.enqueued: Icons.access_time,
    DownloadTaskStatus.undefined: Icons.not_interested,
  };

  final Map<dynamic, Function> downloadStatusFn = {
    DownloadTaskStatus.running: _stopTaskById,
    DownloadTaskStatus.paused: _resumeTaskById,
    DownloadTaskStatus.complete: _openDownloadedFile,
    DownloadTaskStatus.failed: _retryTaskById,
    DownloadTaskStatus.canceled: _retryTaskById,
    DownloadTaskStatus.enqueued: _retryTaskById,
    DownloadTaskStatus.undefined: (String id) {},
  };

  void loadTask() async {
    final tasks = await FlutterDownloader.loadTasks();
    _tasks = tasks;
    setState(() {});
  }

  static _retryTaskById(String id) {
    FlutterDownloader.retry(taskId: id);
  }

  static _resumeTaskById(String id) {
    FlutterDownloader.resume(taskId: id);
  }

  static _stopTaskById(String id) {
    FlutterDownloader.pause(taskId: id);
  }

  Future<void> _removeAllDownloadedTask() async {
    _tasks.forEach((task) async {
      await FlutterDownloader.remove(taskId: task.taskId);
    });
    loadTask();
    setState(() {});
  }

  static Future<bool> _openDownloadedFile(String taskId) {
    return FlutterDownloader.open(taskId: taskId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('下载管理'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.pause),
            onPressed: () {
              FlutterDownloader.cancelAll();
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _removeAllDownloadedTask,
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (ctx, i) {
          print(_tasks[i].status);
          return ListTile(
            title: Text(_tasks[i].filename ?? ''),
            leading: Icon(downloadStatusIcons[_tasks[i].status]),
            trailing: Text('${_tasks[i].progress} %'),
            onTap: () async {
              await downloadStatusFn[_tasks[i].status](_tasks[i].taskId);
              setState(() {});
            },
          );
        },
        itemCount: _tasks.length,
      ),
    );
  }
}
