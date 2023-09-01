import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tournament_client/lib/bar_chart.widget.dart';
import 'package:tournament_client/lib/bar_chart_race.dart';
import 'package:tournament_client/utils/mycolors.dart';
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
    socket = IO.io('http://192.168.101.58:8099', <String, dynamic>{
      'transports': ['websocket'],
    });
    socket!.onConnect((_) {
      print('Connected to server');
    });
    socket!.onDisconnect((_) {
      print('Disconnected from server');
    });
    // socket!.on('eventFromServer', (data) {
    //   List<Map<String, dynamic>> stationData = List<Map<String, dynamic>>.from(data);
    //   _streamController.add(stationData);
    // });
    socket!.on('eventFromServer', (data) {
      if (data is List<dynamic>) {
        List<List<double>> stationData = [];

        for (dynamic item in data) {
          if (item is List<dynamic>) {
            List<double> doubleList = [];
            for (dynamic value in item) {
              if (value is num) {
                doubleList.add(value.toDouble());
              }
            }
            stationData.add(doubleList);
            // print('stationData: ${stationData}');
          }
        }

        List<Map<String, dynamic>> formattedData = stationData.map((list) {
          return {'data': List<double>.from(list)};
        }).toList();

        _streamController.add(formattedData);
      }
    });

    socket!.emit('eventFromClient');
  }

  void _delete(int stationId) {
    socket!.emit('eventFromClientDelete', {'stationId': stationId});
    String message = 'Data deleted with stationId ${stationId}';
    snackbar_custom(context: context, text: message);
  }

  void _create() {
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
    socket!.disconnect();
    _streamController.close();
    super.dispose();
  }

  Future<Null> _refresh() async {
    socket!.emit('eventFromClient');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final stationDataList = snapshot.data!;
              final formattedData =
                  stationDataList.map<List<double>>((dataMap) {
                if (dataMap['data'] is List<double>) {
                  final dataList = dataMap['data'] as List<double>;
                  return dataList;
                }
                return [];
              }).toList();
              if (snapshot.data!.isEmpty || snapshot.data == null || snapshot.data ==[]) {
                return Text('empty data');
              }

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  physics: const BouncingScrollPhysics(),
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: BarChartRace(
                      data: convertData(formattedData),
                      initialPlayState: true,
                      columnsColor: colorList,
                      // columnsColor: shuffleColorList(),
                      framesPerSecond: 90,
                      framesBetweenTwoStates: 90,
                      numberOfRactanglesToShow: formattedData[0].length,
                      title: "DYNAMIC RANKING",
                      columnsLabel: formattedData[0].map((value) => 'PLAYER ${value.toStringAsFixed(0)}').toList(),
                      // [
                      //   "Amazon",
                      //   "Google",
                      //   "Apple",
                      //   "Coca",
                      //   "Huawei",
                      //   "Sony",
                      //   'Pepsi',
                      //   "Samsung",
                      //   "Netflix",
                      //   "Facebook",
                      // ],
                      statesLabel: List.generate(
                        30,
                        (index) => formatDate(
                          DateTime.now().add(
                            Duration(days: index),
                          ),
                        ),
                      ),
                      titleTextStyle: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontSize: 32,
                      ),
                    )),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        // barcharcustom(formattedData)
        // BarCharRace(data: formattedData,)
        // StreamBuilder<List<Map<String, dynamic>>>(
        //   stream: _streamController.stream,
        //   builder: (context, snapshot) {
        //     if (snapshot.hasData) {
        //       final stationData = snapshot.data!;
        //       return ScrollConfiguration(
        //         behavior: ScrollConfiguration.of(context).copyWith(
        //           physics: const BouncingScrollPhysics(),
        //           dragDevices: {
        //             PointerDeviceKind.touch,
        //             PointerDeviceKind.mouse,
        //             PointerDeviceKind.trackpad
        //           },
        //         ),
        //         child: RefreshIndicator(
        //             onRefresh: _refresh, child: Text('$stationData')
        //             // ExamplePage(data: stationData)
        //             ),
        //       );
        //     } else {
        //       return const Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     }
        //   },
        // ),
      ),
    );
  }
}

List<List<double>> convertData(data) {
  if (data.length == 2) {
    return [data.last];
  } else if (data.length == 3) {
    return [data[1], data.last];
  }
  return data;
}

class FormattedDataText extends StatelessWidget {
  final List<List<double>> formattedData;

  FormattedDataText({required this.formattedData});

  @override
  Widget build(BuildContext context) {
    return Text('$formattedData');
  }
}
List<Color> colorList = [
  // MyColor.green_araconda,
  // MyColor.pink,
  // MyColor.pinkMain,
  // Color(0xFFEF5350),
  // MyColor.grey,
  // Color(0xFFFFD600),
  // const Color(0xFFEF6C00),
  // // const Color(0xFFC6FF00),
  // MyColor.blue_coinbase,
  // const Color(0xFF00E5FF),
  // Color(0xFF424242),
  MyColor.orang3,
  MyColor.orang3,
  MyColor.orang3,
  MyColor.orang3,
  MyColor.green_araconda,
  MyColor.orang3,
  MyColor.orang3,
  MyColor.orang3,
  MyColor.orang3,
  MyColor.orang3,
];

// List<Color> shuffleColorList() {
//   final random = Random();
//   final sublistLength = 10;

//   // Make sure the sublist length doesn't exceed the length of the color list
//   final shuffledList = colorList.sublist(0, sublistLength)..shuffle(random);

//   // Create a new list with the shuffled sublist
//   final newList = List<Color>.from(colorList);
//   for (int i = 0; i < sublistLength; i++) {
//     newList[i] = shuffledList[i];
//   }
  
//   return newList;
// }