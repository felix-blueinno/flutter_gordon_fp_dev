# flutter_gordon_dev

## Introduction

This flutter project is using Tensor Flow Lite (tflite) classification model to classify masked face in live camera.

The model was trained on Teachable Machine using <a href="https://www.kaggle.com/prithwirajmitra/covid-face-mask-detection-dataset">COVID Face Mask Detection Dataset</a> found on https://www.kaggle.com/.

<span style="color:red">Caution: wearing glasses may classify as 'wearing mask'...</span>

Find the model and labels in the assets folder.

<br>

## Setup:

1. Run `flutter pub get` to install tflite_flutter, tflite_flutter_helper and camera packages.

2. Follow <a href="https://pub.dev/packages/tflite_flutter#important-initial-setup--add-dynamic-libraries-to-your-app">initial setup guideline</a> to prepare tflite for Android/iOS.

3. Follow <a href="https://pub.dev/packages/camera#installation">initial setup guideline</a> to prepare camera permission on Android/iOS.

4. If encounter iOS build error: "Framework not found TensorFlowLiteC", check <a href="https://github.com/am15h/tflite_flutter_plugin/issues/163#issuecomment-984424456"> solution</a>:
