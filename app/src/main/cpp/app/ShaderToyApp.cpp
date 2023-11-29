//
// Created by cw404021@cw404021@alibaba-inc.com on 2023/11/27.
//

#include "ShaderToyApp.h"

ShaderToyApp::ShaderToyApp(JNIEnv *env, jobject javaAssetManager) {
    mAssetManager = std::make_shared<AssetManager>(env, javaAssetManager);
}

ShaderToyApp::~ShaderToyApp() {

}

void ShaderToyApp::create(ANativeWindow *window) {
    mEGLCore = std::make_unique<EGLCore>();
    mEGLCore->createGLEnv(nullptr, window, 0, 0, false);
    mEGLCore->makeCurrent();
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glEnable(GL_BLEND);
    mFilter = std::make_unique<ShaderToyFilter>(mAssetManager, "raining");
    mFilter->init();
}

void ShaderToyApp::change(int width, int height, long time) {
    mWidth = width;
    mHeight = height;
    glViewport(0, 0, width, height);
    mFilter->setWindowSize(width, height);
    mFilter->doFrame(time);
    mEGLCore->swapBuffer();
}

void ShaderToyApp::destroy() {
    mFilter.reset(nullptr);
    mEGLCore.reset(nullptr);
}

void ShaderToyApp::doFrame(long time) {
    if (mEGLCore == nullptr || mFilter == nullptr) {
        return;
    }
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1.0, 1.0, 1.0, 1.0);
    mFilter->doFrame(time);
    mEGLCore->swapBuffer();
}

void ShaderToyApp::setName(const char *name) {
    if (mEGLCore == nullptr || mFilter == nullptr) {
        return;
    }
    mFilter.reset(nullptr);
    mFilter = std::make_unique<ShaderToyFilter>(mAssetManager, std::string(name));
    mFilter->init();
    mFilter->setWindowSize(mWidth, mHeight);
}
