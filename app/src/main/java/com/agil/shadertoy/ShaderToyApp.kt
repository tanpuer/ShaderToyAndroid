package com.agil.shadertoy

import android.app.Application

class ShaderToyApp : Application() {

    override fun onCreate() {
        super.onCreate()
        mInstance = this
    }

    companion object {
        private lateinit var mInstance: ShaderToyApp

        fun getInstance(): ShaderToyApp {
            return mInstance
        }
    }
}