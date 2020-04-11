.data
formatfloat:	.asciz "%f\n"
formatnumber:	.asciz "%ld\n"
twoPi:
        .float 6.2831853

.text
format:
        .asciz "%f\n"
.global main
main:

	
        sub $8, %rsp
	movq %rsp, %rbp
	CVTSS2SD twoPi, %xmm1			#Set up twoPi

	movq (%rsi), %rsi			# move pointer to argv in rsi
	movq $-1, %r10				#prepare counter


loop_tillnumber:				#used to find start of argv[1]
	incq %r10				#argv[0] is the name of the executable
	mov (%rsi, %r10, 1), %bl		# move every byte from argv[0] to rbx
	cmpb $0, %bl
	jg loop_tillnumber
	

	call character_to_number

	CVTSI2SD %rax, %xmm0
    	call wrap_around
	movq $4, %rax
	movsd %xmm0, %xmm6
	movsd %xmm6, %xmm0
	movq %rsp, %rbp
	push %r10
	push %rdi
	push %rax
	push %rsi
        mov $formatfloat, %rdi
        movq $1, %rax
        call printf

	pop %rsi
	pop %rax
	pop %rdi

	pop %r10
	movq %rbp, %rsp
	movsd %xmm6, %xmm0

	
	call sin

after_sin:
	
        mov $formatfloat, %rdi
       
        movq $1, %rax
        call printf

        mov $0, %rax
        call exit





character_to_number:				# Converts Ascii to number. Output is in rax. Pointer to string in %rsi, offset in %r10
	movq %rsp, %rbp
	push %rbp
	push %rbx
	movq $0, %rax
get_number:					
	incq %r10
	mov (%rsi, %r10, 1), %bl		# move every byte from argv[1] to rbx
	cmpb $0, %bl
	je after_number
	subq $48, %rbx				# remove ASCII code to 0 to convert character to number
	imulq $10, %rax
	addq %rbx, %rax
	#cmp $1000, %rax
	jmp get_number

after_number:
	pop %rbx
	pop %rbp
	mov %rbp, %rsp
	ret


wrap_around:					#Since sin is periodic, there is no point in going above pi or under -pi
						#Number to wrap around is in xmm0. Output in xmm0
	movq %rsp, %rbp
	push %rbp
	push %rbx
	movsd %xmm0, %xmm2
	divsd %xmm1, %xmm0
	CVTSD2SI %xmm0, %rax
	CVTSI2SD %rax, %xmm0
	mulsd %xmm1, %xmm0
	subsd %xmm0, %xmm2
	
	movsd %xmm2, %xmm0

	pop %rbx
	pop %rbp
	movq %rbp, %rsp
	ret


sin:						#Input in xmm0, output in xmm0
	movq %rsp, %rbp
	push %rbp
	push %rax
	push %r10
	push %r11
	movq $1, %rax
	movq $3, %r10
	movsd %xmm0, %xmm1
	mulsd %xmm1, %xmm1
	movq $1, %r11
	movsd %xmm0, %xmm2

	movsd %xmm6, %xmm0
	
	push %r11
	push %r10
	push %rdi
	push %rax
	push %rsi
        mov $formatfloat, %rdi
        movq $1, %rax
        call printf
	pop %rsi
	pop %rax
	pop %rdi
	pop %r10
	pop %r11

	movsd %xmm6, %xmm0

loop_sin:
	mulsd %xmm1, %xmm2
	movsd %xmm2, %xmm4
	movq %r10, %r12
	mul %r12
	decq %r12
	mul %r12
	
	CVTSI2SD %rax, %xmm3
	divsd %xmm3, %xmm4
	cmp $1, %r11
	jne else_case
	movq $1, %r11
	subsd %xmm4, %xmm0
	jmp end_of_loop
else_case:
	movq $0, %r11
	addsd %xmm4, %xmm0

end_of_loop:	

	cmp $13, %r10
	je end_of_sin
	addq $2, %r10
	jmp loop_sin


end_of_sin:
	pop %r11
	pop %r10
	pop %rax
	pop %rbp
	movq %rbp, %rsp
	ret
