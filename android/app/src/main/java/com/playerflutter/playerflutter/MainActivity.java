import android.content.Context
import android.provider.MediaStore
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AudioMethodChannel(private val context: Context) {
    fun configureChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.yourapp.audio/methods").setMethodCallHandler { call, result ->
            when (call.method) {
                "getAudioFiles" -> result.success(getAudioFiles())
                else -> result.notImplemented()
            }
        }
    }

    private fun getAudioFiles(): List<Map<String, Any>> {
        val audioList = mutableListOf<Map<String, Any>>()
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Albums.ALBUM_ART
        )
        
        context.contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            null
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID))
                val title = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE))
                val artist = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST))
                val albumArtPath = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Albums.ALBUM_ART))
                
                val thumbnailBase64 = albumArtPath?.let { path ->
                    val bitmap = BitmapFactory.decodeFile(path)
                    bitmap?.let { bitmapToBase64(it) }
                }

                audioList.add(mapOf(
                    "id" to id,
                    "title" to title,
                    "artist" to artist,
                    "thumbnail" to (thumbnailBase64 ?: "")
                ))
            }
        }
        return audioList
    }

    private fun bitmapToBase64(bitmap: Bitmap): String {
        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
        return android.util.Base64.encodeToString(outputStream.toByteArray(), android.util.Base64.DEFAULT)
    }
}

// package com.playerflutter.playerflutter;

// import android.database.Cursor;
// import android.net.Uri;
// import android.os.Bundle;
// import android.provider.MediaStore;
// import android.util.Log;


// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.plugin.common.MethodChannel;
// import java.util.ArrayList;
// import java.util.List;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.audio/files";

//     @Override
//     protected void onCreate(Bundle savedInstanceState) {
//         super.onCreate(savedInstanceState);

//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                 .setMethodCallHandler((call, result) -> {
//                     if (call.method.equals("getAudioFiles")) {
//                         List<String> audioFiles = getAllAudioFiles();
//                         result.success(audioFiles);
//                     } else {
//                         result.notImplemented();
//                     }
//                 });
//     }

//     private List<String> getAllAudioFiles() {

//         List<String> audioFiles = new ArrayList<>();
//         String[] projection = {
//                 MediaStore.Audio.Media.DATA
//         };
//         Uri audioUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
//         Cursor cursor = getContentResolver().query(audioUri, projection, null, null, null);

//         if (cursor != null) {
//             Log.d("ddd1", "audioFiles.toString()");

//             while (cursor.moveToNext()) {
//                 String filePath = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA));
//                 audioFiles.add(filePath);
//             }
//             cursor.close();
//         }
//         Log.d("ddd2", audioFiles.toString());

//         return audioFiles;
//     }
// }



// //package com.playerflutter.playerflutter;
// //
// //import io.flutter.embedding.android.FlutterActivity;
// //
// //public class MainActivity extends FlutterActivity {
// //
// //}
