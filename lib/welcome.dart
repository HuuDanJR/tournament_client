import 'package:flutter/material.dart';
import 'package:tournament_client/home.dart';
import 'package:tournament_client/utils/mycolors.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController controller = TextEditingController();
  bool isDialogVisible = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height:height,
        width:width,
        decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.black87,
                ],
                stops: [
                  0.0,
                  0.75,
                ], // Adjust the stops to control the gradient effect
              ),
              // image: DecorationImage(
              //   filterQuality: FilterQuality.low,
              //   image: AssetImage('asset/image/background.png'),
              //   fit: BoxFit.cover, // Make the image cover the entire container
              // ),
            ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                alignment: Alignment.center,
                width: 135,
                height: 55,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('asset/image/logo_new.png'),
                        fit: BoxFit.contain)),
              )),
            // MyHomePage(title: 'tournament page',selectedIndex: 0,),
            if (isDialogVisible)
              AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Set border radius
                ),
                title: Text('Player Setting'),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    hintText: 'Enter player number (1-10)',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        int? number = int.tryParse(controller.text);
                        if (number != null && number >= 1 && number <= 10) {
                          setState(() {
                            isDialogVisible = false; // Hide the dialog
                          });
                          final snackBar = SnackBar(
                              duration: Duration(seconds: 1),
                              backgroundColor: MyColor.black_text,
                              content: Text(
                                'You chose as player ${controller.text}',
                                style: TextStyle(
                                    fontFamily: 'OpenSan',
                                    fontSize: 16,
                                    color: MyColor.white),
                              ));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          // The text is a valid number within the range 1-10
                          // Do something with the number here
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => MyHomePage(
                                  title: 'Tournament Client',
                                  selectedIndex: int.parse(controller.text))));
                        } else {
                          final snackBar = SnackBar(
                              backgroundColor: MyColor.black_text,
                              content: Text(
                                'Please input number from 1-10',
                                style: TextStyle(
                                    fontFamily: 'OpenSan',
                                    fontSize: 16,
                                    color: MyColor.white),
                              ));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    },
                    child: Text('Confirm'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isDialogVisible = false; // Hide the dialog
                      });
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void showInSnackBar(String value, _scaffoldKey) {
  _scaffoldKey.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}
