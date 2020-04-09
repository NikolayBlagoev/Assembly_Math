.data
formatfloat:	.asciz "%f\n"
formatnumber:	.asciz "%d\n"
twoPi:
        .float 6.28318

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
	
        mov $formatfloat, %rdi
       
      	

	#mulsd %xmm1, %xmm0
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


wrap_around:					#Since sin is defined from 0 to 2*pi there is no point in going over
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



