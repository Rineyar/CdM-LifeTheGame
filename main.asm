asect 0
main: ext               # Declare labels
default_handler: ext    # as external
ptr_up: ext
ptr_right: ext
ptr_down: ext
ptr_left: ext
life: ext
reset_all: ext
build_plane: ext

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
dc life, 0
dc reset_all, 0
dc build_plane, 0

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
    ldi r2, 0b1000000000000000 # set column (st r5, r3)
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

    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2
    rti

asect 0x01a0

ptr_right>
    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2

    
    sub r5, r1, r3 # Move from right to left if needed
    if
        ldi r6, 126 
        cmp r3, r6
    is z, or
        ldi r6, 254
        cmp r3, r6
    is z, or
        ldi r6, 346
        cmp r3, r6
    is z, or
        ldi r6, 510
        cmp r3, r6
    is z
        ldi r6, 126
        sub r5, r6, r5
    else
        inc r5
        inc r5
    fi

    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2
    rti

asect 0x02a0

ptr_down>
    ldi r2, 0b1000000000000000 # set column (st r5, r3)
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

    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2
    rti

asect 0x03a0

ptr_left>
    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2

    sub r5, r1, r3 # Move from left to right if needed
    if
        tst r3
    is z, or
        ldi r6, 128
        cmp r3, r6
    is z, or
        ldi r6, 256
        cmp r3, r6
    is z, or
        ldi r6, 384
        cmp r3, r6
    is z
        ldi r6, 126 
        add r5, r6, r5
    else
        dec r5
        dec r5
    fi

    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2
    rti 

asect 0x4a0

life>   
    loop:
        ldi r0, 0xfff0
        ld r0, r3
        if 
            tst r3
        is z
            ld r0, r0

            move r1, r5 # Set pointer to start for further setting
            ldi r4, 0b1000000000000000
            ldi r2, 0b1000000000000000 # set column (st r5, r3)
            clr r2
            rti
        fi
        br loop

asect 0x05a0

reset_all>
    move r1, r5 # Set pointer to start for further setting
    ldi r4, 0b1000000000000000
    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2
    rti

asect 0x07a0

build_plane>
    move r1, r5 # Set pointer to start for further setting
    ldi r4, 0b1101111111111111
    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2
    inc r5
    inc r5
    ldi r4, 0b0101111111111111
    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2
    inc r5
    inc r5
    ldi r4, 0b1001111111111111
    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2
    rti

# Main program section
rsect main
asect 0x08a0

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

    ldi r4, 0b1000000000000000 # Pointer in current column
    ldi r2, 0b1000000000000000 # set column (st r5, r3)
    clr r2

    ei
    loop:
        wait
        br loop
    halt

end. 