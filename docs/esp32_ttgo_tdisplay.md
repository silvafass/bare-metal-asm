# ESP32 TTGO T-Display board

**Hardware Requirements**

- ESP32 TTGO T-Display board (or compatible)
- USB cable for programming

## Build from source in Ubuntu based systems

Follow the instructions in the link below to install the Rust development environment:
* https://rust-lang.org/tools/install/

Install espup and required Espressif Rust ecosystem:
```bash
cargo install espup --locked
espup install
# Set environment variables in bash shell
. $HOME/export-esp.sh
```
If you are running from nushell you can run below code to setting environment varaibles:
```bash
let esp_parsed_env = (
     open ($env.home)/export-esp.sh
     | str trim
     | lines
     | parse 'export {name}="{value}"'
 )
 $esp_parsed_env
     | where name != "PATH"
     | transpose --header-row --as-record
     | load-env
 let esp_path = (
     $esp_parsed_env
     | where name == "PATH"
     | get value
     | first
     | str replace ':$PATH' ''
 )
 $env.PATH = $env.PATH | prepend $esp_path
```
NOTE: Even if we're not going to code in Rust, this will be useful for providing us with the xtensa-esp32-elf-[as/ld] tools.

Install espflash:
```bash
cargo install espflash --locked
espflash board-info --port /dev/ttyUSB0 # get board information
```
* `espflash` is a serial flasher utility for Espressif SoCs.

Clone repository locally
```bash
git clone git@github.com:silvafass/bare-metal-asm.git
cd bare-metal-asm
```

Use the make command to easily build and flash into the board:
```bash
make flash_esp32_ttgo_tdisplay BIN=blinks
```
Or execute specific commands to assemble and link the binary:
```bash
xtensa-esp32-elf-as src/esp32_ttgo_tdisplay/blinks.s -o build/esp32_ttgo_tdisplay_blinks.o
xtensa-esp32-elf-ld -T src/esp32_ttgo_tdisplay/linker.ld -o build/esp32_ttgo_tdisplay_blinks build/esp32_ttgo_tdisplay_blinks.o
```
And/or Flash the firmware by connecting the ESP32 TTGO T-Display board to the computer via USB and running the command below to update the board's firmware:
```bash
espflash flash --monitor --chip esp32 --port /dev/ttyUSB0 build/esp32_ttgo_tdisplay_blinks
```

## Useful resources

* Official page for the [ESP32 microchip](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/index.html)
  * [ESP32 Datasheet](https://documentation.espressif.com/esp32_datasheet_en.pdf).
  * [ESP32 Techinical reference manual](https://documentation.espressif.com/esp32_technical_reference_manual_en.pdf)
* [Xtensa LX Instruction set](https://www.cadence.com/content/dam/cadence-www/global/en_US/documents/tools/silicon-solutions/compute-ip/isa-summary.pdf)
