.set    DDRB, 0x04
.set    PINB, 0x03
.set    DDRB_BIT, 5

.section .text

    .global reset_handler
    .type reset_handler, @function
    reset_handler:
        rjmp   main

    main:
        sbi     DDRB, DDRB_BIT
    loop:
        sbi     PINB, DDRB_BIT
        rcall    wait_1s

        rjmp    loop

    .type wait_1s, @function
    wait_1s:
        ldi     r16, 61
        ldi     r17, 255
        ldi     r18, 255
    wait_1s_delay:
        dec     r18
        brne    wait_1s_delay
        dec     r17
        brne    wait_1s_delay
        dec     r16
        brne    wait_1s_delay
        ret
