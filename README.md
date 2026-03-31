# Bare Metal Experiments in ASM

A simple and minimalist bare metal code experiment for microcontroller learning purposes, using simple examples like a blinking LED program, written in Assembly.

## Overview

This project demonstrates bare metal programming in low level with Assembly on microcontrolers. It implements a few program examples that runs entirely without an operating system, using Assembly only and direct hardware manipulation.

**Boards**
* [ESP32 TTGO T-Display](docs/esp32_ttgo_tdisplay.md)

### Project Structure

```
bare-metal-asm/
├── README.md                     # Project description
├── Makefile                      # Build and flash automation
├── docs/                         # Hardware setup and instructions
│   └── esp32_ttgo_tdisplay.md
└── src/
    └── esp32_ttgo_tdisplay/      # ESP32(Xtensa-LX6) source codes
        ├── blinks.s
        └── linker.ld
```
