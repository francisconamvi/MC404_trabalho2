#A subcamada SOUL deve gerenciar o hardware do sistema e prover serviços para a subcamada BiCo através das chamadas de sistemas.

.align 4
int_handler:
  	###### Tratador de interrupções e syscalls ######
	#salva contexto
	csrrw t6, mscratch, t6 # troca valor de t6 com mscratch
	sw a1, 0(t6) # salva a1
	sw a2, 4(t6) # salva a2
	sw a3, 8(t6) # salva a3
	sw a4, 12(t6) # salva a4
	sw t0, 16(t6) # salva t0
	sw t1, 20(t6) # salva t0
	sw t2, 24(t6) # salva t0
	sw t3, 28(t6) # salva t0
	sw t4, 32(t6) # salva t0
	sw t5, 36(t6) # salva t0
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


    # <= Implemente o tratamento da sua syscall aqui
	li t0, 16
	beq t0, a7, read_ultrasonic_sensor
	li t0, 17
	beq t0, a7, set_servo_angles
	li t0, 18
	beq t0, a7, set_engine_torque_int
	li t0, 19
	beq t0, a7, get_position

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
	beq zero, a0, set_servo_angle_base
	li t0, 1
	beq t0, a0, set_servo_angle_mid
	li t0, 2
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
	get_position:
		li t0, 0xFFFF0004
		sw zero, 0(t0)
		wait_pos:
			li t0, 0xFFFF0004
			lw t1, 0(t0)
			beq zero, t1, wait_pos
			#se nao voltar no wait_pos, é porque não acabou de ler
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

	final:
	sw s11, 84(t6)
	sw s10, 80(t6)
	sw s9, 76(t6)
	sw s8, 72(t6)
	sw s7, 68(t6)
	sw s6, 64(t6)
	sw s5, 60(t6)
	sw s4, 56(t6)
	sw s3, 52(t6)
	sw s2, 48(t6)
	sw s1, 44(t6)
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
	csrrw t6, mscratch, t6 # troca valor de a0 com mscratch

	csrr t0, mepc  # carrega endereço de retorno (endereço da instrução que invocou a syscall)
	addi t0, t0, 4 # soma 4 no endereço de retorno (para retornar após a ecall) 
	csrw mepc, t0  # armazena endereço de retorno de volta no mepc
	mret           # Recuperar o restante do contexto (pc <- mepc)


.globl _start
_start:
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
	# li a0, 0
	# li a1, 10
	# jal set_engine_torque

	loop_infinito:
		nop
		j loop_infinito

.align 4
reg_buffer: .skip 4000

###
