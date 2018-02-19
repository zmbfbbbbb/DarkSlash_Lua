LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

#-------------- .cpp  .c ---------------------
SRC_SUFFIX := *.cpp *.c
SRC_ROOT := $(LOCAL_PATH)/../../../Classes \
			$(LOCAL_PATH)/
# recursive wildcard
rwildcard = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d)))
SRC_FILES := $(call rwildcard,$(SRC_ROOT)/,$(SRC_SUFFIX))
LOCAL_SRC_FILES := hellolua/main.cpp
LOCAL_SRC_FILES += $(SRC_FILES:$(LOCAL_PATH)/%=%)
#--------------.h  ---------------------

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../../Classes \
					$(LOCAL_PATH)/../../../Classes/reader \
                    $(LOCAL_PATH)/../../../Classes/reader/collider \
                    $(LOCAL_PATH)/../../../Classes/reader/animation \
                    $(LOCAL_PATH)/../../../Classes/reader/dragonbones/cocos2dx \
                    $(LOCAL_PATH)/../../../Classes/reader/dragonbones/armature \
                    $(LOCAL_PATH)/../../../Classes/reader/dragonbones/animation \
                    $(LOCAL_PATH)/../../../Classes/reader/dragonbones/events \
                    $(LOCAL_PATH)/../../../Classes/reader/dragonbones/factories \
                    $(LOCAL_PATH)/../../../Classes/reader/dragonbones/core \
                    $(LOCAL_PATH)/../../../Classes/reader/dragonbones/geom
#-----------------------------------

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END

LOCAL_STATIC_LIBRARIES := cocos2d_lua_static
LOCAL_STATIC_LIBRARIES += creator_reader_lua
# _COCOS_LIB_ANDROID_BEGIN
# _COCOS_LIB_ANDROID_END

include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings/proj.android)
$(call import-module, ./../../runtime-src/Classes/reader)
# _COCOS_LIB_IMPORT_ANDROID_BEGIN
# _COCOS_LIB_IMPORT_ANDROID_END
