#O código da subcamada BiCo deve implementar as rotinas da API de Controle em linguagem de montagem do RISC-V. A API está descrita no arquivo "api_robot.h". Para controlar o hardware, o código deve realizar chamadas ao sistema, ou syscalls. As syscalls são definidas abaixo.
.globl set_engine_torque
set_engine_torque:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    #a0 é o parâmetro id do motor e a1 e o parametro torque do motor
    li a7, 18
    ecall
    
    lw ra, 0(sp)
    addi sp, sp, 4

    ret
