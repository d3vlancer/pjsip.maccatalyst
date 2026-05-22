# Include core PJSIP build configurations
include ../../../../../build.mak
include ../../../../../build/common.mak
include ../../../../../version.mak

SWIG_MODULE     = pjsua2
MAUI_NAMESPACE  = pjsua2maui.$(SWIG_MODULE)
BASE_OUTPUT_DIR = ./pjsua2maui/Platforms

# Ensures that the SWIG and the interface file be found locally or at the parent directory 
APP_SWIG             ?= swig
SWIG_INTERFACE_FILES  = ../../pjsua2.i

# Global SWIG flags for C#
SWIG_CS_FLAGS   = -csharp -c++ -w312,314,325,362,383,389,401,503 \
                  -namespace $(MAUI_NAMESPACE) \
                  -I$(PJ_DIR)/pjlib/include \
                  -I$(PJ_DIR)/pjlib-util/include \
                  -I$(PJ_DIR)/pjmedia/include \
                  -I$(PJ_DIR)/pjnath/include \
                  -I$(PJ_DIR)/pjsip/include

SWIG_INPUTS     = ./pjsua2_maui.i

# Include paths required to compile the generated wrapper
INCLUDES        = -I$(PJ_DIR)/pjlib/include \
                  -I$(PJ_DIR)/pjlib-util/include \
                  -I$(PJ_DIR)/pjmedia/include \
                  -I$(PJ_DIR)/pjnath/include \
                  -I$(PJ_DIR)/pjsip/include 

# Dynamic list of all core PJSIP static libraries linked into the final bundle
PJSIP_LIBS      = -L$(PJ_DIR)/pjlib/lib \
                  -L$(PJ_DIR)/pjlib-util/lib \
                  -L$(PJ_DIR)/pjmedia/lib \
                  -L$(PJ_DIR)/pjsip/lib \
                  -L$(PJ_DIR)/pjnath/lib \
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
                  -lpj-$(TARGET_NAME)

# Adicionado generate_interface ao PHONY
.PHONY: all maui android ios maccatalyst clean generate_interface

# Corrigido para chamar os nomes exatos das regras abaixo
all: maui

maui: android ios maccatalyst

generate_interface:
	@echo "Creating custom MAUI SWIG interface..."
	@echo '%module $(SWIG_MODULE)' > $(SWIG_INPUTS)
	@echo '%rename("%(regex:/^([a-z])(.*)/\\u\\1\\2/)s", match="function") "";' >> $(SWIG_INPUTS)
	@echo '%rename("%(regex:/^([a-z])(.*)/\\u\\1\\2/)s", match="variable") "";' >> $(SWIG_INPUTS)
	@echo '%include "../../pjsua2.i"' >> $(SWIG_INPUTS)

android: generate_interface
	@echo "========================================================="
	@echo " Generating C# stubs and C++ wrapper for Android...      "
	@echo "========================================================="
	mkdir -p $(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE)
	mkdir -p $(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE)/lib
	$(APP_SWIG) $(SWIG_CS_FLAGS) \
			-DCC_HAS_INT64=1 \
			-D_ANDROID \
			-outdir $(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE) \
			-o $(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE)/pjsua2_wrap.cpp \
			$(SWIG_INPUTS)
	@echo "Compiling Android Shared Library (libpjsua2.so)..."
	$(CXX) -shared -fPIC $(CXXFLAGS) $(INCLUDES) \
			$(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE)/pjsua2_wrap.cpp \
			-o $(BASE_OUTPUT_DIR)/Android/$(SWIG_MODULE)/lib/libpjsua2.so \
			$(PJSIP_LIBS) $(LDFLAGS)

ios: generate_interface
	@echo "========================================================="
	@echo " Generating C# stubs and Obj-C++ wrapper for iOS...      "
	@echo "========================================================="
	mkdir -p $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)
	
	$(APP_SWIG) $(SWIG_CS_FLAGS) -dllimport "__Internal" \
			-DCC_HAS_INT64=1 \
			-DPJ_APPLE=1 \
			-D_IOS \
			-outdir $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE) \
			-o $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/pjsua2_wrap.mm \
			$(SWIG_INPUTS)
	@echo "Compiling iOS Static Library (libpjsua2.a)..."
	$(CXX) -c $(CXXFLAGS) $(INCLUDES) \
			$(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/pjsua2_wrap.mm \
			-o $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/pjsua2_wrap.o
	$(AR) rcs $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/libpjsua2.a \
			$(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/pjsua2_wrap.o
	rm -f $(BASE_OUTPUT_DIR)/iOS/$(SWIG_MODULE)/pjsua2_wrap.o

maccatalyst: generate_interface
	@echo "========================================================="
	@echo " Generating C# stubs and Obj-C++ wrapper for Catalyst... "
	@echo "========================================================="

	mkdir -p $(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)/$(ARCH)
	mkdir -p $(BASE_OUTPUT_DIR)/MacCatalyst/$(SWIG_MODULE)

	$(APP_SWIG) $(SWIG_CS_FLAGS) -dllimport "__Internal" \
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
	rm -f $(SWIG_INPUTS)
	@echo "Output directories wiped successfully!"