.set    PORTB, 0x04
.set    DDRB, 0x05
.set    DDRB_BIT, 5

.section .text

    .global reset_handler
    .type reset_handler, @function
    reset_handler:
        rcall   main

    .type main, @function
    main:
        sbi     PORTB, DDRB_BIT
    loop:
        sbi     DDRB, DDRB_BIT
        rcall    wait_1s

        cbi     DDRB, DDRB_BIT
        rcall    wait_1s

        rjmp    loop
        ret

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
