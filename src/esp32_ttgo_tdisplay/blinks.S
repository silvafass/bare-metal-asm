.section .rodata_desc

    BOOT_MAGIC_WORD: .word 0xABCD5432

.section .rodata

    boot_message:           .string "\r\n=== Bare Metal ESP32 Booted! ===\r\n"
    starting_blick_message: .string "Starting the display backlight blick sequence...\r\n"
    backlight_on_message:   .string "Display backlight: ON\r\n"
    backlight_off_message:  .string "Display backlight: OFF\r\n"

.section .text

    .literal    BOOT_MESSAGE_ADDR, boot_message
    .literal    STARTING_BLICK_MESSAGE_ADDR, starting_blick_message
    .literal    BACKLIGHT_ON_MESSAGE_ADDR, backlight_on_message
    .literal    BACKLIGHT_OFF_MESSAGE_ADDR, backlight_off_message

    RTC_CNTL_WDTWPROTECT_REG:   .word 0x3FF480A4
    RTC_CNTL_WDTCONFIG0_REG:    .word 0x3FF4808C

    UART_FIFO_REG:              .word 0x3FF40000

    GPIO_ENABLE_W1TS_REG:       .word 0x3FF44024
    GPIO_OUT_W1TS_REG:          .word 0x3FF44008
    GPIO_OUT_W1TC_REG:          .word 0x3FF4400C

    WDT_WPROTECT_VAL:           .word 0x50D83AA1
    DELAY_COUNT:                .word 20000000
    LED_GPIO:                   .word (1 << 4)

    .global reset_handler
    .type reset_handler, @function
    reset_handler:
        entry   a1, 32

        call8   disable_rtc_watchdog

        call8   main

        waiti   0

    .align 4
    .global main
    .type main, @function
    main:
        entry   a1, 32

        l32r    a10, BOOT_MESSAGE_ADDR
        call8   print_message

        l32r    a2, GPIO_ENABLE_W1TS_REG
        l32r    a3, LED_GPIO
        s32i    a3, a2, 0

        l32r    a10, STARTING_BLICK_MESSAGE_ADDR
        call8   print_message

    turn_backscreen_on:
        l32r    a2, GPIO_OUT_W1TS_REG
        l32r    a3, LED_GPIO
        s32i    a3, a2, 0
        l32r    a10, BACKLIGHT_ON_MESSAGE_ADDR
        call8   print_message

        l32r    a10, DELAY_COUNT
        call8   wait_cpu_cycles

    turn_backscreen_off:
        l32r    a2, GPIO_OUT_W1TC_REG
        l32r    a3, LED_GPIO
        s32i    a3, a2, 0
        l32r    a10, BACKLIGHT_OFF_MESSAGE_ADDR
        call8   print_message

        l32r    a10, DELAY_COUNT
        call8   wait_cpu_cycles

        j       turn_backscreen_on

        retw

    .align 4
    .type wait_cpu_cycles, @function
    wait_cpu_cycles:
        entry   a1, 32

    delay_inner:
        addi    a2, a2, -1
        bnez    a2, delay_inner

        retw

    .align 4
    .type disable_rtc_watchdog, @function
    disable_rtc_watchdog:
        entry   a1, 32

        l32r    a2, RTC_CNTL_WDTWPROTECT_REG
        l32r    a3, WDT_WPROTECT_VAL
        s32i    a3, a2, 0

        l32r    a2, RTC_CNTL_WDTCONFIG0_REG
        l32r    a3, WDT_WPROTECT_VAL
        s32i    a3, a2, 0

        retw

    .align 4
    .type print_message, @function
    print_message:
        entry   a1, 32

        l32r    a3, UART_FIFO_REG
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
