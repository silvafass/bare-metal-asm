# Arduino UNO board

**Hardware Requirements**

- Arduino UNO board (or compatible)
- USB cable for programming

## Build from source in Ubuntu based systems

Install the required development dependencies:
```bash
sudo apt install gcc-avr avr-libc avrdude simavr
```
* `gcc-avr`and `avr-libc`are compillation/link and library dependencies for AVR microcontrollers (Atmel/Microchip).
* `avrdude` is a utility to program AVR microcontrollers.
* `simavr` is a lean AVR simulator.

Clone repository locally
```bash
git clone git@github.com:silvafass/bare-metal-asm.git
cd bare-metal-asm
```

Use the make command to easily build and flash into the board:
```bash
make flash_arduino_uno_smd_r2 BIN=blinks
```
Or execute specific commands to assemble and link the binary:
```bash
avr-as src/arduino_uno_smd_r2/blinks.s -o build/arduino_uno_smd_r2_blinks.o
avr-ld -o build/arduino_uno_smd_r2_blinks build/arduino_uno_smd_r2_blinks.o
```
And/or Flash the firmware by connecting the Arduino Uno board to the computer via USB and running the command below to update the board's firmware:
```bash
avrdude -c arduino -P /dev/ttyACM0 -p atmega328p -D -U flash:w:build/arduino_uno_smd_r2_blinks:e
```

## Useful resources

* Official page for the [ATmega328p microchip](https://www.microchip.com/en-us/product/ATmega328P)
* [ATmega328p datasheet](https://ww1.microchip.com/downloads/aemDocuments/documents/MCU08/ProductDocuments/DataSheets/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf).
* Official [pinout board documentation](https://docs.arduino.cc/resources/pinouts/A000073-full-pinout.pdf).
* [Avr Instruction set](https://ww1.microchip.com/downloads/en/DeviceDoc/AVR-InstructionSet-Manual-DS40002198.pdf)
