package com.agil.shadertoy

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.appcompat.widget.AppCompatButton

class ShaderToyActivity : AppCompatActivity() {

    private lateinit var mShaderToyView: ShaderToyView
    private lateinit var mNextBtn: AppCompatButton

    private val shaders = ShaderToyApp.getInstance().assets.list("shader") ?: emptyArray()
    private var index = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_shader_toy)
        mNextBtn = findViewById(R.id.next_btn)
        mShaderToyView = findViewById(R.id.shader_toy_view)
        mNextBtn.setOnClickListener {
            mShaderToyView.setShaderName(shaders[index])
            index++
            if (index >= (shaders.size)) {
                index = 0
            }
        }
    }


}