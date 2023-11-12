import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:localmltester/helper/isolate_inference.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassificationHelper {
  static const modelPath =
      'assets/tflitemodels/mobilenet_quant.tflite'; //path指定注意
  static const labelsPath = 'assets/tflitemodels/labels.txt'; //path指定注意

  late final Interpreter interpreter;
  late final List<String> labels;
  late final IsolateInference isolateInference;
  late Tensor inputTensor;
  late Tensor outputTensor;

  // モデルの読み込み
  Future<void> loadModel() async {
    final options = InterpreterOptions();
    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    } else if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }
    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;
    log('Interpreter loaded successfully');
  }

  // ラベルの読み込み
  Future<void> loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelsPath);
    labels = labelTxt.split('\n');
  }

  //ラベルとモデルの読み込み
  Future<void> initHelper() async {
    loadLabels();
    loadModel();
    isolateInference = IsolateInference();
    await isolateInference.start();
  }

  // 推論を行う、結果として各ラベルとその確率を返す
  Future<Map<String, double>> inference(InferenceModel inferenceModel) async {
    ReceivePort responsePort = ReceivePort();
    isolateInference.sendPort
        .send(inferenceModel..responsePort = responsePort.sendPort);
    // get inference result.
    var results = await responsePort.first;
    return results;
  }

  // 静止画像を使用して推論を行う
  Future<Map<String, double>> inferenceCameraFrame(
      CameraImage cameraImage) async {
    var isolateModel = InferenceModel(cameraImage, null, interpreter.address,
        labels, inputTensor.shape, outputTensor.shape);
    return inference(isolateModel);
  }

  // カメラのフレームを使用し推論を行う
  Future<Map<String, double>> inferenceImage(Image image) async {
    var isolateModel = InferenceModel(null, image, interpreter.address, labels,
        inputTensor.shape, outputTensor.shape);
    return inference(isolateModel);
  }

  //分離された推論を閉じる
  Future<void> close() async {
    isolateInference.close();
  }
}
