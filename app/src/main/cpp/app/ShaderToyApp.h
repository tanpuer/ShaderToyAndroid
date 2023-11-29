//
// Created by cw404021@cw404021@alibaba-inc.com on 2023/11/27.
//

#ifndef SHADERTOYANDROID_SHADERTOYAPP_H
#define SHADERTOYANDROID_SHADERTOYAPP_H

#include "jni.h"
#include "EGLCore.h"
#include "memory"
#include "AssetManager.h"
#include "ShaderToyFilter.h"

class ShaderToyApp {

public:

    ShaderToyApp(JNIEnv *env, jobject javaAssetManager);

    ~ShaderToyApp();

    void create(ANativeWindow *window);

    void change(int width, int height, long time);

    void destroy();

    void doFrame(long time);

    void setName(const char *name);

private:

    std::unique_ptr<EGLCore> mEGLCore;
    std::shared_ptr<AssetManager> mAssetManager;
    std::unique_ptr<ShaderToyFilter> mFilter;
    int mWidth = 0, mHeight = 0;
    std::string name = "raining";

};


#endif //SHADERTOYANDROID_SHADERTOYAPP_H
