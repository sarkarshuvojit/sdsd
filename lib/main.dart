import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
            backgroundColor: const Color(0xFFecf0f1),
        appBar: AppBar(
            title: const Text("Slow down, sound down"),
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueGrey
        ),
      body: const SdSd(),
      ),
    );
  }
}

class SdSdController extends GetxController {
    var speed = 0.obs;
    var vol = 0.obs;

    SdSdController() {
        log("Initialising");
    }
}

class SdSd extends StatelessWidget {
  const SdSd({super.key});

  @override
  Widget build(BuildContext context) {
    final SdSdController c = Get.put(SdSdController());

    return Center(
        child: Wrap(
            alignment: WrapAlignment.center,
            direction: Axis.vertical,
            children: [
                Obx(() => Text("Current Speed: ${c.speed} km/h")),
                Obx(() => Text("Current Volume: ${c.vol}%")),
            ],
        ),
    );
  }

}

