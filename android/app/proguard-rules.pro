# --- ML Kit Text Recognition ---
# Le plugin google_mlkit_text_recognition reference les modules chinois,
# devanagari, japonais et coreen meme si on ne les embarque pas.
# On demande a R8 d'ignorer ces classes absentes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text** { *; }

# --- Flutter / plugins courants ---
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**
