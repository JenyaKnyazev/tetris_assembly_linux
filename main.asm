global _start
EXTERN SDL_CreateWindow
EXTERN SDL_PollEvent
EXTERN SDL_DestroyWindow
EXTERN SDL_Delay
EXTERN SDL_Quit
EXTERN SDL_Init
EXTERN SDL_UpdateWindowSurface
EXTERN SDL_GetWindowSurface
section .data
	quit dd 0x100
	temp1 times 8 db 0
	temp2 times 4 db 0
	temp3 times 16 db 0
	temp4 dq 0
	index dq 0
	title db "Jenya Tetris"
	centered dq 805240832
	key_down dd 300H
	key_left dd 1073741904
	key_right dd 1073741903
	key_up dd 1073741906
	p_window dq 0
	p_surface dq 0
	p_pixels dq 0
	x dq 0
	y dq 0
	width dq 400
	height dq 800
	width_bytes dq 1600
	height_bytes dq 3200 
	stack_save dq 0
	stack_save2 dq 0
	color dd 0FFH
	field times 328000 db 0
	p_element dq 0
	swap_element dq 272
	size_element dq 0
			;x   y....
	arr_elements dq 200,20     ,200,20,240,60,200,60,240,20   ,200,20,200,60,200,100,200,140    ,200,100,240,60,240,20,240,100,   240,20,280,20,240,60,200,60 
		     dq 200,20     ,200,20,240,60,200,60,240,20   ,200,20,240,20,280,20,320,20      ,200,100,200,60,200,20,240,100,   200,20,240,20,280,60,240,60
		     dq 200,20     ,200,20,240,60,200,60,240,20   ,200,20,200,60,200,100,200,140    ,200,100,200,60,200,20,240,20,    200,20,200,60,240,60,240,100
		     dq 200,20     ,200,20,240,60,200,60,240,20   ,200,20,240,20,280,20,320,20      ,200,100,200,60,200,20,160,20,    240,20,240,60,200,60,200,100
		     dq 200,20     ,200,20,240,60,200,60,240,20   ,200,20,200,60,200,100,200,140    ,200,20,240,20,280,20,280,60,   240,20,280,20,240,60,200,60 
		     dq 200,20     ,200,20,240,60,200,60,240,20   ,200,20,240,20,280,20,320,20      ,200,20,240,20,280,20,200,60,   200,20,240,20,280,60,240,60
		     dq 200,20     ,200,20,240,60,200,60,240,20   ,200,20,200,60,200,100,200,140    ,200,60,240,60,280,60,200,20,    200,20,200,60,240,60,240,100
		     dq 200,20     ,200,20,240,60,200,60,240,20   ,200,20,240,20,280,20,320,20      ,200,60,240,60,280,20,280,60,    240,20,240,60,200,60,200,100
	end_elements dq 0
	sizes        dq 1         ,4				     ,4				,4                             ,4
	event times 35 dq 0
	move_down dq 20
	moveLR dq 0
section .text
	
_start:
	mov rdi,0
	call SDL_Init
	sub rsp,48
	mov rdi,title
	mov rsi,[centered]
	mov rdx,[centered]
	mov rcx,[width]
	mov r8,[height]
	xor r9,r9
	call SDL_CreateWindow
	mov [p_window],rax
	mov rdi,[p_window]
	call SDL_GetWindowSurface
	mov [p_surface],rax
	mov rdi,32
	add rdi,[p_surface]
	mov rax,[rdi]
	mov [p_pixels],rax
	
	call init_field
	call play
	
	mov rdi,[p_window]
	call SDL_DestroyWindow
	call SDL_Quit
	add rsp,48
	mov rax,231
	mov rdi,0
	syscall
	
gen_random:
	mov rax,96
	mov rdi,temp1
	mov rsi,temp3
	mov rdx,temp4
	syscall
	xor rax,rax
	xor rdx,rdx
	mov eax,[temp2]
	mov rbx,5
	div rbx
	mov [index],rdx
	ret
	
paint_square:
	mov rdi,[p_pixels]
	mov rax,[y]
	sub rax,20
	xor rdx,rdx
	mov rbx,4
	mul rbx
	mov rbx,[width]
	xor rdx,rdx
	mul rbx
	add rax,[x]
	add rax,[x]
	add rax,[x]
	add rax,[x]
	add rdi,rax
	sub rdi,80
	mov rax,[y]
	add rax,20
	xor rdx,rdx
	mov rbx,4
	mul rbx
	mov rbx,[width]
	xor rdx,rdx
	mul rbx
	add rax,[x]
	add rax,[x]
	add rax,[x]
	add rax,[x]
	mov rsi,rax
	add rsi,[p_pixels]
	add rsi,80
	sub rdi,[width_bytes]
	add rdi,160
	run_paint_2:
	mov eax,[color]
	mov rcx,40
	add rdi,[width_bytes]
	sub rdi,160
	run_paint:
		mov [rdi],eax
		add rdi,4
		loop run_paint
	cmp rdi,rsi
	jl run_paint_2
	sub rsp,16
	mov rdi,[p_window]
	call SDL_UpdateWindowSurface
	add rsp,16
	ret

move_print_element:
	check_event:
			sub rsp,280
			mov rdi,event
			call SDL_PollEvent
			add rsp,280
			mov ebx,[quit]
			cmp [event],ebx
			je finish
			mov rdi,event
			mov ebx,[key_down]
			cmp [event],ebx
			jne fin_ch_ev
			add rdi,20
			mov ebx,[key_right]
			cmp [rdi],ebx
			jne next_ch_ev
			add qword[moveLR],40
			call intersection2
			pop r13
			cmp r13,1
			jne end_ch_ev
			sub qword[moveLR],40
			jmp end_ch_ev
			next_ch_ev:
			mov ebx,[key_left]
			cmp [rdi],ebx
			jne next_ch_ev2
			sub qword[moveLR],40
			call intersection2
			pop r13
			cmp r13,1
			jne end_ch_ev
			add qword[moveLR],40
			jmp end_ch_ev
			next_ch_ev2:
			mov ebx,[key_up]
			cmp [rdi],ebx
			jne fin_ch_ev
			mov rdx,[swap_element]
			add qword[p_element],rdx
			mov rdx,arr_elements
			cmp [p_element],rdx
			jl negate
			mov rdx,end_elements
			cmp [p_element],rdx
			jge negate
			jmp end_ch_ev
			negate:
				neg qword[swap_element]
				mov rdx,[swap_element]
				add qword[p_element],rdx
				add qword[p_element],rdx
			jmp end_ch_ev
			fin_ch_ev:
			cmp rax,0
			jne check_event
	end_ch_ev:	
	mov rdi,[p_element]
	mov rcx,[size_element]
	run_move:
		mov rax,[rdi]
		add rax,[moveLR]
		mov [x],rax
		add rdi,8
		mov rax,[rdi]
		add rax,[move_down]
		mov [y],rax
		add rdi,8
		push rdi
		push rcx
		mov eax,0FFH
		mov [color],eax
		call paint_square
		pop rcx
		pop rdi
		loop run_move
	sub rsp,8
	mov rdi,250
	call SDL_Delay
	add rsp,8
	call intersection
	pop r15
	cmp r15,1
	je finish2
	mov rdi,[p_element]
	mov rcx,[size_element]
	run_move2:
		mov rax,[rdi]
		add rax,[moveLR]
		mov [x],rax
		add rdi,8
		mov rax,[rdi]
		add rax,[move_down]
		mov [y],rax
		add rdi,8
		push rdi
		push rcx
		mov eax,0
		mov [color],eax
		call paint_square
		pop rcx
		pop rdi
		loop run_move2
	ret
	finish:
	add rsp,32
	ret
	finish2:
	mov qword[move_down],0
	mov qword[moveLR],0
	ret

play:
	call gen_random
	mov rdi,arr_elements
	mov rsi,sizes
	mov rcx,[index]
	cmp qword[index],0
	je skip_count
	run_count:
		mov r12,[rsi]
		run_count2:
			add rdi,16	
			dec r12
			jnz run_count2
		add rsi,8
		loop run_count
	skip_count:
		mov [p_element],rdi
		mov rax,[rsi]
		mov [size_element],rax
		mov qword[moveLR],0
		push rcx
		push rsi
		push rdi
		run_play2:
			mov rax,20
			add [move_down],rax
			mov rax,[move_down]
			mov rbx,800
			xor rdx,rdx
			div rbx
			mov [move_down],rdx
			call move_print_element
			cmp qword[move_down],0
			jne run_play2
		call check_full_line
		pop rdi
		pop rsi
		pop rcx
		mov rax,[rsi]
		mov rbx,16
		xor rdx,rdx
		mul rbx
		add rdi,rax
	
	jmp play
	ret

intersection:
	mov rdi,[p_element]
	mov r13,[size_element]
	run_inter:
		mov rax,[rdi]
		add rax,[moveLR]
		mov [x],rax
		add rdi,8
		mov rax,[rdi]
		add rax,[move_down]
		mov rbx,400
		xor rdx,rdx
		mul rbx
		add rax,[x]
		push rdi
		mov rdi,field
		add rdi,rax
		cmp byte[rdi],1
		je colusion
		pop rdi
		add rdi,8
		dec r13
		jnz run_inter
	pop r13
	push 0h
	push r13
	ret
	colusion:
		pop rdi 
		mov rdi,[p_element]
		mov r13,[size_element]
	colusion_run:
		mov rax,[rdi]
		add rax,[moveLR]
		mov [x],rax
		add rdi,8
		mov rax,[rdi]
		add rax,[move_down]
		mov rbx,400
		xor rdx,rdx
		mul rbx
		add rax,[x]
		push rdi
		mov rdi,field
		add rdi,rax
		mov byte[rdi],1
		
		pop rdi
		sub rdi,8
		
		mov rax,[rdi]
		add rax,[moveLR]
		mov [x],rax
		add rdi,8
		mov rax,[rdi]
		add rax,[move_down]
		sub rax,40
		mov rbx,400
		xor rdx,rdx
		mul rbx
		add rax,[x]
		push rdi
		mov rdi,field
		add rdi,rax
		mov byte[rdi],1
		
		pop rdi
		add rdi,8
		dec r13
		jnz colusion_run
	pop r13
	push 1h
	push r13
	ret
	
init_field:
	mov rsi,field
	add rsi,312040
	mov rcx,400
	run1_init:
		mov byte[rsi],1
		inc rsi
		loop run1_init
	ret
	
intersection2:
	push rdi 
	mov rdi,[p_element]
	mov rcx,[size_element]
	run_intr2:
		mov rax,[rdi]
		add rax,[moveLR]
		mov [x],rax
		cmp qword[x],0
		jle colusionLR
		cmp qword[x],400
		jge colusionLR
		add rdi,16
		loop run_intr2
	pop rdi
	pop r13
	push 0h
	push r13
	ret
	colusionLR:
		pop rdi
		pop r13
		push 1h
		push r13
	ret
check_full_line:
	mov rdi,312040
	add rdi,field
	mov rdx,field
	mov rbx,rdi
	sub rbx,16000
	add rdx,8040
	mov qword[y],780
	mov qword[x],40
	again_run_check_full:
		mov rcx,9
		xor al,al
		run_check_full:
			add al,[rbx]
			add al,[rdi]
			add rdi,40
			add rbx,40
			loop run_check_full
		sub rdi,360
		sub rbx,360
		cmp al,18
		jne skip_refresh
		mov rsi,rdi
		mov rcx,9
		refresh:
			mov byte[rsi],0
			add rsi,40
			loop refresh
		skip_refresh:
		sub rbx,16000
		sub rdi,16000
		cmp rdi,rdx
		jg again_run_check_full
	mov rdi,312040
	add rdi,field
	mov rbx,rdi
	mov rsi,rbx
	mov rcx,9
	refresh2:
		sub rdi,16000
		refresh3:
			cmp byte[rdi],1
			je end_refresh3
			sub rdi,16000
			cmp rdi,rdx
			jg refresh3
		end_refresh3:
		cmp rdi,rdx
		jl skip_ref4
		refresh5:
			cmp byte[rbx],0
			je end_refresh5
			sub rbx,16000
			cmp rbx,rdx
			jg refresh5
		end_refresh5:
		cmp rbx,rdx
		jl skip_ref4
		cmp rbx,rdi
		jl skip_ref4
		refresh4:
			mov al,[rdi]
			mov [rbx],al
			mov byte[rdi],0
			sub rdi,16000
			sub rbx,16000
			cmp rdi,rdx
			jg refresh4
		skip_ref4:
		add rsi,40
		mov rbx,rsi
		mov rdi,rsi
		loop refresh2
	
	
	mov rdi,312040
	add rdi,field
	mov rbx,rdi
	sub rbx,16000
	mov rdx,field
	add rdx,16040
	
	re_refresh:
	mov rcx,9
	run_refresh2:
		cmp byte[rbx],1
		jne erase_square
		cmp byte[rdi],1
		jne next_ref
		mov dword[color],0FF00H
		push rdx
		push rdi
		push rcx
		push rbx
		call paint_square
		pop rbx
		pop rcx
		pop rdi
		pop rdx
		jmp next_ref
		erase_square:
		cmp byte[rdi],1
		jne next_ref
		mov dword[color],0
		push rdx
		push rdi
		push rcx
		push rbx
		call paint_square
		pop rbx
		pop rcx
		pop rdi
		pop rdx
		next_ref:
		add qword[x],40
		add rdi,40
		add rbx,40
		loop run_refresh2
	sub rbx,16360
	sub rdi,16360
	sub qword[y],40
	mov qword[x],40
	cmp rdi,rdx
	jg re_refresh
	mov rdi,312040
	add rdi,field
	mov rcx,9
	;repair:
		;mov byte[rdi],1
		;add rdi,40
		;loop repair
	ret
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
