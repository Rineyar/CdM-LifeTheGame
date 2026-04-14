asect 0
main: ext               # Declare labels
default_handler: ext    # as external
set_handler: ext
life_handler: ext
button_flag: ext

# Interrupt vector table (IVT)
# Place a vector to program start and
# map all internal exceptions to default_handler
dc main, 0              # Startup/Reset vector
dc default_handler, 0   # Unaligned SP
dc default_handler, 0   # Unaligned PC
dc default_handler, 0   # Invalid instruction
dc default_handler, 0   # Double fault

dc set_handler, 0
dc life_handler, 0
align 0x0080            # Reserve space for the rest 
                        # of IVT

# Exception handlers section
rsect exc_handlers

# This handler halts processor
default_handler>
    halt

#IRQ handlers section
rsect irq_handlers

set_handler>
    ldi r0, 0xfff0 # Button flags
    ld r0, r0
    ld r5, r3
    
    # Clear display and set pointer to start
    ldi r2, 4
    if 
        cmp r0, r2
    is z
        move r1, r5
        ldi r4, len
        ld r4, r4
        add r1, r4, r4
        while
            cmp r5, r4
        stays nz 
            ld r5, r3
            ldi r3, 0
            st r5, r3
            inc r5
            inc r5
        wend
        ldi r4, 0b1000000000000000
        move r1, r5
        st r5, r4
        rti
    fi
    
    # Pointer up
    shl r2
    if 
        cmp r0, r2
    is z
        xor r4, r3, r3
        st r5, r3

        ldi r6, 0b1000000000000000 # Move to other display if needed 
        if
            cmp r4, r6
        is z
            ldi r6, 130
            add r1, r6, r6
            if
                cmp r5, r6
            is mi
                ldi r6, 384
                add r5, r6, r5
                ldi r4, 1
            else
                ldi r6, 128
                sub r5, r6, r5
                ldi r4, 1
            fi
        else
            shl r4
        fi

        ld r5, r3
        xor r4, r3, r3
        st r5, r3
        rti
    fi
    
    # Pointer right
    shl r2
    if 
        cmp r0, r2
    is z
        xor r4, r3, r3
        st r5, r3

        push r2 # Move from right to left if needed
        sub r5, r1, r2
        if
            ldi r6, 126 
            cmp r2, r6
        is z, or
            ldi r6, 254
            cmp r2, r6
        is z, or
            ldi r6, 346
            cmp r2, r6
        is z, or
            ldi r6, 510
            cmp r2, r6
        is z
            ldi r6, 126
            sub r5, r6, r5
        else
            inc r5
            inc r5
        fi
        pop r2

        ld r5, r3
        xor r4, r3, r3
        st r5, r3 
        rti
    fi
    
    # Pointer left
    shl r2
    if 
        cmp r0, r2
    is z
        xor r4, r3, r3
        st r5, r3

        push r2 # Move from left to right if needed
        sub r5, r1, r2
        if
            tst r2
        is z, or
            ldi r6, 128
            cmp r2, r6
        is z, or
            ldi r6, 256
            cmp r2, r6
        is z, or
            ldi r6, 384
            cmp r2, r6
        is z
            ldi r6, 126 
            add r5, r6, r5
        else
            dec r5
            dec r5
        fi
        pop r2

        ld r5, r3
        xor r4, r3, r3
        st r5, r3
        rti 
    fi

    # Pointer down
    shl r2
    if 
        cmp r0, r2
    is z
        xor r4, r3
        st r5, r3
        
        ldi r6, 1 # Move to other display if needed 
        if
            cmp r4, r6
        is z
            ldi r6, 384
            add r1, r6, r6
            if
                cmp r5, r6
            is pl
                ldi r6, 384
                sub r5, r6, r5
                ldi r4, 0b1000000000000000
            else
                ldi r6, 128
                add r5, r6, r5
                ldi r4, 0b1000000000000000
            fi
        else
            shr r4
        fi

        ld r5, r3
        xor r4, r3
        st r5, r3
        rti
    fi

    # Set current cell to opposite
    shl r2
    if 
        cmp r0, r2
    is z
        xor r4, r3
        st r5, r3
        rti
    fi

life_handler>
    ldi r0, 0xfff0
    ld r0, r2
    ld r5, r3 
    xor r4, r3, r3 # Remove pointer from display
    st r5, r3 
    loop:
        ldi r4, mem2
        ld r4, r1
        ldi r4, mem1
        ld r4, r1
        ld r0, r2
        ldi r3, 2 # Check if break
        if 
            cmp r2, r3
        is z
            ld r0, r0

            move r1, r5 # Set pointer to start for further setting
            ld r5, r3
            ldi r4, 0b1000000000000000
            xor r4, r3, r3
            st r5, r3
            rti
        fi
        br loop


# Main program section
rsect main
button_flag: dc  0xfff0
asect 0x0080 #Переменные
len: dc 256 #len*16 - матрица 64*64
memtmp: dc 0x0080
mem1: dc 0x00A0 #адрес первой матрицы
mem2: dc 0x02A0 #адрес второй матрицы

align 0x02A0

asect 0x02A0 
align 0x04A0



asect 0x0500

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

    clr r0
    
    ldv r1, mem1 # Almost never change, goes to the display
    ldv r5, mem1 # Active pointer to the matrix

    #КОД МБ

    ldi r3, 0b1000000000000000 # Current column
    st r5,r3
    ldi r4, 0b1000000000000000 # Pointer in current column
    ei
    loop:
        wait
        br loop
    halt

end. 