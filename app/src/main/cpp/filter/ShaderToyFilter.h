#pragma once

#include "AssetManager.h"
#include "memory"
#include "GLES3/gl3.h"
#include "matrix_util.h"
#include "string"

static GLfloat vertex[] = {
        1.0f, 1.0f,
        -1.0f, 1.0f,
        -1.0f, -1.0f,
        1.0f, 1.0f,
        -1.0f, -1.0f,
        1.0f, -1.0f,
};

static GLfloat imageTexture[] = {
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f
};

class ShaderToyFilter {

public:

    ShaderToyFilter(std::shared_ptr<AssetManager> assetManager, const std::string& name);

    ~ShaderToyFilter();

    virtual void init();

    virtual void setWindowSize(int width, int height);

    virtual void doFrame(long timeMills);

    virtual void setTouch(float x, float y);

protected:

    int mWidth = 0, mHeight = 0;

    std::string mVertexShaderStr = "", mFragmentShaderStr = "";
    GLuint mVertexShader = 0, mFragmentShader = 0;
    GLuint mProgram = 0;
    GLuint mFrameCount = 0;
    ESMatrix matrix = ESMatrix();
    GLuint aPositionLocation = 0, aTextureCoordinateLocation = 0;

    /**
     * 最多支持4个纹理
     */
    GLuint mTextures[4] = {0, 0, 0, 0};

    virtual void initTextures();

    virtual void setUniforms(long timeMills);

    virtual void setAttributes();

    virtual void bindTextures();

    virtual void draw();

private:
    std::shared_ptr<AssetManager> assetManager = nullptr;
    std::string name;

    float x = 0.0f, y = 0.0f;
    float transX = 0.0f, transY = 0.0f;
};
