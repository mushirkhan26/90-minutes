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
