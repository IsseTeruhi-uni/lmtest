import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localmltester/view/filescan_screen.dart';
import 'package:localmltester/view/livescan_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  late CameraDescription cameraDescription;
  int selectedIndex = 0;
  List<Widget>? widgetOptions;

  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPages();
    });
  }

  initPages() async {
    widgetOptions = [const GalleryScreen()];

    if (cameraIsAvailable) {
      // get list available camera
      cameraDescription = (await availableCameras()).first;
      widgetOptions!.add(CameraScreen(camera: cameraDescription));
    }

    setState(() {});
  }

  void onItemTapped(int index) {
    if (!cameraIsAvailable) {
      debugPrint("This is not supported on your current platform");
      return;
    }
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Local ML Tester"),
      ),
      body: Center(
        child: widgetOptions?.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Gallery screen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Live Camera',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: onItemTapped,
      ),
    );
  }
}
