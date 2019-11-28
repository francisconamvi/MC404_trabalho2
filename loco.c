/**************************************************************** 
 * Description: Lógica de Controle (LoCo).
 *
 * Authors: Francisco Namias Vicente
 *          Luiz Felipe Eike Kina
 *
 * Date: 2019
 ***************************************************************/

#include "api_robot.h"
/*variaveis globais*/
int estado;
Vector3 amigo;

/*funcao para transformar int em string*/
void tostring(char str[], int num)
{
    int i, rem, len = 0, n;
 
    n = num;
    if(n==0){
        len++;
    }
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

/*funcao para calcular a distancia entre duas coordenadas*/
int distancia(Vector3* vetor1, Vector3* vetor2){
    int x, z, distancia, k;
    int i;

    x = vetor1->x - vetor2->x;
    z = vetor1->z - vetor2->z;
    x = x * x;
    z = z * z;
    k = x + z;
    //Calcular raiz de dois
    distancia = k/2;
    for(i = 0; i < 10; i++){
        distancia = (distancia + (k/distancia))/2;
    }

    return distancia;
}

/*delay puro, realmente apenas conta o tempo*/
void delay_puro(int t){
    int t0 = get_time();
    int nt = get_time();
    while(nt-t0 < t){
        nt = get_time();
    }
    return;
}

/*vira para um angulo especifico*/
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
        delay_puro(100);
        set_torque(0,0);
        delay_puro(100);
    }
    else{
        set_torque(10,-10);
        while(!((dif < 0 && dif < -180) || (dif > 0 && dif < 180))){
            get_gyro_angles(angulo);
            dif = angulo->y - x;
        }
        set_torque(-10,10);
        delay_puro(100);
        set_torque(0,0);
        delay_puro(100);
    }
}

/*principal funcao, que alem de contar tempo, verifica situaçoes*/
void delay(int t_d){
    int t0_d = get_time();
    int nt_d = get_time();
    Vector3* angle;
    while(nt_d-t0_d < t_d){
        get_current_GPS_position(angle);
        /*verifica se ja esta perto do amigo*/
        if(distancia(angle, &amigo) < 5){
            set_torque(-10,10);
            delay_puro(500);
            set_torque(0,0);
            delay_puro(200);
            return;
        }

        get_gyro_angles(angle);
        /*verifica se esta inclinado*/
        if(angle->x > 10 && angle->x < 180){
            return;
        }
        if(angle->x > 180 && angle->x < 350){
            return;
        }

        /*verifica se tem um objeto a frente*/
        if(get_us_distance() <= 1000){
            set_torque(-70,-70);
            delay_puro(400);
            set_torque(40,40);
            delay_puro(300);
            set_torque(-15,-15);
            delay_puro(1000);
            while(get_us_distance() <= 900){
                continue;
            }
            set_torque(50,50);
            delay_puro(400);
            set_torque(-10,-10);
            delay_puro(100);
            return;
        }
        
        //se ta perto da area perigosa
        for(int i = 0; i<(sizeof(dangerous_locations)/sizeof(dangerous_locations[0])); i++){
            get_current_GPS_position(angle);
            if(distancia(angle, &dangerous_locations[i]) < 12){
                int deltaX = dangerous_locations[i].x - angle->x;
                int movimento;
                int deltaZ = dangerous_locations[i].z - angle->z;
                if(deltaX < 0 && estado == 270){
                    set_torque(-80,-80);
                    delay_puro(500);
                    set_torque(30,30);
                    delay_puro(400);
                    if(deltaZ < 0){
                        set_angle(315);                     
                        set_torque(10, 10);
                        delay_puro(2000);
                    }
                    else{                     
                        set_angle(225);
                        set_torque(10, 10);
                        delay_puro(2000);
                    }
                    return;
                }
                else if(deltaX > 0 && estado == 90){
                    set_torque(-80,-80);
                    puts("I-P\n");
                    delay_puro(500);
                    set_torque(30,30);
                    delay_puro(400);
                    if(deltaZ > 0){
                        set_angle(135);    
                        set_torque(10, 10);
                        delay_puro(2000);
                    }
                    else{                       
                        set_angle(45);
                        set_torque(10, 10);
                        delay_puro(2000);
                    }
                    return;
                }
                else if(deltaZ > 0 && estado == 0){
                    set_torque(-80,-80);
                    delay_puro(500);
                    set_torque(30,30);
                    delay_puro(400);
                    if(deltaX > 0){
                        set_angle(315);    
                        set_torque(10, 10);
                        delay_puro(2000);
                    }
                    else{                     
                        set_angle(45);
                        set_torque(10, 10);
                        delay_puro(2000);
                    }
                    return;
                }
                else if(deltaZ < 0 && estado == 180){
                    set_torque(-80,-80);
                    delay_puro(500);
                    set_torque(30,30);
                    delay_puro(400);
                    if(deltaX < 0){
                        set_angle(135);    
                        set_torque(10, 10);
                        delay_puro(2000);
                    }
                    else{                       
                        set_angle(225);
                        set_torque(10, 10);
                        delay_puro(2000);
                    }
                    return;
                }
            }
        }
        nt_d = get_time();
    }
    return;
}




int main(){
    delay_puro(500); 
    set_head_servo(2,82);
    delay_puro(100);
    set_torque(-10, -10);
    delay_puro(2000);
    /*vai procurar cada amigo, em ordem*/
    for(int i = 0; i<(sizeof(friends_locations)/sizeof(friends_locations[0])); i++){
        Vector3* pos;
        get_current_GPS_position(pos);
        amigo = friends_locations[i];
        /*enquanto estiver longe do amigo*/
        while(distancia(pos, &amigo) > 5){
            get_current_GPS_position(pos);
            /*calcula a diferença na coordenada X, e se aproxima nesse direção*/
            int deltaX = amigo.x - pos->x;

            if(deltaX>0){
                puts("virou 90\n");
                set_angle(90);
                estado = 90;
            }
            else{
                puts("virou 270\n");
                set_angle(270);
                deltaX = -deltaX;
                estado = 270;
            }
            set_torque(10,10);
            /*delay é proporcional a distancia, pra que ele ande mais se a distancia estiver grande*/
            delay(deltaX*120+400);

            /*verifica se depois de andar chegou perto do amigo*/
            get_current_GPS_position(pos);            
            if(distancia(pos, &amigo) <= 5){
                /*se sim, da uma freiada*/
                set_torque(-50,-50);
                delay_puro(500);
                set_torque(40,40);
                delay_puro(200);
                break;
            }

            get_current_GPS_position(pos);
            /*calcula a diferença na coordenada Z, e se aproxima nesse direção*/
            int deltaZ = amigo.z - pos->z;
            if(deltaZ<0){
                puts("virou 180\n");
                set_angle(180);
                deltaZ = -deltaZ;
                estado = 180;
            }
            else{
                puts("virou 0\n");
                set_angle(0);
                estado = 0;
            }
            set_torque(10,10);
            /*delay é proporcional a distancia, pra que ele ande mais se a distancia estiver grande*/
            delay(deltaZ*120+400);
            get_current_GPS_position(pos);

        }
        puts("Encontrou amigo ");
        char amigo_char[2] = {i+48,'\0'};
        puts(amigo_char);
        puts("\n");
        
        /*printa o tempo que ja foi decorrido pra encontrar amigo*/
        char str_tempo[10];
        tostring(str_tempo, (get_time()/1000));
        puts("t: ");
        puts(str_tempo);
    }
    set_torque(0, 0);
    return 0;
}