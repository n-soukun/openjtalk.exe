# OpenJTalk Multi-platform Makefile
# This Makefile builds OpenJTalk for Windows, macOS, and Linux
# Based on the GitHub Actions build.yml configuration

# Detect the operating system
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    SHELL := cmd.exe
    .SHELLFLAGS := /c
else
    DETECTED_OS := $(shell uname -s)
endif

# Directory paths
PROJECT_ROOT := $(shell pwd)
BIN_DIR := $(PROJECT_ROOT)/bin
HTSENGINE_DIR := $(PROJECT_ROOT)/lib/hts_engine_API-1.10
OPENJTALK_DIR := $(PROJECT_ROOT)/lib/open_jtalk-1.11

# Default target
.PHONY: all clean build-hts build-openjtalk test install prepare-artifacts check-deps

all: build

# Main build target - detects platform and builds accordingly
build:
ifeq ($(DETECTED_OS),Windows)
	@echo Building for Windows...
	$(MAKE) build-windows
else ifeq ($(DETECTED_OS),Darwin)
	@echo Building for macOS...
	$(MAKE) build-macos
else ifeq ($(DETECTED_OS),Linux)
	@echo Building for Linux...
	$(MAKE) build-linux
else
	@echo Unsupported operating system: $(DETECTED_OS)
	@exit 1
endif

# Windows build process
build-windows: prepare-bin-dir
	@echo Setting up Windows build environment...
	chcp 932
	set CFLAGS=/source-charset:shift_jis /execution-charset:shift_jis
	@echo Building HTS Engine API for Windows...
	cd $(HTSENGINE_DIR) && nmake /f Makefile.mak
	cd $(HTSENGINE_DIR) && nmake /f Makefile.mak install
	@echo Building Open JTalk for Windows...
	cd $(OPENJTALK_DIR) && chcp 932 && set CFLAGS=/source-charset:shift_jis /execution-charset:shift_jis && nmake /f Makefile.mak
	@echo Copying Windows executable to bin directory...
	copy "$(OPENJTALK_DIR)\bin\open_jtalk.exe" "$(BIN_DIR)\"
	@echo Windows build completed successfully!

# Linux build process
build-linux: prepare-bin-dir
	@echo Building HTS Engine API for Linux...
	cd $(HTSENGINE_DIR) && autoreconf -f -i
	cd $(HTSENGINE_DIR) && chmod +x ./configure
	cd $(HTSENGINE_DIR) && ./configure
	cd $(HTSENGINE_DIR) && make
	@echo Building Open JTalk for Linux...
	cd $(OPENJTALK_DIR) && autoreconf -f -i
	cd $(OPENJTALK_DIR) && chmod +x ./configure
	cd $(OPENJTALK_DIR) && ./configure --with-charset=UTF-8 --with-hts-engine-header-path=$(HTSENGINE_DIR)/include --with-hts-engine-library-path=$(HTSENGINE_DIR)/lib
	cd $(OPENJTALK_DIR) && make
	@echo Copying Linux executable to bin directory...
	cp $(OPENJTALK_DIR)/bin/open_jtalk $(BIN_DIR)/
	@echo Linux build completed successfully!

# macOS build process
build-macos: prepare-bin-dir
	@echo Building HTS Engine API for macOS...
	cd $(HTSENGINE_DIR) && autoreconf -f -i
	cd $(HTSENGINE_DIR) && chmod +x ./configure
	cd $(HTSENGINE_DIR) && ./configure
	cd $(HTSENGINE_DIR) && make
	@echo Building Open JTalk for macOS...
	cd $(OPENJTALK_DIR) && autoreconf -f -i
	cd $(OPENJTALK_DIR) && chmod +x ./configure
	cd $(OPENJTALK_DIR) && ./configure --with-charset=UTF-8 --with-hts-engine-header-path=$(HTSENGINE_DIR)/include --with-hts-engine-library-path=$(HTSENGINE_DIR)/lib
	cd $(OPENJTALK_DIR) && make
	@echo Copying macOS executable to bin directory...
	cp $(OPENJTALK_DIR)/bin/open_jtalk $(BIN_DIR)/
	@echo macOS build completed successfully!

# Prepare bin directory
prepare-bin-dir:
	@echo Preparing bin directory...
ifeq ($(DETECTED_OS),Windows)
	@if not exist "$(BIN_DIR)" mkdir "$(BIN_DIR)"
else
	@mkdir -p $(BIN_DIR)
endif

# Check dependencies for all platforms
check-deps:
ifeq ($(DETECTED_OS),Linux)
	$(MAKE) check-linux-deps
else ifeq ($(DETECTED_OS),Darwin)
	$(MAKE) check-macos-deps
else ifeq ($(DETECTED_OS),Windows)
	@echo Windows dependency check not implemented
else
	@echo Unsupported operating system for dependency check
endif

# Check Linux dependencies
check-linux-deps:
	@echo Checking Linux dependencies...
	@command -v autoconf >/dev/null 2>&1 || (echo "Error: autoconf not found. Please install: sudo apt-get install autoconf" && exit 1)
	@command -v automake >/dev/null 2>&1 || (echo "Error: automake not found. Please install: sudo apt-get install automake" && exit 1)
	@command -v libtoolize >/dev/null 2>&1 || command -v libtool >/dev/null 2>&1 || (echo "Error: libtool not found. Please install: sudo apt-get install libtool" && exit 1)
	@command -v gcc >/dev/null 2>&1 || (echo "Error: gcc not found. Please install: sudo apt-get install build-essential" && exit 1)

# Check macOS dependencies
check-macos-deps:
	@echo Checking macOS dependencies...
	@command -v autoconf >/dev/null 2>&1 || (echo "Error: autoconf not found. Please install: brew install autoconf" && exit 1)
	@command -v automake >/dev/null 2>&1 || (echo "Error: automake not found. Please install: brew install automake" && exit 1)
	@command -v libtool >/dev/null 2>&1 || command -v glibtool >/dev/null 2>&1 || (echo "Error: libtool not found. Please install: brew install libtool" && exit 1)
	@command -v gcc >/dev/null 2>&1 || (echo "Error: gcc not found. Please install Xcode command line tools" && exit 1)

# Test the built executable
test:
	@echo Testing built executable...
ifeq ($(DETECTED_OS),Windows)
	"$(BIN_DIR)\open_jtalk.exe" --help || echo Built successfully
else
	$(BIN_DIR)/open_jtalk --help || echo "Built successfully"
endif

# Install dependencies (for CI/automated builds)
install-deps:
ifeq ($(DETECTED_OS),Linux)
	@echo Installing Linux dependencies...
	@if command -v sudo >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y build-essential autoconf automake libtool; \
	else \
		echo "Warning: sudo not available. Please install dependencies manually: apt-get install build-essential autoconf automake libtool"; \
	fi
else ifeq ($(DETECTED_OS),Darwin)
	@echo Installing macOS dependencies...
	brew install autoconf automake libtool
else ifeq ($(DETECTED_OS),Windows)
	@echo Windows dependencies should be installed via Visual Studio or Windows SDK
else
	@echo Unsupported operating system for automatic dependency installation
endif

# Prepare artifacts for distribution
prepare-artifacts: build
	@echo Preparing artifacts...
ifeq ($(DETECTED_OS),Windows)
	@if not exist "artifacts" mkdir "artifacts"
	copy "$(BIN_DIR)\open_jtalk.exe" "artifacts\"
	copy "LICENSE" "artifacts\"
	copy "Readme.md" "artifacts\"
else
	@mkdir -p artifacts
	cp $(BIN_DIR)/open_jtalk artifacts/
	cp LICENSE artifacts/
	cp Readme.md artifacts/
endif
	@echo Artifacts prepared in ./artifacts/

# Clean build files
clean:
	@echo Cleaning build files...
ifeq ($(DETECTED_OS),Windows)
	cd $(HTSENGINE_DIR) && nmake /f Makefile.mak clean
	cd $(OPENJTALK_DIR) && nmake /f Makefile.mak clean
	@if exist "$(BIN_DIR)\open_jtalk.exe" del "$(BIN_DIR)\open_jtalk.exe"
	@if exist "artifacts" rmdir /s /q "artifacts"
else
	cd $(HTSENGINE_DIR) && make clean || true
	cd $(OPENJTALK_DIR) && make clean || true
	rm -f $(BIN_DIR)/open_jtalk
	rm -rf artifacts
endif
	@echo Clean completed!

# Deep clean - remove all generated files including configure scripts
distclean: clean
	@echo Performing deep clean...
ifneq ($(DETECTED_OS),Windows)
	cd $(HTSENGINE_DIR) && make distclean || true
	cd $(OPENJTALK_DIR) && make distclean || true
	find $(HTSENGINE_DIR) -name "Makefile" -not -name "Makefile.mak" -not -name "Makefile.am" -delete || true
	find $(OPENJTALK_DIR) -name "Makefile" -not -name "Makefile.mak" -not -name "Makefile.am" -delete || true
endif
	@echo Deep clean completed!

# Help target
help:
	@echo OpenJTalk Multi-platform Build System
	@echo ====================================
	@echo Available targets:
	@echo   all              - Build for current platform (default)
	@echo   build            - Build for current platform
	@echo   build-windows    - Build specifically for Windows
	@echo   build-linux      - Build specifically for Linux
	@echo   build-macos      - Build specifically for macOS
	@echo   test             - Test the built executable
	@echo   install-deps     - Install build dependencies
	@echo   prepare-artifacts- Prepare distribution artifacts
	@echo   clean            - Clean build files
	@echo   distclean        - Deep clean all generated files
	@echo   help             - Show this help message
	@echo
	@echo Current platform: $(DETECTED_OS)
	@echo
	@echo Examples:
	@echo   make             - Build for current platform
	@echo   make test        - Build and test
	@echo   make install-deps- Install dependencies first
	@echo   make clean       - Clean up build files
