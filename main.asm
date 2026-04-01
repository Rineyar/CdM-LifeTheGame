asect 0
main: ext               # Declare labels
default_handler: ext    # as external

# Interrupt vector table (IVT)
# Place a vector to program start and
# map all internal exceptions to default_handler
dc main, 0              # Startup/Reset vector
dc default_handler, 0   # Unaligned SP
dc default_handler, 0   # Unaligned PC
dc default_handler, 0   # Invalid instruction
dc default_handler, 0   # Double fault
align 0x0080            # Reserve space for the rest 
                        # of IVT

# Exception handlers section
rsect exc_handlers

# This handler halts processor
default_handler>
    halt

# Main program section
rsect main

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
    clr r0

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

    ldv r1,mem1
    ldv r2,mem1

    ldv r5,len
    shl r5
    add r2,r5

    while
        cmp r2,r5
    stays lt
        inc r2
        inc r2
    wend

    halt

end.