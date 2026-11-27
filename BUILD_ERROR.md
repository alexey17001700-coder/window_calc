# Ошибка сборки window_calc

Прогон: 46013205464
Дата: 2026-11-27 14:16 UTC

```

Running Gradle task 'assembleRelease'...                        
Your project is configured with Android NDK 23.1.7779620, but the following plugin(s) depend on a different Android NDK version:
- flutter_plugin_android_lifecycle requires Android NDK 27.0.12077973
- image_picker_android requires Android NDK 27.0.12077973
- open_filex requires Android NDK 27.0.12077973
- package_info_plus requires Android NDK 27.0.12077973
- path_provider_android requires Android NDK 27.0.12077973
- share_plus requires Android NDK 27.0.12077973
- shared_preferences_android requires Android NDK 27.0.12077973
Fix this issue by using the highest Android NDK version (they are backward compatible).
Add the following to /home/runner/work/window_calc/window_calc/android/app/build.gradle:

    android {
        ndkVersion = "27.0.12077973"
        ...
    }

Checking the license for package Android SDK Platform 33 in /usr/local/lib/android/sdk/licenses
License for package Android SDK Platform 33 accepted.
Preparing "Install Android SDK Platform 33 (revision 3)".
"Install Android SDK Platform 33 (revision 3)" ready.
Installing Android SDK Platform 33 in /usr/local/lib/android/sdk/platforms/android-33
"Install Android SDK Platform 33 (revision 3)" complete.
"Install Android SDK Platform 33 (revision 3)" finished.
lib/window_visual.dart:283:21: Error: No named parameter with the name 'glassLabel'.
                    glassLabel: widget.glassLabel,
                    ^^^^^^^^^^
lib/window_visual.dart:1421:3: Context: Found this candidate, but the arguments don't match.
  _BalconyPainter({
  ^^^^^^^^^^^^^^^
lib/window_visual.dart:333:19: Error: No named parameter with the name 'glassLabel'.
                  glassLabel: widget.glassLabel,
                  ^^^^^^^^^^
lib/window_visual.dart:795:3: Context: Found this candidate, but the arguments don't match.
  _GostPainter({
  ^^^^^^^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.24.0-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 1m 57s
Running Gradle task 'assembleRelease'...                          117.8s
Gradle task assembleRelease failed with exit code 1

Running Gradle task 'assembleRelease'...                        
Your project is configured with Android NDK 23.1.7779620, but the following plugin(s) depend on a different Android NDK version:
- flutter_plugin_android_lifecycle requires Android NDK 27.0.12077973
- image_picker_android requires Android NDK 27.0.12077973
- open_filex requires Android NDK 27.0.12077973
- package_info_plus requires Android NDK 27.0.12077973
- path_provider_android requires Android NDK 27.0.12077973
- share_plus requires Android NDK 27.0.12077973
- shared_preferences_android requires Android NDK 27.0.12077973
Fix this issue by using the highest Android NDK version (they are backward compatible).
Add the following to /home/runner/work/window_calc/window_calc/android/app/build.gradle:

    android {
        ndkVersion = "27.0.12077973"
        ...
    }

lib/window_visual.dart:283:21: Error: No named parameter with the name 'glassLabel'.
                    glassLabel: widget.glassLabel,
                    ^^^^^^^^^^
lib/window_visual.dart:1421:3: Context: Found this candidate, but the arguments don't match.
  _BalconyPainter({
  ^^^^^^^^^^^^^^^
lib/window_visual.dart:333:19: Error: No named parameter with the name 'glassLabel'.
                  glassLabel: widget.glassLabel,
                  ^^^^^^^^^^
lib/window_visual.dart:795:3: Context: Found this candidate, but the arguments don't match.
  _GostPainter({
  ^^^^^^^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.24.0-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 1m 38s
Running Gradle task 'assembleRelease'...                           98.8s
Gradle task assembleRelease failed with exit code 1

Running Gradle task 'assembleRelease'...                        
Your project is configured with Android NDK 23.1.7779620, but the following plugin(s) depend on a different Android NDK version:
- flutter_plugin_android_lifecycle requires Android NDK 27.0.12077973
- image_picker_android requires Android NDK 27.0.12077973
- open_filex requires Android NDK 27.0.12077973
- package_info_plus requires Android NDK 27.0.12077973
- path_provider_android requires Android NDK 27.0.12077973
- share_plus requires Android NDK 27.0.12077973
- shared_preferences_android requires Android NDK 27.0.12077973
Fix this issue by using the highest Android NDK version (they are backward compatible).
Add the following to /home/runner/work/window_calc/window_calc/android/app/build.gradle:

    android {
        ndkVersion = "27.0.12077973"
        ...
    }

lib/window_visual.dart:283:21: Error: No named parameter with the name 'glassLabel'.
                    glassLabel: widget.glassLabel,
                    ^^^^^^^^^^
lib/window_visual.dart:1421:3: Context: Found this candidate, but the arguments don't match.
  _BalconyPainter({
  ^^^^^^^^^^^^^^^
lib/window_visual.dart:333:19: Error: No named parameter with the name 'glassLabel'.
                  glassLabel: widget.glassLabel,
                  ^^^^^^^^^^
lib/window_visual.dart:795:3: Context: Found this candidate, but the arguments don't match.
  _GostPainter({
  ^^^^^^^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildRelease'.
> Process 'command '/opt/hostedtoolcache/flutter/stable-3.24.0-x64/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 1m 38s
Running Gradle task 'assembleRelease'...                           98.9s
Gradle task assembleRelease failed with exit code 1
```
