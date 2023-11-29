package com.agil.shadertoy

import android.content.res.AssetManager
import android.os.Handler
import android.os.HandlerThread
import android.view.Surface

class ShaderToyEngine {

    private val shaderToyHandlerThread: HandlerThread =
        HandlerThread("shader-toy", Thread.MAX_PRIORITY).apply {
            start()
        }
    private val shaderToyHandler = Handler(shaderToyHandlerThread.looper)

    private val ctx = ShaderToyApp.getInstance()

    init {
        shaderToyHandler.post {
            nativeInit(ctx.assets)
        }
    }

    fun create(surface: Surface) {
        shaderToyHandler.post {
            nativeCreate(surface)
        }
    }

    fun change(width: Int, height: Int, time: Long) {
        shaderToyHandler.post {
            nativeChange(width, height, time)
        }
    }

    fun destroy() {
        shaderToyHandler.post {
            nativeDestroy()
        }
    }

    fun doFrame(time: Long) {
        shaderToyHandler.post {
            nativeDoFrame(time)
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
    }

}