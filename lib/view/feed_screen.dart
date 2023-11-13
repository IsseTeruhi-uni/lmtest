import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localmltester/helper/image_classification_helper.dart';
import 'package:localmltester/view/filescan_screen.dart';
import 'package:localmltester/view/home_screen.dart';
import 'package:localmltester/view/livescan_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);
  @override
  FeedScreenState createState() => FeedScreenState();
}

class FeedScreenState extends ConsumerState<FeedScreen> {
  int cullentIndex = 0;
  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;
  late CameraDescription cameraDescription;
  ImageClassificationHelper? imageClassificationHelper;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPages();
    });
  }

  initPages() async {
    if (cameraIsAvailable) {
      // get list available camera
      cameraDescription = (await availableCameras()).first;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: cullentIndex,
        children: <Widget>[
          const HomeScreen(),
          const FileScanScreen(),
          LiveScanScreen(camera: cameraDescription),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: cullentIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            cullentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: "Gallery",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: "Live Scan",
          ),
        ],
      ),
    );
  }
}
