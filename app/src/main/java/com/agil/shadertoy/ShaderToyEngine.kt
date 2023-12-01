package com.agil.shadertoy

import android.content.res.AssetManager
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.view.Surface
import java.util.concurrent.atomic.AtomicBoolean

class ShaderToyEngine {

    private val shaderToyHandlerThread: HandlerThread =
        HandlerThread("shader-toy", Thread.MAX_PRIORITY).apply {
            start()
        }
    private val shaderToyHandler = Handler(shaderToyHandlerThread.looper)

    private val ctx = ShaderToyApp.getInstance()
    private var finishDraw = AtomicBoolean(true)

    init {
        shaderToyHandler.post {
            nativeInit(ctx.assets)
        }
    }

    fun create(surface: Surface) {
        shaderToyHandler.post {
            val start = System.currentTimeMillis()
            nativeCreate(surface)
            Log.d(TAG, "create cost ${System.currentTimeMillis() - start}")
        }
    }

    fun change(width: Int, height: Int, time: Long) {
        shaderToyHandler.post {
            val start = System.currentTimeMillis()
            nativeChange(width, height, time)
            Log.d(TAG, "change cost ${System.currentTimeMillis() - start}")
        }
    }

    fun destroy() {
        shaderToyHandler.post {
            nativeDestroy()
        }
    }

    fun doFrame(time: Long) {
        if (!finishDraw.get()) {
            Log.d(TAG, "doFrame ignore current vysnc draw")
            return
        }
        shaderToyHandler.post {
            finishDraw.set(false)
            val start = System.currentTimeMillis()
            nativeDoFrame(time)
            Log.d(TAG, "doFrame cost ${System.currentTimeMillis() - start}")
            finishDraw.set(true)
        }
    }

    fun release() {
        shaderToyHandler.post {
            nativeRelease()
        }
        shaderToyHandlerThread.quitSafely()
    }

    fun setShaderName(name: String) {
        shaderToyHandler.post {
            nativeSetShaderName(name)
        }
    }

    private external fun nativeInit(assetManager: AssetManager)
    private external fun nativeCreate(surface: Surface);
    private external fun nativeChange(width: Int, height: Int, time: Long)
    private external fun nativeDestroy()
    private external fun nativeDoFrame(time: Long)
    private external fun nativeRelease()
    private external fun nativeSetShaderName(name: String)

    companion object {
        init {
            System.loadLibrary("shadertoy")
        }

        private const val TAG = "ShaderToyEngine"
    }

}