// ============================================================================
// File: blinks.s
// Description: Implementation for blinking the backlight of the display and
//              sending messages via a UART peripheral.
// Architecture: Xtensa LX6 (ESP32)
// ============================================================================

// ============================================================================
// Section: Constants and Register Offsets
// Description: Defines compilation flags and hardware register offsets used
//              along the program.
// ============================================================================
.set    DISABLE_WATCHDOG, 1
.set    RTC_CNTL_WDTWPROTECT_REG_OFFSET, 0x00a4
.set    RTC_CNTL_WDTCONFIG0_REG_OFFSET, 0x008C
.set    RTC_CNTL_WDTFEED_REG_OFFSET, 0x00A0
.set    GPIO_ENABLE_W1TS_REG_OFFSET, 0x0024
.set    GPIO_OUT_W1TS_REG_OFFSET, 0x0008
.set    GPIO_OUT_W1TC_REG_OFFSET, 0x000c

// ============================================================================
// Section: Read-Only Data (ESP32 Application Descriptor)
// Description: Constains the boot magic word expected by the ESP32 bootloader.
// ============================================================================
.section .rodata_desc

    BOOT_MAGIC_WORD: .word 0xABCD5432

// ============================================================================
// Section: Read-Only Data
// Description: Mapped to DROM (Flash Data memory). Contains constant strings,
//              hardcoded arrays, and other immutable variables.
// ============================================================================
.section .rodata

    boot_message:           .string "\r\n=== Bare Metal ESP32 Booted! ===\r\n"
    starting_blick_message: .string "Starting the display backlight blick sequence...\r\n"
    backlight_on_message:   .string "Display backlight: ON\r\n"
    backlight_off_message:  .string "Display backlight: OFF\r\n"

// ============================================================================
// Section: Text / Executable Code
// Description: Contains literal pools (memory addresses/constants) and all
//              executable instructions.
// ============================================================================
.section .text

    .literal    BOOT_MESSAGE_ADDR, boot_message
    .literal    STARTING_BLICK_MESSAGE_ADDR, starting_blick_message
    .literal    BACKLIGHT_ON_MESSAGE_ADDR, backlight_on_message
    .literal    BACKLIGHT_OFF_MESSAGE_ADDR, backlight_off_message

    RTC_CNTL_OPTIONS0_REG_BASE:     .word 0x3FF48000
    UART_FIFO_REG_BASE:             .word 0x3FF40000
    GPIO_REG_BASE:                  .word 0x3FF44000

    WDT_WPROTECT_VAL:               .word 0x50D83AA1
    DELAY_COUNT:                    .word 1000
    LED_GPIO:                       .word (1 << 4)

    // ------------------------------------------------------------------------
    // Function: reset_handler
    // Description: The main entry point called by the ESP32 bootloader.
    // ------------------------------------------------------------------------
    .align 4
    .global reset_handler
    .type reset_handler, @function
    reset_handler:
        entry   a1, 32

    .if DISABLE_WATCHDOG
        call8   disable_rtc_watchdog
    .endif

        call8   main

        waiti   0

    // ------------------------------------------------------------------------
    // Function: main
    // Description: The primary application loop.
    // ------------------------------------------------------------------------
    .align 4
    .global main
    .type main, @function
    main:
        entry   a1, 32

        l32r    a10, BOOT_MESSAGE_ADDR
        call8   print_message

        l32r    a2, GPIO_REG_BASE
        l32r    a3, LED_GPIO
        s32i    a3, a2, GPIO_ENABLE_W1TS_REG_OFFSET

        l32r    a10, STARTING_BLICK_MESSAGE_ADDR
        call8   print_message

    toggle_displa_backlight:
        l32r    a2, GPIO_REG_BASE
        l32r    a3, LED_GPIO
        s32i    a3, a2, GPIO_OUT_W1TS_REG_OFFSET
        l32r    a10, BACKLIGHT_ON_MESSAGE_ADDR
        call8   print_message

        l32r    a10, DELAY_COUNT
        call8   wait_cpu_cycles

        l32r    a2, GPIO_REG_BASE
        l32r    a3, LED_GPIO
        s32i    a3, a2, GPIO_OUT_W1TC_REG_OFFSET
        l32r    a10, BACKLIGHT_OFF_MESSAGE_ADDR
        call8   print_message

        l32r    a10, DELAY_COUNT
        call8   wait_cpu_cycles

    .if !DISABLE_WATCHDOG
        call8   feed_rtc_watchdog
    .endif

        j       toggle_displa_backlight

        retw

    // ------------------------------------------------------------------------
    // Function: wait_cpu_cycles
    // Description: Blocks execution for a specifified duration based on CPU
    //              cycles. Assumes an 80 MHz CPU clock speed.
    // ------------------------------------------------------------------------
    .align 4
    .type wait_cpu_cycles, @function
    wait_cpu_cycles:
        entry   a1, 32

        movi    a3, (80 * 1000)             // Normal speed: 80 MHz
        mull    a2, a2, a3

        loop    a2, wait_cpu_cycles_return
        nop

    wait_cpu_cycles_return:
        retw

    // ------------------------------------------------------------------------
    // Function: disable_rtc_watchdog
    // Description: Disables the RTC (Real Time Clock) whatchdog Timer.
    // ------------------------------------------------------------------------
    .align 4
    .type disable_rtc_watchdog, @function
    disable_rtc_watchdog:
        entry   a1, 32

        l32r    a2, RTC_CNTL_OPTIONS0_REG_BASE
        l32r    a3, WDT_WPROTECT_VAL
        movi    a4, 0

        s32i    a3, a2, RTC_CNTL_WDTWPROTECT_REG_OFFSET
        s32i    a4, a2, RTC_CNTL_WDTCONFIG0_REG_OFFSET
        s32i    a4, a2, RTC_CNTL_WDTWPROTECT_REG_OFFSET

        retw

    // ------------------------------------------------------------------------
    // Function: feed_rtc_watchdog
    // Description: Resets the RTC Watchdog timer to present a system reset.
    // ------------------------------------------------------------------------
    .align 4
    .type feed_rtc_watchdog, @function
    feed_rtc_watchdog:
        entry   a1, 32

        l32r    a2, RTC_CNTL_OPTIONS0_REG_BASE
        l32r    a3, WDT_WPROTECT_VAL
        movi    a4, (1 << 31)

        s32i    a3, a2, RTC_CNTL_WDTWPROTECT_REG_OFFSET
        s32i    a4, a2, RTC_CNTL_WDTFEED_REG_OFFSET
        s32i    a4, a2, RTC_CNTL_WDTWPROTECT_REG_OFFSET

        retw

    // ------------------------------------------------------------------------
    // FunctionL print_message
    // Description: Writes a null-terminated string to the UART0 TX FIVO.
    // ------------------------------------------------------------------------
    .align 4
    .type print_message, @function
    print_message:
        entry   a1, 32

        l32r    a3, UART_FIFO_REG_BASE
        movi    a4, 126
    print_loop:
        l8ui    a5, a2, 0
        beqz    a5, print_message_return
    wait_fifo:
        l32i    a6, a3, 0x1C
        extui   a7, a6, 16, 8
        bgeu    a7, a4, wait_fifo
        s32i    a5, a3, 0
        addi    a2, a2, 1
        j       print_loop

    print_message_return:
        retw
