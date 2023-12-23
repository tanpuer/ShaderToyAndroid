//
// Created by cw404021@alibaba-inc.com on 2023/11/27.
//
#define STB_IMAGE_IMPLEMENTATION

#include "ShaderToyFilter.h"
#include <utility>
#include "matrix_util.h"
#include "gl_utils.h"
#include "stb_image.h"


ShaderToyFilter::ShaderToyFilter(std::shared_ptr<AssetManager> assetManager,
                                 const std::string &name) {
    this->assetManager = assetManager;
    this->name = name;
}

void ShaderToyFilter::init() {
    auto vertexShaderStr = assetManager->readFile("vertex_shader.glsl");
    auto path = "shader/" + name + "/" + name + ".glsl";
    ALOGD("ShaderToyFilter::init %s", path.c_str())
    auto fragmentShaderStr = assetManager->readFile(path.c_str());
    mVertexShader = loadShader(GL_VERTEX_SHADER, vertexShaderStr);
    mFragmentShader = loadShader(GL_FRAGMENT_SHADER, fragmentShaderStr);
    mProgram = createShaderProgram(mVertexShader, mFragmentShader);
    glUseProgram(mProgram);
    ALOGD("program %d %d %d", mProgram, mVertexShader, mFragmentShader)
    checkGLError("ShaderToyFilter::program");
    mVertexShaderStr = vertexShaderStr;
    mFragmentShaderStr = fragmentShaderStr;
    initTextures();
}

ShaderToyFilter::~ShaderToyFilter() {
    glActiveTexture(GL_NONE);
    glDeleteProgram(mProgram);
    glDeleteShader(mVertexShader);
    glDeleteShader(mFragmentShader);
    glDeleteTextures(4, mTextures);
}

void ShaderToyFilter::setWindowSize(int width, int height) {
    mWidth = width;
    mHeight = height;
}

void ShaderToyFilter::doFrame(long time) {
    if (mProgram <= 0) {
        return;
    }
    glUseProgram(mProgram);
    setUniforms(time);
    setAttributes();
    bindTextures();
    draw();
}

void ShaderToyFilter::setUniforms(long timeMills) {
    //1. iResolution
    auto iResolution = glGetUniformLocation(mProgram, "iResolution");
    GLfloat resolution[2] = {(GLfloat) mWidth, (GLfloat) mHeight};
    glUniform2fv(iResolution, 1, resolution);
    //2. iTimeDelta
    auto iTimeDelta = glGetUniformLocation(mProgram, "iTimeDelta");
    glUniform1f(iTimeDelta, 0.0);
    //3. iTime
    auto iTime = glGetUniformLocation(mProgram, "iTime");
    glUniform1f(iTime, (GLfloat) timeMills / 1000);
    //4. iFrame
    auto iFrame = glGetUniformLocation(mProgram, "iFrame");
    mFrameCount++;
    glUniform1i(iFrame, (GLint) mFrameCount);
    //5. iMouse ignore
    GLfloat mouse[3] = {0.0, 0.0, 0.0};
    auto iMouse = glGetUniformLocation(mProgram, "iMouse");
    glUniform3fv(iMouse, 1, mouse);
    //6. iMouseButton ignore

    //7. iViewMatrix
    auto iViewMatrix = glGetUniformLocation(mProgram, "iViewMatrix");
    setIdentityM(&matrix);
    glUniformMatrix4fv(iViewMatrix, 1, GL_FALSE, matrix.m);
    //8. resolution
    glUniform2fv(glGetUniformLocation(mProgram, "resolution"), 1, resolution);
    //9. time
    auto time = glGetUniformLocation(mProgram, "time");
    glUniform1f(time, (GLfloat) timeMills / 1000);
    //10. mouse ignore
    glUniform3fv(glGetUniformLocation(mProgram, "mouse"), 1, mouse);

    checkGLError("ShaderToyFilter::setUniforms");
}

void ShaderToyFilter::setAttributes() {
    aPositionLocation = glGetAttribLocation(mProgram, "aPosition");
    glEnableVertexAttribArray(aPositionLocation);
    glVertexAttribPointer(aPositionLocation, 2, GL_FLOAT, GL_FALSE, 8, vertex);
    aTextureCoordinateLocation = glGetAttribLocation(mProgram, "aTextureCoord");
    glEnableVertexAttribArray(aTextureCoordinateLocation);
    glVertexAttribPointer(aTextureCoordinateLocation, 2, GL_FLOAT, GL_FALSE, 8, imageTexture);
    checkGLError("ShaderToyFilter::setAttributes");
}

void ShaderToyFilter::draw() {
    GLint vertexCount = sizeof(vertex) / (sizeof(vertex[0]) * 2);
    //draw triangles
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
    checkGLError("ShaderToyFilter::draw");
    glDisableVertexAttribArray(aPositionLocation);
    glDisableVertexAttribArray(aTextureCoordinateLocation);
}

void ShaderToyFilter::initTextures() {
    auto textureIndex = 0;
    std::string to_find = "#iChannel";
    size_t found = mFragmentShaderStr.find(to_find);
    while (found != std::string::npos) {
        //#iChannel0 "assets://raining/raining.png"，找到assets://raining/raining.png
        auto startIndex = found + 9;
        while (mFragmentShaderStr.at(startIndex) != '\"') {
            startIndex++;
        }
        auto endIndex = startIndex + 1;
        while (mFragmentShaderStr.at(endIndex) != '\"') {
            endIndex++;
        }
        auto path = mFragmentShaderStr.substr(startIndex + 1, endIndex - startIndex - 1);
        ALOGD("#iChannel path is %s", path.c_str());
        //只支持assets中的图片
        assert(path.find("assets") != std::string::npos);
        auto textureId = createTexture(GL_TEXTURE_2D);
        int x, y, comp;
        auto fileName = path.substr(9, path.length() - 9);
        auto fileloc = fileName.c_str();
        auto imageData = assetManager->readImage(fileloc);
        unsigned char *data = stbi_load_from_memory(imageData->content, imageData->length, &x, &y,
                                                    &comp, STBI_default);
        delete imageData;
        GLuint format = GL_RGB;
        if (comp == 1) {
            format = GL_LUMINANCE;
        } else if (comp == 2) {
            format = GL_LUMINANCE_ALPHA;
        } else if (comp == 3) {
            format = GL_RGB;
        } else if (comp == 4) {
            format = GL_RGBA;
        } else {
            ALOGE("unSupport type %d %s", comp, fileloc);
        }
        if (nullptr != data) {
            glActiveTexture(GL_TEXTURE0 + textureId);
            glBindTexture(GL_TEXTURE_2D, textureId);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTexImage2D(GL_TEXTURE_2D, 0, format, x, y, 0, format, GL_UNSIGNED_BYTE, data);
            glBindTexture(GL_TEXTURE_2D, 0);
            stbi_image_free(data);
            ALOGD("load image success %s", fileloc);
        } else {
            ALOGE("load image fail %s", fileloc);
        }
        checkGLError("ShaderToyFilter::initTextures");
        if (textureId > 0 && textureIndex < 4) {
            mTextures[textureIndex] = textureId;
            textureIndex++;
        }

        found = mFragmentShaderStr.find(to_find, found + 1);
    }
}

void ShaderToyFilter::bindTextures() {
//    uniform sampler2D iChannel0; 得改成 uniform sampler2D iChannel0;
//    uniform sampler2D iChannel1;
//    uniform sampler2D iChannel2;
//    uniform sampler2D iChannel3;
    for (int i = 0; i < 4; ++i) {
        if (mTextures[i] <= 0) {
            return;
        }
        glActiveTexture(GL_TEXTURE0 + mTextures[i]);
        glBindTexture(GL_TEXTURE_2D, mTextures[i]);
        auto iChannel = std::string("iChannel") + std::to_string(i);
        auto iChannelLocation = glGetUniformLocation(mProgram, iChannel.c_str());
        glUniform1i(iChannelLocation, mTextures[i] - 1);
        glBindTexture(GL_TEXTURE_2D, 0);
        checkGLError("ShaderToyFilter::bindTexture");
    }

}