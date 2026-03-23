flash_esp32_ttgo_tdisplay_blinks:
	xtensa-esp32-elf-as src/esp32_ttgo_tdisplay/blinks.S -o build/esp32_ttgo_tdisplay_blinks.o
	xtensa-esp32-elf-ld -T src/esp32_ttgo_tdisplay/linker.ld -o build/esp32_ttgo_tdisplay_blinks build/esp32_ttgo_tdisplay_blinks.o
	espflash flash --monitor --chip esp32 --port /dev/ttyUSB0 build/esp32_ttgo_tdisplay_blinks

arase_flash_esp32:
	espflash erase-flash --port /dev/ttyUSB0
