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
    
    # Kill everyone
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
    fi
    
    # Pointer up
    shl r2
    if 
        cmp r0, r2
    is z
        xor r4, r3, r3
        rol r4
        xor r4, r3, r3
        st r5, r3
    fi
    
    # Pointer right
    shl r2
    if 
        cmp r0, r2
    is z
        xor r4, r3, r3
        st r5, r3
        inc r5
        inc r5
        ld r5, r3
        xor r4, r3, r3
        st r5, r3 
    fi
    
    # Pointer left
    shl r2
    if 
        cmp r0, r2
    is z
        xor r4, r3
        st r5, r3
        dec r5
        dec r5
        ld r5, r3
        xor r4, r3
        st r5, r3 
    fi

    # Pointer down
    shl r2
    if 
        cmp r0, r2
    is z
        xor r4, r3
        ror r4
        xor r4, r3
        st r5, r3
    fi

    # Set current cell alive or dead
    shl r2
    if 
        cmp r0, r2
    is z
        xor r4, r3
        st r5, r3
    fi

    ldi r2, 0
    rti

life_handler>
    ldi r0, 0xfff0
    ld r0, r2
    ld r5, r3 
    xor r4, r3, r3
    st r5, r3 # Remove pointer from display
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
            bnz exit
        fi
        br loop
    exit:
        rti
    

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
    # your code here

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
        ldi r2, $1
        ldi r3, $2
        st  r2, r3
    mend

    ldv r1, mem1 # Almost never change, goes to the display
    ldv r5, mem1 # Active pointer to the matrix
    ldi r3, 0b1000000000000000 # Current column
    st r5, r3
    ldi r4, 0b1000000000000000 # Pointer in current column
    ei
    loop:
        wait
        br loop
    halt

end. 