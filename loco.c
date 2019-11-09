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

void delay(int t){
    int t0 = get_time();
    int nt = get_time();
    while(nt-t0 < t){
        nt = get_time();
    }
    return;
}

int distancia(Vector3* vetor1, Vector3* vetor2){
    int x, y, distancia, k;
    int i;

    x = vetor1->x - vetor2->x;
    y = vetor1->y - vetor2->y;
    x = x * x;
    y = y * y;
    k = x + y;
    //Calcular raiz de dois
    distancia = k/2;
    for(i = 0; i < 10; i++){
        distancia = (distancia + (k/distancia))/2;
    }

    return distancia;
}

void set_angle(int x){
    //if rot atual for maior que rot obj gira pra esquerda
    //se nao gira pra direita
    Vector3 *angulo;
    get_gyro_angles(angulo);
    if(angulo->y > x){
        set_torque(-5,5);
        while(angulo->y > x){
            get_gyro_angles(angulo);
        }
        set_torque(0,0);
    }
    else{
        set_torque(5,-5);
        while(angulo->y < x){
            get_gyro_angles(angulo);
        }
        set_torque(0,0);
    }
}

void tostring(char str[], int num)
{
    int i, rem, len = 0, n;
 
    n = num;
    while (n != 0)
    {
        len++;
        n /= 10;
    }
    for (i = 0; i < len; i++)
    {
        rem = num % 10;
        num = num / 10;
        str[len - (i + 1)] = rem + '0';
    }
    str[len] = '\n';
    str[len + 1] = '\0';
}

//  Posição inicial do uóli: (734, 105, -75)

int main(){
    int n;
    char time[10000];
    char pos[10000];
    set_torque(20,20);
    //set_torque(-5,-5);
    set_time(10);
    while(get_us_distance() > 600){
        tostring(pos, get_time());
        puts(pos);
    }
    // while(get_us_distance() > 600){
    //     tostring(pos, get_us_distance());
    //     puts(pos);
    // }
    set_head_servo(0, 115);
    set_head_servo(1, 90);
    
    set_torque(1,1);

    tostring(pos, get_us_distance());
    puts(pos);
    
    //tostring(time, get_time());
    //puts(time);

    return 0;
}