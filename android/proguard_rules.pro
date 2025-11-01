# Keep Kotlin Parcelize annotations
-keep class kotlinx.parcelize.** { *; }
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Keep Giphy SDK classes (Jitsi depends on it)
-keep class com.giphy.** { *; }
-dontwarn com.giphy.**

# Keep Jitsi SDK classes
-keep class org.jitsi.meet.** { *; }
-dontwarn org.jitsi.**


# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keep class com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin { *; }
-keep class com.dexterous.flutterlocalnotifications.NotificationService { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Firebase Messaging
-keep class com.google.firebase.messaging.FirebaseMessaging { *; }
-keep class com.google.firebase.messaging.RemoteMessage { *; }
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class * extends com.google.firebase.messaging.FirebaseMessagingService
-dontwarn com.google.firebase.messaging.**
-keep class com.google.firebase.iid.** { *; }
-dontwarn com.google.firebase.iid.**

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Reflection & Annotations
-keepattributes *Annotation*
-keep class androidx.annotation.Keep { *; }
-dontwarn androidx.annotation.Keep
-keepclassmembers class * {
  @android.webkit.JavascriptInterface <methods>;
}

