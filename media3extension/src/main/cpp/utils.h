//
// Created by muaaz on 3/31/25.
//

#ifndef NEOMEDIA3_UTILS_H
#define NEOMEDIA3_UTILS_H

#include <jni.h>

/**
 * Initializes the fields struct that keeps handles to MediaFile's internal fields in order to read/write to them.
 */
int utils_fields_init(JavaVM *vm);

/**
 * Frees resources created in utils_fields_init(JavaVM *vm).
 */
void utils_fields_free(JavaVM *vm);

/**
 * Returns a pointer to JNIEnv struct to use in various JNI-specific functions.
 */
JNIEnv *utils_get_env();

/**
 * Helper function for calling an instance void methods of Java objects with arbitrary arguments.
 *
 * @param instance Java object to call a method on
 * @param methodID an ID of a method to call
 * @param ... arguments to pass to the method
 */
void utils_call_instance_method_void(JNIEnv *env, jobject instance, jmethodID methodID, ...);

struct fields {
    struct {
        jclass clazz;
        jmethodID onMediaInfoFoundID;
        jmethodID onVideoStreamFoundID;
        jmethodID onAudioStreamFoundID;
        jmethodID onSubtitleStreamFoundID;
        jmethodID onErrorID;
    } MediaInfoBuilder;
};

extern struct fields fields;

#endif //NEOMEDIA3_UTILS_H
