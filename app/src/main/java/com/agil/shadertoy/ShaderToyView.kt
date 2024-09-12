package com.agil.shadertoy

import android.content.Context
import android.util.AttributeSet
import android.view.Choreographer
import android.view.MotionEvent
import android.view.SurfaceHolder
import android.view.SurfaceView

class ShaderToyView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : SurfaceView(context, attrs), SurfaceHolder.Callback, Choreographer.FrameCallback {

    init {
        holder.addCallback(this)
    }

    private val engine = ShaderToyEngine()
    private var created = false
    private var start = System.currentTimeMillis()

    override fun surfaceCreated(holder: SurfaceHolder) {
        engine.create(holder.surface)
        created = true
        Choreographer.getInstance().postFrameCallback(this)
    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        engine.change(width, height, System.currentTimeMillis() - start)
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        Choreographer.getInstance().removeFrameCallback(this)
        created = false
        engine.destroy()
    }

    override fun doFrame(frameTimeNanos: Long) {
        if (created) {
            engine.doFrame(System.currentTimeMillis() - start)
            Choreographer.getInstance().postFrameCallback(this)
        }
    }

    fun release() {
        engine.release()
    }

    fun setShaderName(name: String) {
        engine.setShaderName(name)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        engine.setTouch(event.x, event.y)
        return true
    }

}