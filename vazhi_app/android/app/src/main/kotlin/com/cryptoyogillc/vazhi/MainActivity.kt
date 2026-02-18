package com.cryptoyogillc.vazhi

import android.app.ActivityManager
import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.cryptoyogillc.vazhi/device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getMemoryInfo" -> {
                        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val memInfo = ActivityManager.MemoryInfo()
                        activityManager.getMemoryInfo(memInfo)

                        val info = mapOf(
                            "totalRam" to (memInfo.totalMem / (1024 * 1024)),
                            "availableRam" to (memInfo.availMem / (1024 * 1024)),
                            "lowMemory" to memInfo.lowMemory,
                            "threshold" to (memInfo.threshold / (1024 * 1024))
                        )
                        result.success(info)
                    }

                    "findModelInDownloads" -> {
                        val filename = call.argument<String>("filename")!!
                        result.success(findModelInDownloads(filename))
                    }

                    "saveModelToDownloads" -> {
                        val filename = call.argument<String>("filename")!!
                        val sourcePath = call.argument<String>("sourcePath")!!
                        Thread {
                            try {
                                val path = saveModelToDownloads(filename, sourcePath)
                                runOnUiThread { result.success(path) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("SAVE_FAILED", e.message, null) }
                            }
                        }.start()
                    }

                    "deleteModelFromDownloads" -> {
                        val filename = call.argument<String>("filename")!!
                        val deleted = deleteModelFromDownloads(filename)
                        result.success(deleted)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    /// Find a model file in Downloads/VAZHI/ and return its real file path.
    /// Returns null if not found.
    private fun findModelInDownloads(filename: String): String? {
        // Strategy 1: Direct file path (works on most devices)
        val directPath = "${Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)}/VAZHI/$filename"
        if (File(directPath).let { it.exists() && it.canRead() }) {
            return directPath
        }

        // Strategy 2: MediaStore query (Android 10+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                val uri = queryMediaStoreFile(filename) ?: return null
                // Try to get real path from DATA column
                contentResolver.query(
                    uri,
                    arrayOf(MediaStore.MediaColumns.DATA),
                    null, null, null
                )?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val path = cursor.getString(0)
                        if (path != null && File(path).let { it.exists() && it.canRead() }) {
                            return path
                        }
                    }
                }
            } catch (_: Exception) {}
        }

        return null
    }

    /// Save a model file from sourcePath to Downloads/VAZHI/ via MediaStore.
    /// Returns the real file path of the saved file.
    private fun saveModelToDownloads(filename: String, sourcePath: String): String {
        val sourceFile = File(sourcePath)
        if (!sourceFile.exists()) throw Exception("Source file not found: $sourcePath")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+: Use MediaStore
            // Delete existing entry first to avoid duplicates
            deleteModelFromDownloads(filename)

            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, filename)
                put(MediaStore.MediaColumns.MIME_TYPE, "application/octet-stream")
                put(MediaStore.MediaColumns.RELATIVE_PATH, "Download/VAZHI")
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

            val uri = contentResolver.insert(
                MediaStore.Downloads.EXTERNAL_CONTENT_URI, values
            ) ?: throw Exception("Failed to create MediaStore entry")

            // Copy file content
            contentResolver.openOutputStream(uri)?.use { out ->
                FileInputStream(sourceFile).use { input ->
                    val buffer = ByteArray(65536)
                    var bytesRead: Int
                    while (input.read(buffer).also { bytesRead = it } != -1) {
                        out.write(buffer, 0, bytesRead)
                    }
                }
            } ?: throw Exception("Failed to open output stream")

            // Mark as complete
            val updateValues = ContentValues().apply {
                put(MediaStore.MediaColumns.IS_PENDING, 0)
            }
            contentResolver.update(uri, updateValues, null, null)

            // Get real file path
            contentResolver.query(
                uri,
                arrayOf(MediaStore.MediaColumns.DATA),
                null, null, null
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val path = cursor.getString(0)
                    if (path != null) return path
                }
            }

            // Fallback: construct known path
            return "${Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)}/VAZHI/$filename"
        } else {
            // Android 9 and below: Direct file copy
            val destDir = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                "VAZHI"
            )
            destDir.mkdirs()
            val destFile = File(destDir, filename)
            sourceFile.copyTo(destFile, overwrite = true)
            return destFile.absolutePath
        }
    }

    /// Delete a model file from Downloads/VAZHI/.
    private fun deleteModelFromDownloads(filename: String): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val uri = queryMediaStoreFile(filename) ?: return false
            return try {
                contentResolver.delete(uri, null, null) > 0
            } catch (_: Exception) {
                false
            }
        } else {
            val file = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                "VAZHI/$filename"
            )
            return file.delete()
        }
    }

    /// Query MediaStore for a file in Downloads/VAZHI/ by filename.
    private fun queryMediaStoreFile(filename: String): Uri? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null

        val selection = "${MediaStore.MediaColumns.RELATIVE_PATH} = ? AND ${MediaStore.MediaColumns.DISPLAY_NAME} = ?"
        val selectionArgs = arrayOf("Download/VAZHI/", filename)

        contentResolver.query(
            MediaStore.Downloads.EXTERNAL_CONTENT_URI,
            arrayOf(MediaStore.MediaColumns._ID),
            selection,
            selectionArgs,
            null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                val id = cursor.getLong(0)
                return Uri.withAppendedPath(
                    MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                    id.toString()
                )
            }
        }
        return null
    }
}
