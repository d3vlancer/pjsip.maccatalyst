# Include core PJSIP build configurations
include ../../../../../build.mak
include ../../../../../build/common.mak
include ../../../../../version.mak
include ../../../Makefile.mk

SWIG_MODULE     = pjsua2
MAUI_NAMESPACE  = pjsua2maui.$(SWIG_MODULE)
BASE_OUTPUT_DIR = ./pjsua2maui/Platforms

# Global SWIG flags for C#
SWIG_CS_FLAGS   = -csharp -c++ -w312,314,325,362,383,389,401,503 \
                  -namespace $(MAUI_NAMESPACE) \
                  -I$(PJ_DIR)/pjlib/include \
                  -I$(PJ_DIR)/pjlib-util/include \
                  -I$(PJ_DIR)/pjmedia/include \
                  -I$(PJ_DIR)/pjsip/include

SWIG_INPUTS     = $(SWIG_INTERFACE_FILES)

# Include paths required to compile the generated wrapper
INCLUDES        = -I$(PJ_DIR)/pjlib/include \
                  -I$(PJ_DIR)/pjlib-util/include \
                  -I$(PJ_DIR)/pjmedia/include \
                  -I$(PJ_DIR)/pjsip/include \
                  -I$(PJ_DIR)/pjsdp/include

# Dynamic list of all core PJSIP static libraries linked into the final bundle
PJSIP_LIBS      = -L$(PJ_DIR)/pjlib/lib \
                  -L$(PJ_DIR)/pjlib-util/lib \
                  -L$(PJ_DIR)/pjmedia/lib \
                  -L$(PJ_DIR)/pjsip/lib \
                  -L$(PJ_DIR)/pjsdp/lib \
                  -lpjsua2-$(TARGET_NAME) \
                  -lpjsua-$(TARGET_NAME) \
                  -lpjsip-ua-$(TARGET_NAME) \
                  -lpjsip-simple-$(TARGET_NAME) \
                  -lpjsip-$(TARGET_NAME) \
                  -lpjmedia-codec-$(TARGET_NAME) \
                  -lpjmedia-videodev-$(TARGET_NAME) \
                  -lpjmedia-audiodev-$(TARGET_NAME) \
                  -lpjmedia-$(TARGET_NAME) \
                  -lpjlib-util-$(TARGET_NAME) \
                  -lsdp-$(TARGET_NAME) \
                  -lpj-$(TARGET_NAME)

.PHONY: all maui android ios maccatalyst clean

all: maui

maui: maui-android maui-ios maui-maccatalyst

# --- TARGET: ANDROID (.so) ---
android:
	@echo "========================================================="
	@echo " Generating C# stubs and C++ wrapper for Android...      "
	@echo "========================================================="
	mkdir -p $(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE)
	$(APP_SWIG) $(SWIG_CS_FLAGS) \
		-DCC_HAS_INT64=1 \
		-D_ANDROID \
		-outdir $(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE) \
		-o $(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE)/pjsua2_wrap.cpp \
		$(SWIG_INPUTS)
	@echo "Compiling Android Shared Library (libpjsua2.so)..."
	# Uses the cross-compiler provided by the Android NDK via configure environment
	$(CXX) -shared -fPIC $(CXXFLAGS) $(INCLUDES) \
		$(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE)/pjsua2_wrap.cpp \
		-o $(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE)/lib/libpjsua2.so \
		$(PJSIP_LIBS) $(LDFLAGS)

# --- TARGET: iOS (.a) ---
ios:
	@echo "========================================================="
	@echo " Generating C# stubs and Obj-C++ wrapper for iOS...      "
	@echo "========================================================="
	mkdir -p $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)
	$(APP_SWIG) $(SWIG_CS_FLAGS) \
		-DCC_HAS_INT64=1 \
		-DPJ_APPLE=1 \
		-D_IOS \
		-outdir $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE) \
		-o $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/pjsua2_wrap.mm \
		$(SWIG_INPUTS)
	@echo "Compiling iOS Static Library (libpjsua2.a)..."
	# Compiles the wrapper and packages everything into a fat/single static archive
	$(CXX) -c $(CXXFLAGS) $(INCLUDES) \
		$(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/pjsua2_wrap.mm \
		-o $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/pjsua2_wrap.o
	$(AR) rcs $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/libpjsua2.a \
		$(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/pjsua2_wrap.o
	rm -f $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/pjsua2_wrap.o

# --- TARGET: MacCatalyst (.a) ---
maccatalyst:
	@echo "========================================================="
	@echo " Generating C# stubs and Obj-C++ wrapper for Catalyst... "
	@echo "========================================================="

	mkdir -p $(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)/$(ARCH)
	mkdir -p $(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)

	$(APP_SWIG) $(SWIG_CS_FLAGS) \
		-DCC_HAS_INT64=1 \
		-DPJ_APPLE=1 \
		-DTARGET_OS_MACCATALYST=1 \
		-D_MAC_CATALYST \
		-outdir $(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE) \
		-o $(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)/pjsua2_wrap.mm \
		$(SWIG_INPUTS)

	@echo "Compiling MacCatalyst Static Library (libpjsua2.a)..."

	$(CXX) -c \
		$(CXXFLAGS) \
		$(CFLAGS) \
		$(INCLUDES) \
		$(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)/pjsua2_wrap.mm \
		-o $(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)/$(ARCH)/pjsua2_wrap.o

	$(AR) rcs \
		$(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)/$(ARCH)/libpjsua2.a \
		$(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)/$(ARCH)/pjsua2_wrap.o

	rm -f $(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)/$(ARCH)/pjsua2_wrap.o

clean:
	rm -rf $(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE)/*
	rm -rf $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/*
	rm -rf $(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)/*
	@echo "Output directories wiped successfully!"