# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# WebView Flutter
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Youtube Player Iframe
-keep class com.pierfrancescosoffritti.androidyoutubeplayer.** { *; }
-keep class androidx.lifecycle.** { *; }

# Prevent R8 from stripping needed classes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Retain generic type information for reflection
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Ensure JavascriptInterface methods are kept
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep all classes in the youtube_player_iframe package
-keep class com.google.android.youtube.player.** { *; }
