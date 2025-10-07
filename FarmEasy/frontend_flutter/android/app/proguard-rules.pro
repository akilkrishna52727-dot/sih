# Keep TensorFlow Lite classes and GPU delegate to avoid R8 removing them
-keep class org.tensorflow.lite.** { *; }
-keepclassmembers class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.**
