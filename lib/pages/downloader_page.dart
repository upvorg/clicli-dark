// import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:clicli_dark/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:url_launcher/url_launcher.dart';

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
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) async {
      await loadTask();
    });

    loadTask();
    // loadDownloadedFiles();
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
    DownloadTaskStatus.canceled: Icons.not_interested,
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

  Future<void> loadTask() async {
    final tasks = await FlutterDownloader.loadTasks();
    tasks.sort((l, r) => l.progress.compareTo(r.progress));
    _tasks = tasks;
    setState(() {});
  }

  final downloadedFileList = [];

  // Future<void> loadDownloadedFiles() async {
  //   final path = await Config.downloadPath();
  //   final list = Directory(path).listSync();

  //   for (var i = 0; i < list.length; i++) {
  //     final dir = list[i];
  //     if ((await dir.stat()).type == FileSystemEntityType.directory) {
  //       final fileDir = dir.path.replaceAll('$path/', '');
  //       print('---目录名 $fileDir----');

  //       final fileList = Directory(dir.path).listSync();

  //       final _fileList = [];
  //       for (var i = 0; i < fileList.length; i++) {
  //         if (fileList[i].statSync().type == FileSystemEntityType.file) {
  //           _fileList.add({
  //             'name': fileList[i].path.replaceAll('$path/$fileDir/', ''),
  //             'path': fileList[i].path
  //           });

  //           print('---文件名 ${fileList[i].uri}----');
  //           if (await canLaunch(fileList[i].uri.path)) {
  //             await launch(fileList[i].uri.path);
  //           } else {
  //             showErrorSnackBar('打开链接失败');
  //           }
  //         }
  //       }

  //       downloadedFileList.add({'name': fileDir, 'children': _fileList});
  //     }
  //   }

  //   list.forEach((l) async {});
  // }

  static Future<void> _retryTaskById(String id) async {
    await FlutterDownloader.retry(taskId: id);
  }

  static Future<void> _resumeTaskById(String id) async {
    await FlutterDownloader.resume(taskId: id);
  }

  static Future<void> _stopTaskById(String id) async {
    await FlutterDownloader.pause(taskId: id);
  }

  // Future<void> _removeAllDownloadedTask() async {
  //   _tasks.forEach((task) async {
  //     await FlutterDownloader.remove(
  //       taskId: task.taskId,
  //       shouldDeleteContent: true,
  //     );
  //   });
  //   await loadTask();
  // }

  static Future<bool> _openDownloadedFile(String taskId) {
    return FlutterDownloader.open(taskId: taskId);
  }

  bool hasDoingTasks() {
    return _tasks.any(
      (task) =>
          task.status == DownloadTaskStatus.running ||
          task.status == DownloadTaskStatus.enqueued,
    );
  }

  Future<void> startAllPausedTask() async {
    _tasks.forEach((task) async {
      if (task.status == DownloadTaskStatus.paused) {
        await _resumeTaskById(task.taskId);
      }

      if (task.status == DownloadTaskStatus.canceled) {
        await _retryTaskById(task.taskId);
      }
    });
  }

  Future<void> pauseAllPausedTask() async {
    _tasks.forEach((task) async {
      if (task.status == DownloadTaskStatus.running ||
          task.status == DownloadTaskStatus.enqueued) {
        await _stopTaskById(task.taskId);
        setState(() {});
      }
    });
  }

  bool hasTaskId(String id) {
    return _tasks.any((task) => task.taskId == id);
  }

  void removeSelectedTasks() async {
    for (var i = 0; i < selectedTasks.length; i++) {
      await FlutterDownloader.remove(
        taskId: selectedTasks[i],
        shouldDeleteContent: true,
      );
    }
    await loadTask();
  }

  List<String> selectedTasks = [];

  @override
  Widget build(BuildContext context) {
    final hasDoingTask = hasDoingTasks();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('下载管理'),
        actions: selectedTasks.length < 1
            ? [
                IconButton(
                  icon: Icon(hasDoingTask ? Icons.pause : Icons.play_arrow),
                  onPressed: () async {
                    if (hasDoingTask) {
                      await pauseAllPausedTask();
                    } else {
                      await startAllPausedTask();
                    }
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: Icon(Icons.select_all),
                  onPressed: () {
                    _tasks.forEach((t) {
                      selectedTasks.add(t.taskId);
                    });
                    setState(() {});
                  },
                )
              ]
            : [
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: removeSelectedTasks,
                ),
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    selectedTasks = [];
                    setState(() {});
                  },
                ),
              ],
      ),
      body: ListView.builder(
        itemBuilder: (ctx, i) {
          final DownloadTask task = _tasks[i];
          final bool isSelected = selectedTasks.any((t) => t == task.taskId);
          return Container(
            color: isSelected ? Theme.of(context).accentColor : null,
            child: ListTile(
              title: ellipsisText(task.filename ?? ''),
              leading: Icon(downloadStatusIcons[task.status]),
              trailing: Text('${task.progress > 100 ? '∞' : task.progress} %'),
              onTap: () async {
                if (selectedTasks.length > 0) {
                  if (isSelected) {
                    selectedTasks.removeWhere((t) => t == task.taskId);
                  } else {
                    selectedTasks.add(task.taskId);
                  }
                } else {
                  await downloadStatusFn[task.status](task.taskId);
                }
                setState(() {});
              },
              onLongPress: () {
                if (isSelected) {
                  selectedTasks.removeWhere((t) => t == task.taskId);
                } else {
                  selectedTasks.add(task.taskId);
                }
                setState(() {});
              },
            ),
          );
        },
        itemCount: _tasks.length,
      ),
    );
  }
}
