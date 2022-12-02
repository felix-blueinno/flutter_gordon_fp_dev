# flutter_gordon_dev

## Introduction

This flutter project is using Tensor Flow Lite (tflite) classification model to classify masked face in live camera.

The model was trained on Teachable Machine using <a href="https://www.kaggle.com/prithwirajmitra/covid-face-mask-detection-dataset">COVID Face Mask Detection Dataset</a> found on https://www.kaggle.com/.

<span style="color:red">Caution: wearing glasses may classify as 'wearing mask'...</span>

Find the model and labels in the assets folder.

<br>

## Setup:

1. Run `flutter pub get` to install tflite_flutter, tflite_flutter_helper and camera packages.

2. Run `sh install.sh` (Linux/Mac) or `install.bat` (Windows),
   <a href="https://pub.dev/packages/tflite_flutter#important-initial-setup--add-dynamic-libraries-to-your-app">reference</a>

3. Follow <a href="https://pub.dev/packages/camera#installation">initial setup guideline</a> to prepare camera permission on Android/iOS.

4. If encounter iOS build error: "Framework not found TensorFlowLiteC", check <a href="https://github.com/am15h/tflite_flutter_plugin/issues/163#issuecomment-984424456"> solution</a>:

## Android build error emerged from Flutter 3.0:

Error message:

```bash
e: /Users/felixwong/Developer/flutter/.pub-cache/hosted/pub.dartlang.org/tflite_flutter_helper-0.3.1/android/src/main/kotlin/com/tfliteflutter/tflite_flutter_helper/TfliteFlutterHelperPlugin.kt: (43, 1): Class 'TfliteFlutterHelperPlugin' is not abstract and does not implement abstract member public abstract fun onRequestPermissionsResult(p0: Int, p1: Array<(out) String!>, p2: IntArray): Boolean defined in io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
e: /Users/felixwong/Developer/flutter/.pub-cache/hosted/pub.dartlang.org/tflite_flutter_helper-0.3.1/android/src/main/kotlin/com/tfliteflutter/tflite_flutter_helper/TfliteFlutterHelperPlugin.kt: (143, 2): 'onRequestPermissionsResult' overrides nothing

FAILURE: Build failed with an exception.

- What went wrong:
Execution failed for task ':tflite_flutter_helper:compileDebugKotlin'.

> Compilation error. See log for more details
```

Solution:

1.  Find the android file of `tflite_flutter_helper` package:

    package_version: 0.3.1

    `~/Developer/flutter/.pub-cache/hosted/pub.dartlang.org/tflite_flutter_helper-0.3.1/android/src/main/kotlin/com/tfliteflutter/tflite_flutter_helper/TfliteFlutterHelperPlugin.kt`

2.  Replace original `onRequestPermissionsResult` function with the following:

```kotlin
              override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>,
              										grantResults: IntArray): Boolean {
              	when (requestCode) {
              		AUDIO_RECORD_PERMISSION_CODE -> {
              			if (grantResults != null) {
              				permissionToRecordAudio = grantResults.isNotEmpty() &&
              						grantResults[0] == PackageManager.PERMISSION_GRANTED
              			}
              			completeInitializeRecorder()
              			return true
              		}
              	}
              	return false
              }
```
