package de.appternity.solar_planner

import android.content.Context
import android.net.Uri
import android.provider.DocumentsContract
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Implements the "solar_planner/sync" MethodChannel.
 *
 * On Android the sync folder is a Storage Access Framework tree URI
 * (content://...), so plain file I/O is not possible. This channel exposes
 * the SyncBackend operations against DocumentFile / ContentResolver.
 */
class MainActivity : FlutterActivity() {
    private val CHANNEL = "solar_planner/sync"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "resolveChild" -> result.success(
                        resolveChild(
                            call.argument<String>("parent")!!,
                            call.argument<String>("name")!!
                        )
                    )
                    "listFiles" -> result.success(
                        listFiles(call.argument<String>("dir")!!)
                    )
                    "readFile" -> result.success(
                        readFile(call.argument<String>("uri")!!)
                    )
                    "writeFile" -> {
                        writeFile(
                            call.argument<String>("uri")!!,
                            call.argument<ByteArray>("data")!!
                        )
                        result.success(null)
                    }
                    "createFile" -> result.success(
                        createFile(
                            call.argument<String>("parent")!!,
                            call.argument<String>("name")!!,
                            call.argument<String>("mimeType") ?: "application/octet-stream"
                        )
                    )
                    "statFile" -> result.success(
                        statFile(call.argument<String>("uri")!!)
                    )
                    "deleteFile" -> {
                        deleteFile(call.argument<String>("uri")!!)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("SYNC_ERROR", e.message, null)
            }
        }
    }

    private fun context(): Context = applicationContext

    private fun treeUri(uri: String): Uri = Uri.parse(uri)

    private fun documentFile(uri: String): DocumentFile? {
        val u = treeUri(uri)
        return if (DocumentsContract.isTreeUri(u)) {
            DocumentFile.fromTreeUri(context(), u)
        } else {
            DocumentFile.fromSingleUri(context(), u)
        }
    }

    private fun resolveChild(parent: String, name: String): String? {
        val parentFile = documentFile(parent) ?: return null
        for (child in parentFile.listFiles()) {
            if (child.name == name) return child.uri.toString()
        }
        return null
    }

    private fun listFiles(dir: String): List<String> {
        val dirFile = documentFile(dir) ?: return emptyList()
        return dirFile.listFiles().map { it.name ?: "" }
    }

    private fun readFile(uri: String): ByteArray {
        val file = documentFile(uri) ?: throw Exception("File not found: $uri")
        return context().contentResolver.openInputStream(file.uri)!!.use { it.readBytes() }
    }

    private fun writeFile(uri: String, data: ByteArray) {
        val file = documentFile(uri) ?: throw Exception("File not found: $uri")
        context().contentResolver.openOutputStream(file.uri)!!.use { it.write(data) }
    }

    private fun createFile(parent: String, name: String, mimeType: String): String {
        val parentFile = documentFile(parent)
            ?: throw Exception("Parent not found: $parent")
        val uri = DocumentsContract.createDocument(
            context().contentResolver, parentFile.uri, mimeType, name
        ) ?: throw Exception("createDocument failed for $name")
        return uri.toString()
    }

    private fun statFile(uri: String): Map<String, Any?>? {
        val file = documentFile(uri) ?: return null
        val size = file.length()
        val mtime = file.lastModified()
        return mapOf("size" to size, "mtime" to mtime)
    }

    private fun deleteFile(uri: String) {
        val file = documentFile(uri) ?: return
        file.delete()
    }
}
