import 'package:clicli_dark/instance.dart';
import 'package:dlna/dlna.dart';
import 'package:flutter/material.dart';

class DLNAPage extends StatefulWidget {
  @override
  _DLNAPageState createState() => _DLNAPageState();
}

class _DLNAPageState extends State<DLNAPage> {
  List<DLNADevice> _devices = [];
  DLNADevice _dlnaDevice;
  String errMsg = '';

  setDlnaDevice(DLNADevice value) {
    _dlnaDevice = value;
    Instances.dlnaManager.setDevice(value);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Instances.dlnaManager.setRefresher(DeviceRefresher(
        onDeviceAdd: (dlnaDevice) {
          if (!_devices.contains(dlnaDevice)) {
            print('add ' + dlnaDevice.toString());
            _devices.add(dlnaDevice);
          }
          setState(() {});
        },
        onDeviceRemove: (dlnaDevice) {
          print('remove ' + dlnaDevice.toString());
          _devices.remove(dlnaDevice);
          setState(() {});
        },
        onDeviceUpdate: (dlnaDevice) {
          print('update ' + dlnaDevice.toString());
          setState(() {});
        },
        onSearchError: (error) {
          print('error ' + error);
        },
        onPlayProgress: (positionInfo) {}));

    Instances.dlnaManager.startSearch();
  }

  @override
  void dispose() {
    Instances.dlnaManager.stopSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('投屏'),
        actions: <Widget>[
          MaterialButton(
            onPressed: () {},
            child: Text('需要帮助', style: theme.textTheme.caption),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Text('错误信息$errMsg', style: theme.textTheme.caption),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text('当前连接设备', style: theme.textTheme.caption),
          ),
          Container(
            width: double.infinity,
            color: theme.backgroundColor,
            padding: EdgeInsets.all(8.0),
            child: Text(
              _dlnaDevice != null
                  ? '${_dlnaDevice?.deviceName ?? ''}\n${_dlnaDevice?.location ?? ''}'
                  : '未选择设备',
              style: theme.textTheme.bodyText2,
            ),
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // IconButton(
              //   icon: Icon(Icons.skip_previous),
              //   iconSize: 40,
              //   onPressed: () {},
              // ),
              IconButton(
                iconSize: 40,
                icon: Icon(Icons.play_circle_filled),
                onPressed: () async {
                  final u = VideoObject(
                      'cpdd 你是唯一',
                      'https://vt1.doubanio.com/201902111139/0c06a85c600b915d8c9cbdbbaf06ba9f/view/movie/M/302420330.mp4',
                      VideoObject.VIDEO_MP4);
                  u.refreshPosition = true;
                  final e = await Instances.dlnaManager.actSetVideoUrl(u);
                  errMsg = e.toString();
                  setState(() {});
                  final ee = await Instances.dlnaManager.actPlay();
                  errMsg = ee.toString();
                  setState(() {});
                  // _dlnaManager.release();
                },
              ),
              // IconButton(
              //   iconSize: 40,
              //   icon: Icon(Icons.pause),
              //   onPressed: () => Instances.dlnaManager.actPlay(),
              // ),
              // IconButton(
              //   iconSize: 40,
              //   icon: Icon(Icons.skip_next),
              //   onPressed: () {},
              // ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('选择投屏设备', style: theme.textTheme.caption),
                IconButton(
                  onPressed: Instances.dlnaManager.startSearch,
                  icon: Icon(Icons.refresh),
                )
              ],
            ),
          ),
          DeviceListStatefulWidget(_devices, (DLNADevice device) {
            setDlnaDevice(device);
          }),
        ],
      ),
    );
  }
}

class DeviceListStatefulWidget extends StatefulWidget {
  final List<DLNADevice> _devices;
  final Function(DLNADevice device) _onClickCallback;

  DeviceListStatefulWidget(this._devices, this._onClickCallback);

  @override
  State<StatefulWidget> createState() {
    return DeviceListState();
  }
}

class DeviceListState extends State<DeviceListStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: widget._devices.length > 0
            ? ListView.builder(
                itemCount: widget._devices.length,
                itemBuilder: (BuildContext context, int position) {
                  return _getListData(position);
                },
              )
            : Container(
                width: double.infinity,
                color: Theme.of(context).backgroundColor,
                padding: EdgeInsets.all(8.0),
                child: Text('正在搜索设备 ··· ', textAlign: TextAlign.center),
              ),
      ),
    );
  }

  _getListData(int position) {
    return GestureDetector(
        onTap: () {
          widget._onClickCallback(widget._devices[position]);
        },
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  widget._devices[position].deviceName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                _listViewLine
              ],
            )));
  }

  get _listViewLine {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
        child: Container(
          color: Colors.black12,
          height: 1,
        ));
  }
}
