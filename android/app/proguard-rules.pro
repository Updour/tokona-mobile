# Flutter & Android Play Core
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# SQFlite
-keep class com.tekartik.sqflite.** { *; }

# Local Auth / Biometrics
-keep class androidx.biometric.** { *; }

# Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
