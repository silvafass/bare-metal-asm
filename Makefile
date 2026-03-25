.ONESHELL:
SHELL := /bin/bash

.PHONY: flash_esp32_ttgo_tdisplay arase_flash_esp32

all: help

help:
		@echo "ESP32 Bare-Metal Assembly Project"
		@echo "=================================="
		@echo ""
		@echo "Usage: make <target>"
		@echo ""
		@echo "Targets:"
		@echo " flash_esp32_ttgo_tdisplay  Flash the firmware"
		@echo " arase_flash_esp32          Erase flash before flashing"
		@echo " clean                      Remove build artifacts"
		@echo " help                       Show this help message"
		@echo ""
		@echo "ARGS:"
		@echo " BIN=specific_bin"
		@echo ""

flash_esp32_ttgo_tdisplay: clean _build_dir
	@if [ "$(BIN)" = "" ]; then
		@echo "Error: BIN is not specified. (e.g., 'BIN=your_BIN')."
		@exit 1;
	@fi

	xtensa-esp32-elf-as src/esp32_ttgo_tdisplay/$(BIN).S -o build/esp32_ttgo_tdisplay_$(BIN).o
	xtensa-esp32-elf-ld -T src/esp32_ttgo_tdisplay/linker.ld -o build/esp32_ttgo_tdisplay_$(BIN) build/esp32_ttgo_tdisplay_$(BIN).o
	espflash flash --monitor --chip esp32 --port /dev/ttyUSB0 build/esp32_ttgo_tdisplay_$(BIN)

arase_flash_esp32:
	espflash erase-flash --port /dev/ttyUSB0

_build_dir:
	mkdir -p build

clean:
	rm -rf build
