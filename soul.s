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

    # <= Implemente o tratamento da sua syscall aqui
	li t0, 18
	beq t0, a7, set_engine_torque_int

	set_engine_torque_int:
	beq zero, a0, set_engine_torque_esq
	j set_engine_torque_dir
	
	set_engine_torque_esq:
		li t0, 0xFFFF001A
		sh a1, 0(t0)
		j final

	set_engine_torque_dir:
		li t0, 0xFFFF0018
		sh a1, 0(t0)
		j final


	final:
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
