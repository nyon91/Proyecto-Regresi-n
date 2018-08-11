#include <iostream>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

using namespace std;

int main() {

<<<<<<< HEAD
    cout << "Ejecutando las pruebas del ";
=======
>>>>>>> 939bfd0131d918b7b4fc5134ce673b1755b6f5de
    char fecha[25];//ctime devuelve 26 caracteres pero tambien se podría usar un puntero de char
    time_t current_time;
    current_time=time(NULL);
    ctime(&current_time);
    strcpy(fecha, ctime(&current_time));
<<<<<<< HEAD
    cout << fecha;
=======
    cout << "Ejecutando las pruebas del " << fecha << endl;
>>>>>>> 939bfd0131d918b7b4fc5134ce673b1755b6f5de
    return 0;
}
