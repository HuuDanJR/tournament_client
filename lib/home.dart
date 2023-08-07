import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tournament_client/animatelist.dart';
import 'package:tournament_client/example.dart';
import 'package:tournament_client/widget/listview.dart';
import 'package:tournament_client/widget/snackbar.custom.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IO.Socket? socket;
  StreamController<List<Map<String, dynamic>>> _streamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  List<Map<String, dynamic>> stationData = [];
  Map<String, AnimationController> _animationControllers = {};

  @override
  void initState() {
    super.initState();
    // Connect to the socket.io server
    socket = IO.io('http://30.0.0.82:8090', <String, dynamic>{
      'transports': ['websocket'],
    });
    socket!.onConnect((_) {
      print('Connected to server');
    });
    socket!.onDisconnect((_) {
      print('Disconnected from server');
    });
    socket!.on('eventFromServer', (data) {
      // print('Received data from server: $data');
      List<Map<String, dynamic>> stationData =
          List<Map<String, dynamic>>.from(data);
      _streamController.add(stationData);
    });

    socket!.emit('eventFromClient');
  }

  void _delete(int stationId) {
    // Emit an event to the server for delete with the given stationId
    socket!.emit('eventFromClientDelete', {'stationId': stationId});
    String message = 'Data deleted with stationId ${stationId}';
    snackbar_custom(context: context, text: message);
  }

  void _create() {
    // Emit an event to the server for delete with the given stationId
    socket!.emit('eventFromClientAdd', {
      "machine": "RL-TEST",
      "member": "1",
      "bet": "799999",
      "credit": "799999",
      "connect": "1",
      "status": "0",
      "aft": "0",
      "lastupdate": "2023-07-28"
    });
    String message = 'Created an record';
    snackbar_custom(context: context, text: message);
  }

  @override
  void dispose() {
    // Disconnect from the socket.io server when the widget is disposed
    socket!.disconnect();
    _streamController.close();
    super.dispose();
  }

  Future<Null> _refresh() async {
    socket!.emit('eventFromClient');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final stationData = snapshot.data!;
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  physics: const BouncingScrollPhysics(),
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad
                  },
                ),
                child: RefreshIndicator(
                    onRefresh: _refresh,
                    child:
                    ExamplePage(data: stationData)
                    //  ListView.builder(
                    //   padding: const EdgeInsets.all(32),
                    //   // shrinkWrap: true,
                    //   itemCount: stationData.length,
                    //   itemBuilder: (context, index) {
                    //     // Use the station data to build your UI here
                    //     final data = stationData[index];
                    //     return Card(
                    //       child: ListTile(
                    //         leading: index == 1 || index == 2 || index == 0
                    //             ? Icon(Icons.star, color: Colors.redAccent)
                    //             : Container(
                    //                 width: 1,
                    //                 height: 1,
                    //               ),
                    //         title: Text('Member: ${data['member']}'),
                    //         subtitle: Text('credit: ${data['credit']}'),
                    //       ),
                    //     );
                    //   },
                    // )
                    
                    ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              print('order listview');
            },
            tooltip: 'Order',
            child: const Icon(Icons.bar_chart),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              _create();
            },
            tooltip: 'Create',
            child: const Icon(Icons.create_outlined),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(

            onPressed: () {
              // snackbar_custom(context: context, text: "Delete Data");
              _delete(1241);
            },
            tooltip: 'Delete',
            child: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              snackbar_custom(context: context, text: "Refeshing Data");
              _refresh();
            },
            tooltip: 'Refresh',
            child: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}
