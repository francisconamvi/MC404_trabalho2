#A subcamada SOUL deve gerenciar o hardware do sistema e prover serviços para a subcamada BiCo através das chamadas de sistemas.

int_handler:
  	###### Tratador de interrupções e syscalls ######
	#salva contexto
	csrrw t6, mscratch, t6 # troca valor de t6 com mscratch
	sw a1, 0(t6) # salva a1
	sw a2, 4(t6) # salva a2
	sw a3, 8(t6) # salva a3
	sw a4, 12(t6) # salva a4

    # <= Implemente o tratamento da sua syscall aqui 

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
	li sp, 134217724 #seta o endereço da pilha
	
	# Muda para o Modo de usuário
	csrr t1, mstatus # Seta os bits 11 e 12 (MPP)
	li t2, ~0x1800 # do registrador mstatus
	and t1, t1, t2 # com o valor 00
	csrw mstatus, t1
	la t0, main # Grava o endereço do rótulo main
	csrw mepc, t0 # no registrador mepc
	mret # PC <= MEPC; MIE <= MPIE; Muda modo para MPP

.align 4
reg_buffer: .skip 4000