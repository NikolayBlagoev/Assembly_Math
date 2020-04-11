.data
formatnumber:	.asciz "%ld"
formatstring:	.asciz "%s"
output:		.asciz " x10^"
formatnumber2:	.asciz "%d\n"

.text
format:
        .asciz "%f\n"
.global main
main:

        sub $8, %rsp
	movq %rsp, %rbp

	movq (%rsi), %rsi			# move pointer to argv in rsi
	movq $-1, %r10				#prepare counter


loop_tillnumber:				#used to find start of argv[1]
	incq %r10				#argv[0] is the name of the executable
	mov (%rsi, %r10, 1), %bl		# move every byte from argv[0] to rbx
	cmpb $0, %bl
	jg loop_tillnumber
	
	
	call character_to_number
	movq %rax, %rsi
	call factorial
        mov $formatnumber, %rdi
       	movq %rax, %rsi
        movq $0, %rax
        call printf
        mov $formatstring, %rdi
       	movq $output, %rsi
        movq $0, %rax
        call printf
        mov $formatnumber2, %rdi
       	movq %rbx, %rsi
        movq $0, %rax
        call printf
        mov $0, %rax
        call exit

factorial:					#input stored in rsi, output in rax, power of ten in rbx
	movq $0, %rbx	
	movq %rsp, %rbp
	push %rbp
	push %rsi
	cmp $1, %rsi
	je base_case

	decq %rsi
	call factorial
	pop %rsi
	call check_module_5
	mulq %rsi
	pop %rbp
	movq %rbp, %rsp
	ret

base_case:
	pop %rsi
	mov %rsi, %rax
	pop %rbp
	movq %rbp, %rsp
	ret


check_module_5:
	movq %rsp, %rbp
	push %rbp
	push %rsi
	push %rax
	push %r11
	movq %rsi, %rax
	movq $5, %r11	
	movq $0, %rdx
	div %r11
	cmp $0, %rdx
	je divisible_by_5

#else:
	pop %r11
	pop %rax
	pop %rsi
	pop %rbp
	movq %rbp, %rsp
	ret

divisible_by_5:
	movq %rax, %rsi
	incq %rbx
	pop %r11
	pop %rax
	push %r11
	movq $0, %rdx
	movq $2, %r11
	div %r11
	pop %r11
	pop %r12
	pop %rbp
	movq %rbp, %rsp
	ret

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






