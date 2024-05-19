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
    mFilter = std::make_unique<ShaderToyFilter>(mAssetManager, name);
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
    this->name = std::string(name);
    mFilter = std::make_unique<ShaderToyFilter>(mAssetManager, this->name);
    mFilter->init();
    mFilter->setWindowSize(mWidth, mHeight);
}
