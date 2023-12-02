#include <jni.h>
#include <base/native_log.h>
#include <iterator>
#include "android/native_window_jni.h"
#include "ShaderToyApp.h"

const char *ShaderToyEngine = "com/agil/shadertoy/ShaderToyEngine";
jobject globalAssets = nullptr;
static ShaderToyApp *app = nullptr;

extern "C" JNIEXPORT void JNICALL
native_init(JNIEnv *env, jobject instance, jobject javaAssetManager) {
    ALOGD("native_init")
    globalAssets = env->NewGlobalRef(javaAssetManager);
    app = new ShaderToyApp(env, globalAssets);
}

extern "C" JNIEXPORT void JNICALL
native_create(JNIEnv *env, jobject instance, jobject javaSurface) {
    ALOGD("native_create")
    if (app != nullptr) {
        app->create(ANativeWindow_fromSurface(env, javaSurface));
    }
}

extern "C" JNIEXPORT void JNICALL
native_change(JNIEnv *env, jobject instance, jint width, jint height, jlong time) {
    ALOGD("native_change")
    if (app != nullptr) {
        app->change(width, height, time);
    }
}

extern "C" JNIEXPORT void JNICALL
native_destroy(JNIEnv *env, jobject instance) {
    ALOGD("native_destroy")
    if (app != nullptr) {
        app->destroy();
    }
}

extern "C" JNIEXPORT void JNICALL
native_do_frame(JNIEnv *env, jobject instance, jlong time) {
    if (app != nullptr) {
        app->doFrame(time);
    }
}

extern "C" JNIEXPORT void JNICALL
native_release(JNIEnv *env, jobject instance, jlong time) {
    ALOGD("native_release")
    env->DeleteGlobalRef(globalAssets);
    globalAssets = nullptr;
    delete app;
    app = nullptr;
}

extern "C" JNIEXPORT void JNICALL
native_set_shader_name(JNIEnv *env, jobject instance, jstring name) {
    ALOGD("native_set_shader_name")
    if (app != nullptr) {
        auto nameStr = env->GetStringUTFChars(name, nullptr);
        app->setName(nameStr);
        env->ReleaseStringUTFChars(name, nameStr);
    }
}

static JNINativeMethod g_RenderMethods[] = {
        {"nativeInit",          "(Landroid/content/res/AssetManager;)V", (void *) native_init},
        {"nativeCreate",        "(Landroid/view/Surface;)V",             (void *) native_create},
        {"nativeChange",        "(IIJ)V",                                (void *) native_change},
        {"nativeDestroy",       "()V",                                   (void *) native_destroy},
        {"nativeDoFrame",       "(J)V",                                  (void *) native_do_frame},
        {"nativeRelease",       "()V",                                   (void *) native_release},
        {"nativeSetShaderName", "(Ljava/lang/String;)V",                 (void *) native_set_shader_name},
};

static int RegisterNativeMethods(JNIEnv *env, const char *className, JNINativeMethod *nativeMethods,
                                 int methodNum) {
    ALOGD("RegisterNativeMethods start %s", className)
    jclass clazz = env->FindClass(className);
    if (clazz == nullptr) {
        ALOGD("RegisterNativeMethods fail clazz == null")
        return JNI_FALSE;
    }
    if (env->RegisterNatives(clazz, nativeMethods, methodNum) < 0) {
        ALOGD("RegisterNativeMethods fail")
        return JNI_FALSE;
    }
    return JNI_TRUE;
}

static void UnRegisterNativeMethods(JNIEnv *env, const char *className) {
    ALOGD("UnRegisterNativeMethods start")
    jclass clazz = env->FindClass(className);
    if (clazz == nullptr) {
        ALOGD("UnRegisterNativeMethods fail clazz == null")
    }
    env->UnregisterNatives(clazz);
}

extern "C" jint JNI_OnLoad(JavaVM *jvm, void *p) {
    JNIEnv *env = nullptr;
    if (jvm->GetEnv((void **) (&env), JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }
    RegisterNativeMethods(env, ShaderToyEngine, g_RenderMethods, std::size(g_RenderMethods));
    return JNI_VERSION_1_6;
}

extern "C" void JNI_OnUnload(JavaVM *jvm, void *p) {
    ALOGD("JNI_OnUnload")
    JNIEnv *env = nullptr;
    if (jvm->GetEnv((void **) env, JNI_VERSION_1_6) != JNI_OK) {
        return;
    }
    UnRegisterNativeMethods(env, ShaderToyEngine);
}