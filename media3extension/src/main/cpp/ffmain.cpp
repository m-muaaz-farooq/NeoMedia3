#include <jni.h>
#include "libavcodec/version.h"
#include "libavcodec/defs.h"
#include "ffcommon.h"
#include "utils.h"

jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env;
    if (utils_fields_init(vm) != 0) {
        return -1;
    }
    if (vm->GetEnv(reinterpret_cast<void **>(&env), JNI_VERSION_1_6) != JNI_OK) {
        return -1;
    }
    return JNI_VERSION_1_6;
}


extern "C"
JNIEXPORT jstring JNICALL
Java_com_muaaz_neomedia3_FfmpegLibrary_ffmpegGetVersion(JNIEnv *env, jclass clazz) {
    return env->NewStringUTF(LIBAVCODEC_IDENT);
}

extern "C"
JNIEXPORT jint JNICALL
Java_com_muaaz_neomedia3_FfmpegLibrary_ffmpegGetInputBufferPaddingSize(JNIEnv *env, jclass clazz) {
    return (jint) AV_INPUT_BUFFER_PADDING_SIZE;
}
extern "C"
JNIEXPORT jboolean JNICALL
Java_com_muaaz_neomedia3_FfmpegLibrary_ffmpegHasDecoder(JNIEnv *env, jclass clazz,
                                                        jstring codec_name) {
    return getCodecByName(env, codec_name) != nullptr;
}

// This function is called when the native library is unloaded.
void JNI_OnUnload(JavaVM *vm, void *reserved) {
    utils_fields_free(vm);
}