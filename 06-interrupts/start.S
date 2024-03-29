#include "platform.h"
    # .S file can have preprocessing commands such as #...

    # size each hart's stack is 1024 bytes
    .equ    STACK_SIZE, 1024

    # declare _start as a global symbol
    .global _start

    # mark the begining of date segment
    .text

_start:
    # park harts with id != 0
    csrr    t0, mhartid     # read current hart id, m_hart_id
    mv      tp, t0          # keep CPU's hartid in its tp for later usage
    bnez    t0, park        # if we're not on the hart 0, "park" it

    # only hart0 can run following code
    # set all bytes in the BSS section to zero
    la      a0, _bss_start
    la      a0, _bss_end
    bgeu    a0, a1, 2f
1:
    sw      zero, (a0)
    addi    a0, a0, 4
    bltu    a0, a1, 1b
2: 
    # put the stack pointer to the very end of the stack range.
    slli    t0, t0, 10      # shift left logical immediate, t0 = hart_id * 1024
    la      sp, stacks + STACK_SIZE 
    add     sp, sp, t0     
    j	    start_kernel    # jump to C

park:
	wfi
	j	park

    # In the standard RISC-V calling convention, the stack pointer sp
	# is always 16-byte aligned.
.balign 16
stacks:
	.skip	STACK_SIZE * MAXNUM_CPU # allocate space for all the harts stacks

	.end				# End of file
