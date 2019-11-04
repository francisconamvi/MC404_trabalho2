/*Lógica de Controle (LoCo)
O código da subcamada LoCo deve ser implementado em linguagem C e deve fazer uso das rotinas disponíveis na API de Controle para enviar comandos para o robô.

Com base nas coordenadas dos amigos, armazenadas na variável "friends_locations", e das posições perigosas, armazenadas na variável "dangerous_locations" (veja o arquivo api_robot.h), a lógica de controle do programa deve:

Movimentar o Uóli pelo terreno com o objetivo de encontrar e transmitir informações para os amigos e evitar as posições perigosas.
O Uóli deve passar a pelo menos 5 metros do amigo para que a informação possa ser transferida.
O Uóli deve se manter a pelo menos 10 metros de distância de posições perigosas para evitar problemas.
Note que o Uóli não consegue subir montanhas muito íngremes. Você deve identificar estes casos e programá-lo para que ele contorne os obstáculos.
O terreno poderá conter obstáculos, além de montanhas muito íngremes. Estes obstáculos devem ser desviados, pois a colisão com estes pode afetar a trajetória ou mesmo o funcionamento do Uóli.
*/
#include "api_robot2.h"

int main(){
    
    /*tem que apagar isso depois, soul que tem que configurar*/
    set_head_servo(0, 31);
    set_head_servo(1, 80);
    set_head_servo(2, 78);
    
    set_torque(40,40);
    
    while(get_us_distance()==-1){ // ou seja, nada a frente
        set_torque(40,40);
    }
    
    set_head_servo(0, 115);
    set_head_servo(1, 90);


    return 0;
}