#O código da subcamada BiCo deve implementar as rotinas da API de Controle em linguagem de montagem do RISC-V. A API está descrita no arquivo "api_robot.h". Para controlar o hardware, o código deve realizar chamadas ao sistema, ou syscalls. As syscalls são definidas abaixo.
.globl set_engine_torque
set_engine_torque:
    #a0 é o parâmetro id do motor e a1 e o parametro torque do motor
    #verificar se torque está no range
    li t0, 100
    bgt a1, t0, set_engine_torque_invalido
    li t0, -100
    blt a1, t0, set_engine_torque_invalido
    #se chegou ate aqui, é um valor valido

    li a7, 18
    ecall
    #se a0 for menor que 0, id invalido, retorna -2
    blt a0, zero, set_engine_torque_id_invalido 
    li a0, 0
    ret

    set_engine_torque_id_invalido:
    li a0, -2
    ret

    set_engine_torque_invalido:
    li a0, -1
    ret



.globl set_torque
set_torque:
    #a0 é o valor do torque da esquerda
    #a1 é o valor do torque da direita
    
    #tem que verificar os valores
    li t0, 100
    bgt a0, t0, set_torque_invalido
    bgt a1, t0, set_torque_invalido
    li t0, -100
    blt a0, t0, set_torque_invalido
    blt a1, t0, set_torque_invalido

    #configurar motor esquerdo
    mv s2, a1 #guarda valor do torque da direita em s2 
    mv a1, a0 #coloca o valor do torque da esqueda em a1
    li a0, 0 #id = 0 é o toque da esquerda
    li a7, 18 #syscall set_engine_torque_int
    ecall

    #configurar motor direito
    mv a1, s2 #coloca o valor do torque da direita em a1
    li a0, 1 #id = 1 é o toque da direita
    li a7, 18 #syscall set_engine_torque_int
    ecall
    
    li a0, 0
    ret
    
    set_torque_invalido:
    li a0, -1
    ret

.globl set_head_servo
set_head_servo:
    #a0 é o identificador do servo motor 0/1/2 = base/mid/top
    #a1 é o angulo
    li a7, 17
    ecall
    ret

.globl get_us_distance
get_us_distance:
    #nao tem parametros
    li a7, 16
    ecall
    
    ret


####
