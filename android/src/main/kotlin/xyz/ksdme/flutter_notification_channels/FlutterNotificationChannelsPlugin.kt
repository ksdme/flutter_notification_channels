package xyz.ksdme.flutter_notification_channels

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentResolver
import android.content.Context
import android.content.Context.NOTIFICATION_SERVICE
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlutterNotificationChannelsPlugin */
class FlutterNotificationChannelsPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var context: Context

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_notification_channels")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "areChannelsSupported" -> result.success(areChannelsSupported())
      "createChannel" -> result.success(createChannel(call.arguments as HashMap<String, String>))
      "removeChannel" -> result.success(removeChannel(call.arguments as String))
      else -> result.notImplemented()
    }
  }

  private fun areChannelsSupported(): Boolean {
    return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
  }

  private fun createChannel(args: HashMap<String, String>): Boolean {
    if (!areChannelsSupported()) {
      return true
    }

    // Unpack the arguments.
    val id = args["id"]
    val name = args["name"]
    val description = args["description"]
    val sound = args.getOrDefault("sound", "default")
    val lights = args.getOrDefault("lights", "true")
    val vibrate = args.getOrDefault("vibrate", "true")
    val importance = NotificationManager.IMPORTANCE_HIGH

    // Create the notification channel instance
    val notificationChannel = NotificationChannel(id, name, importance)
    notificationChannel.description = description

    // Set vibration
    if (vibrate == "true") {
      notificationChannel.enableVibration(true)
    }

    // Set lights
    if (lights == "true") {
      notificationChannel.enableLights(true)
    }

    // Set notification sound depending on the option selected, supports
    // null, default or a file name from the raw resources directory. In
    // case null is passed, no sound is set.
    val uri = when (sound) {
      null -> {
        null
      }
      "default" -> {
        RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
      }
      else -> {
        Uri.Builder()
                .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
                .authority(context.packageName)
                .appendPath("raw")
                .appendPath(sound)
                .build()
      }
    }

    if (uri != null) {
      val attributes = AudioAttributes.Builder()
              .setUsage(AudioAttributes.USAGE_NOTIFICATION)
              .setContentType(AudioAttributes.CONTENT_TYPE_UNKNOWN)
              .build()

      notificationChannel.setSound(uri, attributes)
    }

    // Save the notification channel
    val manager = context.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
    manager.createNotificationChannel(notificationChannel)
    return true
  }

  private fun removeChannel(channel: String): Boolean {
    if (!areChannelsSupported()) {
      return true
    }

    val manager = context.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
    manager.deleteNotificationChannel(channel)
    return true
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
