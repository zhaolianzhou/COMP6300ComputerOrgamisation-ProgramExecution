.syntax unified
.global main
	.macro enable_GPIOB_clock
		ldr r1, =0x40021000
		ldr r2, [r1, #0x4C]
		orr r2, #2
		str r2, [r1, #0x4C]
	.endm

	.macro enable_GPIOE_clock
		ldr r1, =0x40021000
		ldr r2, [r1, #0x4C]
		orr r2, #16
		str r2, [r1, #0x4C]
	.endm

	.macro enable_GPIOx_clock arg
		ldr r1, =0x40021000
		ldr r2, [r1, #0x4C]
		orr r2, \arg
		str r2, [r1, #0x4C]
	.endm

	.macro set_bit address_register, offset, bit_index
		@ load current peripheral register value into r3
    	ldr r3, [\address_register, \offset]
    	@ set the bit you care about, leave the others as they are
		movs r9, #1
		lsl r10, r9, \bit_index
    	orr r3, r10
    	@ write the data back to the peripheral register
    	str r3, [\address_register,\offset]
	.endm

	.macro clear_bit address_register, offset, bit_index
		@ load current peripheral register value into r3
    	ldr r3, [\address_register,\offset]
    	@ set the bit you care about, leave the others as they are
    	and r3, \bit_index
    	@ write the data back to the peripheral register
    	str r3, [\address_register,\offset]
	.endm

	.macro delay register, from, to
	ldr \register, =\from
	delay\@:
		cmp \register, \to
		bne end_delay\@
		subs \register, #1
		b delay\@
	end_delay\@:
	.endm

	.macro turn_red_on
	@load base address of PB
	ldr r1, =0x48000400
	set_bit r1, #0, #4
	clear_bit r1, #0, #0xffffffdf
	@turn pin on
	set_bit r1, #0x14, #2
	.endm

	.macro red_on
		ldr r1, =0x4800040
		set_bit r1, #0x14, #2
	.endm

	.macro turn_red_off
	@load base address of PB
	ldr r1, =0x48000400
	clear_bit r1, #0x14, #0xfffffffb
	.endm

	.macro turn_green_on
		@load base address of PE
		ldr r1, =0x48001000
		set_bit r1, #0, #3
		clear_bit r1, #0, #0xfffdffff
		set_bit r1, #0x14, #8
	.endm

	.macro green_on
		ldr r1, =0x48001000
		set_bit r1, #0x14, #8
	.endm
	.macro turn_green_off
		@load base address of PE
		ldr r1, =0x48001000
		clear_bit r1, #0x14, #0xfffffeff
	.endm


main:
	@enable PB_clock
	enable_GPIOx_clock #2
	@enable_PE_clock
	enable_GPIOx_clock #16
	ldr r2, [r1, #0x6c]
	turn_red_on
	turn_green_on

loop:
	turn_green_off
	@turn_red_on
	ldr r1, =0x48000400
	set_bit r1, #0x14, #2
	@delay
	movs r8, #500
	bl new_delay
	turn_red_off
	#turn green on
	ldr r1, =0x48001000
	set_bit r1, #0x14, #8
	@delay
	movs r8, #500
	bl new_delay
	b loop

new_delay:
	sub r8, #1
	cmp r8, #0
	bne new_delay
	mov pc,lr

