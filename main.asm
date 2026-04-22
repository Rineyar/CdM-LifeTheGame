asect 0
main: ext               # Declare labels
default_handler: ext    # as external
ptr_up: ext
ptr_right: ext
ptr_down: ext
ptr_left: ext
life_off: ext
reset_all: ext
build_plane: ext
two_towers: ext       # <- новая метка для отдельной функции
life_on: ext

# Interrupt vector table (IVT)
# Place a vector to program start and
# map all internal exceptions to default_handler
dc main, 0              # Startup/Reset vector
dc default_handler, 0   # Unaligned SP
dc default_handler, 0   # Unaligned PC
dc default_handler, 0   # Invalid instruction
dc default_handler, 0   # Double fault

dc ptr_up, 0
dc ptr_right, 0
dc ptr_down, 0
dc ptr_left, 0
dc life_off, 0
dc reset_all, 0
dc build_plane, 0
dc two_towers, 0      # <- добавляем в IVT (по желанию)
dc life_on, 0

align 0x0080            # Reserve space for the rest 
                        # of IVT

# Exception handlers section
rsect exc_handlers

# This handler halts processor
default_handler>
    halt

#IRQ handlers section
rsect irq_handlers

asect 0x00a0
    
ptr_up>
    ldi r1, 1 # interruption flag
    ldi r2, 0b1000000000000000 # set column 
    clr r2

    ldi r3, 0b1000000000000000 # Move to other display if needed 
    if
        cmp r4, r3
    is z
        ldi r3, 130
        add r1, r3, r3
        if
            cmp r5, r3
        is mi
            ldi r3, 384
            add r5, r3, r5
            ldi r4, 1
        else
            ldi r3, 128
            sub r5, r3, r5
            ldi r4, 1
        fi
    else
        shl r4
    fi

    ldi r2, 0b1000000000000000 # set column 
    clr r2
    clr r1
    rti

asect 0x01a0

ptr_right>
    ldi r1, 1 # interruption flag
    ldi r2, 0b1000000000000000 # set column 
    clr r2

    
    # Move from right to left if needed
    if
        ldi r6, 126 
        cmp r5, r6
    is z, or
        ldi r6, 254
        cmp r5, r6
    is z, or
        ldi r6, 346
        cmp r5, r6
    is z, or
        ldi r6, 510
        cmp r5, r6
    is z
        ldi r6, 126
        sub r5, r6, r5
    else
        inc r5
        inc r5
    fi

    ldi r2, 0b1000000000000000 # set column 
    clr r2
    clr r1
    rti

asect 0x02a0

ptr_down>
    ldi r1, 1 # interruption flag
    ldi r2, 0b1000000000000000 # set column 
    clr r2
    
    ldi r3, 1 # Move to other display if needed 
    if
        cmp r4, r3
    is z
        ldi r3, 384
        add r1, r3, r3
        if
            cmp r5, r3
        is pl
            ldi r3, 384
            sub r5, r3, r5
            ldi r4, 0b1000000000000000
        else
            ldi r3, 128
            add r5, r3, r5
            ldi r4, 0b1000000000000000
        fi
    else
        shr r4
    fi

    ldi r2, 0b1000000000000000 # set column
    clr r2
    clr r1
    rti

asect 0x03a0

ptr_left>
    ldi r1, 1 # interruption flag
    ldi r2, 0b1000000000000000 # set column 
    clr r2

    # Move from left to right if needed
    if
        tst r5
    is z, or
        ldi r6, 128
        cmp r5, r6
    is z, or
        ldi r6, 256
        cmp r5, r6
    is z, or
        ldi r6, 384
        cmp r5, r6
    is z
        ldi r6, 126 
        add r5, r6, r5
    else
        dec r5
        dec r5
    fi

    ldi r2, 0b1000000000000000 # set column
    clr r2
    clr r1
    rti 

asect 0x4a0

life_off>
    clr r1
    ldi r5, 0 # Set pointer to start for further setting
    ldi r4, 0b1000000000000000
    ldi r2, 0b1000000000000000 # set column 
    clr r2
    
    rti

asect 0x05a0

reset_all>
    ldi r1, 1 # interruption flag
    ldi r5, 0 # Set pointer to start for further setting
    ldi r4, 0b1000000000000000
    ldi r2, 0b1000000000000000 # set column 
    clr r2
    clr r1
    rti

asect 0x06a0

build_plane>
    ldi r1, 1 # interruption flag
    ldi r2, 0b1000000000000000 # hide pointer
    clr r2

    ldi r4, 0b0010000000000000
    ldi r2, 0b1000000000000000 # set column
    clr r2
    inc r5
    inc r5
    ldi r4, 0b1010000000000000
    ldi r2, 0b1000000000000000 # set column 
    clr r2
    inc r5
    inc r5
    ldi r4, 0b0110000000000000
    ldi r2, 0b1000000000000000 # set column 
    clr r2

    ldi r5, 0
    ldi r4, 0b1000000000000000
    ldi r2, 0b1000000000000000 # set pointer
    clr r2
    clr r1
    rti

asect 0x07a0

two_towers>
    ldi r1, 1 # interruption flag
    ldi r2, 0b1000000000000000 # hide pointer
    clr r2

    # столбец 1
    ldi r4, 0b0000000000010100
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 2
    ldi r4, 0b0000000000000010
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 3
    ldi r4, 0b0000000000100010
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 4
    ldi r4, 0b0000000000000010
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 5
    ldi r4, 0b0000000000010010
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 6
    ldi r4, 0b0000000000001110
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 7
    ldi r4, 0b0000001010000000
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 8
    ldi r4, 0b0000000001000000
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 9
    ldi r4, 0b0000010001000000
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 10
    ldi r4, 0b0000000001000000
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 11
    ldi r4, 0b0000001001000000
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 12
    ldi r4, 0b0000000111000000
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    inc r5
    inc r5# пропуск 13 столбца
    inc r5
    inc r5# пропуск 14 столбца
    inc r5
    inc r5# пропуск 15 столбца
    inc r5
    inc r5# пропуск 16 столбца

    # столбец 17
    ldi r4, 0b0011001100110011
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 18
    ldi r4, 0b0011001100110011
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    inc r5
    inc r5# пропуск 19 столбца
    inc r5
    inc r5# пропуск 20 столбца

    # столбец 21
    ldi r4, 0b0011001100110011
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 22
    ldi r4, 0b0011001100110011
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    inc r5
    inc r5# пропуск 23 столбца
    inc r5
    inc r5# пропуск 24 столбца
    inc r5
    inc r5# пропуск 25 столбца

    # столбец 26
    ldi r4, 0b0011001100110011
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 27
    ldi r4, 0b0011001100110011
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    inc r5
    inc r5# пропуск 28 столбца
    inc r5
    inc r5# пропуск 29 столбца

    # столбец 30
    ldi r4, 0b0011001100110011
    ldi r2, 0b1000000000000000
    clr r2
    inc r5
    inc r5

    # столбец 31
    ldi r4, 0b0011001100110011
    ldi r2, 0b1000000000000000
    clr r2

    ldi r4, 0b1000000000000000    # завершающая установка
    ldi r5, 0
    ldi r2, 0b1000000000000000 # set pointer
    nop
    nop
    clr r2
    clr r1
    rti

asect 0x09a0
life_on>
    
    ldi r2, 0b1000000000000000 # hide pointer
    clr r2
    ldi r1, 1 # interruption flag
    rti

rsect main
asect 0x09b0

main>

    #Макросы
    
    macro ldv/2
        ldi $1,$2
        ld $1,$1
    mend

    macro stv/2
        save r0
        ldi r0,$2
        st r0,$1
        restore r0
    mend

    macro putw/2
        save r2
        save r3
        ldi r2, $1
        ldi r3, $2
        st  r2, r3
        restore r3
        restore r2
    mend

    #НЕ ТРОГАТЬ


    #КОД МБ

    # putw 0x0040,0x05a0
    # putw 0x0044,0x06a0

    ldi r4, 0b1000000000000000 # Pointer in current column
    ldi r2, 0b1000000000000000 # set column 
    nop
    nop
    clr r2
    ldi r5, 0

    ei
    loop:
        wait
        br loop
    halt

end. 