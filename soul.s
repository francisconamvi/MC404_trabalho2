#**************************************************************** 
#* Description: Sistema Operacional UóLi (SOUL).
#*
#* Authors: Francisco Namias Vicente
#*          Luiz Felipe Eike Kina
#*
#* Date: 2019
#***************************************************************/

.align 4
int_handler:
  	###### Tratador de interrupções e syscalls ######

	#salva contexto
	csrrw t6, mscratch, t6 # troca valor de t6 com mscratch
	sw a1, 0(t6)
	sw a2, 4(t6)
	sw a3, 8(t6)
	sw a4, 12(t6)
	sw t0, 16(t6)
	sw t1, 20(t6)
	sw t2, 24(t6)
	sw t3, 28(t6)
	sw t4, 32(t6)
	sw t5, 36(t6)
	sw ra, 40(t6)
	sw s1, 44(t6)
	sw s2, 48(t6)
	sw s3, 52(t6)
	sw s4, 56(t6)
	sw s5, 60(t6)
	sw s6, 64(t6)
	sw s7, 68(t6)
	sw s8, 72(t6)
	sw s9, 76(t6)
	sw s10, 80(t6)
	sw s11, 84(t6)


    #Implementação do tratamento da syscall

	#verifica se é GPT
	csrr t0, mcause
	blt t0, zero, GPT_handler

	#nao é o GPT
	li t0, 16
	beq t0, a7, read_ultrasonic_sensor
	li t0, 17
	beq t0, a7, set_servo_angles
	li t0, 18
	beq t0, a7, set_engine_torque_int
	li t0, 19
	beq t0, a7, read_gps
	li t0, 20
	beq t0, a7, read_gyroscope
	li t0, 21
	beq t0, a7, get_times
	li t0, 22
	beq t0, a7, set_times
	li t0, 64
	beq t0, a7, write

	######### GPT #########
	GPT_handler:
		li t0, 0xFFFF0104
		lb t1, 0(t0)
		beq t1, zero, final_gpt
		
		#se chegou aqui, GPT-IO = 1, zerar ele pois a int sera tratada
		sb zero, 0(t0)

		#aumentar system_time
		la t0, system_time
		lw t1, 0(t0)
		addi t1, t1, 100
		sw t1, 0(t0)

		li t3, 100
		li t4, 0xFFFF0100
		sw t3, 0(t4)
		j final_gpt

	######### ENGINE_TORQUE #########
	set_engine_torque_int:
		beq zero, a0, set_engine_torque_esq
		li t1, 1
		beq t1, a0, set_engine_torque_dir
		li a0, -1 #id invalido, retorna -1
		j final

		set_engine_torque_esq:
			li t0, 0xFFFF001A
			sh a1, 0(t0)
			li a0, 0
			j final

		set_engine_torque_dir:
			li t0, 0xFFFF0018
			sh a1, 0(t0)
			li a0, 0
			j final

	######### SERVO_ANGLES #########
	set_servo_angles:
		li t0, 1
		beq t0, a0, set_servo_angle_base
		li t0, 2
		beq t0, a0, set_servo_angle_mid
		li t0, 3
		beq t0, a0, set_servo_angle_top
		li a0, -2
		j final

		set_servo_angle_top:
			li t0, 156
			blt a1, zero, servo_motor_ang_invalido
			bgt a1, t0, servo_motor_ang_invalido
			li t0, 0xFFFF001C
			sb a1, 0(t0)
			li a0, 0
			j final

		set_servo_angle_mid:
			li t0, 52
			li t1, 90
			blt a1, t0, servo_motor_ang_invalido
			bgt a1, t1, servo_motor_ang_invalido
			li t0, 0xFFFF001D
			sb a1, 0(t0)
			li a0, 0
			j final

		set_servo_angle_base:
			li t0, 16
			li t1, 116
			blt a1, t0, servo_motor_ang_invalido
			bgt a1, t1, servo_motor_ang_invalido
			li t0, 0xFFFF001E
			sb a1, 0(t0)
			li a0, 0
			j final

	servo_motor_ang_invalido:
		li a0, -1
		j final

	######### ULTRASONIC_SENSOR #########
	read_ultrasonic_sensor:
		li t0, 0xFFFF0020
		sw zero, 0(t0)
		wait_us:
			lw t1, 0(t0)
			beq zero, t1, wait_us
			#se nao voltar no wait_us, é porque us está pronto pra ser lido
		li t0, 0xFFFF0024
		lw a0, 0(t0) #valor de retorno do ultrassom, de 0 a 600 ou -1
		j final

	######### GET_POSITION #########
	read_gps:
		li t0, 0xFFFF0004
		sw zero, 0(t0)
		wait_gps:
			li t0, 0xFFFF0004
			lw t1, 0(t0)
			beq zero, t1, wait_gps
			#se nao voltar no wait_gps, é porque acabou de ler
		#armazena a posicao de x
		li t0, 0xFFFF0008
		lw t1, 0(t0)
		sw t1, 0(a0)
		#armazena a posicao de y
		li t0, 0xFFFF000C
		lw t1, 0(t0)
		sw t1, 4(a0)
		#armazena a posicao de z
		li t0, 0xFFFF0010
		lw t1, 0(t0)
		sw t1, 8(a0)
		j final

	read_gyroscope:
		li t0, 0xFFFF0004
		sw zero, 0(t0)
		wait_gyros:
			li t0, 0xFFFF0004
			lw t1, 0(t0)
			beq zero, t1, wait_gyros
			#se nao voltar no wait_gyros, é porque acabou de ler
		#armazena a posicao de x
		li t0, 0xFFFF0014
		lw t1, 0(t0)
		li t2, 0x3FF00000
		and t1, t1, t2
		srli t1, t1, 20
		sw t1, 0(a0)
		#armazena a posicao de y
		li t0, 0xFFFF0014
		lw t1, 0(t0)
		li t2, 0x000FFC00
		and t1, t1, t2
		srli t1, t1, 10
		sw t1, 4(a0)
		#armazena a posicao de z
		li t0, 0xFFFF0014
		lw t1, 0(t0)
		li t2, 0x000003FF
		and t1, t1, t2
		srli t1, t1, 0
		sw t1, 8(a0)
		j final

	######### GET_TIME #########
	get_times:
		la t0, system_time
		lw a0, 0(t0)
		j final

	######### SET_TIME #########
	set_times:
		la t0, system_time
		sw a0, 0(t0)
		j final

	######### WRITE #########
	write:
		li a0, 0
		write_inicio:
		bge a0, a2, final
		#dar load byte na memoria
		lb t0, 0(a1)
		#coloca no 0xFFFF0109
		li t1, 0xFFFF0109
		sb t0, 0(t1)
		#poe 1 no 0xFFFF0108
		li t1, 1
		li t2, 0xFFFF0108
		sb t1, 0(t2)
		#verifica se é 0, se sim continua
		verifica_write:
		lb t1, 0(t2)
		bne zero, t1, verifica_write
		addi a0, a0, 1
		addi a1, a1, 1
		j write_inicio

	final:
		csrr t0, mepc  # carrega endereço de retorno (endereço da instrução que invocou a syscall)
		addi t0, t0, 4 # soma 4 no endereço de retorno (para retornar após a ecall) 
		csrw mepc, t0  # armazena endereço de retorno de volta no mepc

	final_gpt:
		lw s11, 84(t6)
		lw s10, 80(t6)
		lw s9, 76(t6)
		lw s8, 72(t6)
		lw s7, 68(t6)
		lw s6, 64(t6)
		lw s5, 60(t6)
		lw s4, 56(t6)
		lw s3, 52(t6)
		lw s2, 48(t6)
		lw s1, 44(t6)
		lw ra, 40(t6)
		lw t5, 36(t6) # salva t0
		lw t4, 32(t6) # salva t0
		lw t3, 28(t6) # salva t0
		lw t2, 24(t6) # salva t0
		lw t1, 20(t6) # salva t0
		lw t0, 16(t6) # salva t0
		lw a4, 12(t6)
		lw a3, 8(t6)
		lw a2, 4(t6)
		lw a1, 0(t6)
		csrrw t6, mscratch, t6 # troca valor de t6 com mscratch

	mret           # Recuperar o restante do contexto (pc <- mepc)


.globl _start
_start:

	# Ajustes iniciais
	la t0, system_time
	sw zero, 0(t0)

	#configura GPT
	li t3, 100
	li t4, 0xFFFF0100
	sw t3, 0(t4)

	#configura torque pra zero
	li t0, 0xFFFF001A
	sh zero, 0(t0)

	li t0, 0xFFFF0018
	sh zero, 0(t0)

	#configura articulações cabeça
	li t0, 0xFFFF001E
	li t1, 31
	sb t1, 0(t0)
	
	li t0, 0xFFFF001D
	li t1, 80
	sb t1, 0(t0)

	li t0, 0xFFFF001C
	li t1, 78
	sb t1, 0(t0)

	# Configura o tratador de interrupções
	la t0, int_handler # Grava o endereço do rótulo int_handler
	csrw mtvec, t0 # no registrador mtvec

	# Habilita Interrupções Global
	csrr t1, mstatus # Seta o bit 7 (MPIE)
	ori t1, t1, 0x80 # do registrador mstatus
	csrw mstatus, t1
	
	# Habilita Interrupções Externas
	csrr t1, mie # Seta o bit 11 (MEIE)
	li t2, 0x800 # do registrador mie
	or t1, t1, t2
	csrw mie, t1
	
	# Ajusta o mscratch
	la t1, reg_buffer # Coloca o endereço do buffer para salvar
	csrw mscratch, t1 # registradores em mscratch
	li sp, 0x7fffffc #seta o endereço da pilha

	# Muda para o Modo de usuário
	csrr t1, mstatus # Seta os bits 11 e 12 (MPP)
	li t2, ~0x1800 # do registrador mstatus
	and t1, t1, t2 # com o valor 00
	csrw mstatus, t1
	la t0, user # Grava o endereço do rótulo user
	csrw mepc, t0 # no registrador mepc
	mret # PC <= MEPC; MIE <= MPIE; Muda modo para MPP

.align 4
user:
	call main

	loop_infinito:
		nop
		j loop_infinito

.align 4
reg_buffer: .skip 4000
.align 4
system_time: .skip 4

###
