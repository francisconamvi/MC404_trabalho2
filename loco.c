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


void delay(int t){
    int t0 = get_time();
    int nt = get_time();
    Vector3* angle;
    while(nt-t0 < t){
        get_gyro_angles(angle);
        //se ta inclinado
        if(angle->x > 10 && angle->x < 350){
            set_torque(0, 0);
            return;
        }
        //se tem objeto na frente 
        if(get_us_distance() <= 750){
            set_torque(0, 0);
            return;
        }
        
        //se ta perto da area perigosa
    
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
    int dif = angulo->y - x;

    if((dif < 0 && dif < -180) || (dif > 0 && dif < 180)){

        set_torque(-10,10);
        while((dif < 0 && dif < -180) || (dif > 0 && dif < 180)){
            get_gyro_angles(angulo);
            dif = angulo->y - x;
        }
        set_torque(10,-10);
        delay(100);
        set_torque(0,0);
        delay(100);
    }
    else{
        set_torque(10,-10);
        while(!((dif < 0 && dif < -180) || (dif > 0 && dif < 180))){
            get_gyro_angles(angulo);
            dif = angulo->y - x;
        }
        set_torque(-10,10);
        delay(100);
        set_torque(0,0);
        delay(100);
    }
}


int main(){
    /*Posição inicial do uóli: (734, 105, -75);*/
    
    delay(500);    
    for(int i = 0; i<(sizeof(friends_locations)/sizeof(friends_locations[0])); i++){
        Vector3* pos;
        Vector3 amigo;
        get_current_GPS_position(pos);
        amigo = friends_locations[i];
        while(distancia(pos, &amigo) > 5){
            get_current_GPS_position(pos);
            int deltaX = amigo.x - pos->x;
            if(deltaX>0){
                puts("virou 90\n");
                set_angle(90);
            }
            else{
                puts("virou 270\n");
                set_angle(270);
                deltaX = -deltaX;
            }
            set_torque(10,10);
            delay(deltaX*100);

            get_current_GPS_position(pos);
            int deltaZ = amigo.z - pos->z;
            if(deltaZ<0){
                puts("virou 180\n");
                set_angle(180);
                deltaZ = -deltaZ;
            }
            else{
                puts("virou 0\n");
                set_angle(0);
            }
            set_torque(10,10);
            delay(deltaZ*100);
            get_current_GPS_position(pos);

        }
        puts("Encontrou amigo ");
        char amigo_char[2] = {i+48,'\0'};
        puts(amigo_char);
        puts("\n");
    }
    set_torque(0, 0);

    return 0;
}