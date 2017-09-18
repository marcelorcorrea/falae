package com.marcelorcorrea.falae.storage

import android.content.Context
import android.webkit.MimeTypeMap
import java.io.File

/**
 * Created by marcelo on 9/17/17.
 */
object FileHandler {

    fun createUserFolder(context: Context, folderName: String): File {
        val folder = File(context.filesDir, folderName)
        if (!folder.exists()) {
            folder.mkdirs()
        }
        return folder
    }

    fun createImg(folder: File, fileName: String, imgSrc: String) : File{
        val extension = MimeTypeMap.getFileExtensionFromUrl(imgSrc)
        val image = File(folder, "$fileName.$extension")
        return image
    }

    fun deleteUserFolder(context: Context, folderName: String) {
        val folder = File(context.filesDir, folderName)
        folder.delete()
    }
}