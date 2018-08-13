#include <iostream>
#include <cstdlib>
#include <fstream>

using namespace std;

int main(){
  int num, semilla;
  char cadena[128];
  //Se crea un fichero
  ofstream fs("file.txt");

  //Se le pide ingresar una semilla al usuario para hacer mas aleatorio el numegro generado
  cout << "Ingrese una semilla para rand()" <<endl; //nueva linea
  cin >> semilla;
  srand(semilla);

  //Se genera un numero aleatorio
  for(int i=0; i<10; i++){
    num=1+rand() % 50;
  }

  if(num % 2 == 0){
    num=1;
  }
  else{
    num=0;
  }

  //Se envia el numero al archivo file.txt
  fs << num << endl;
  //Se cierra el fichero
  fs.close();

  //Se abre un fichero
   ifstream fe("file.txt");

   // Leeremos el fichero
   fe.getline(cadena, 128);
   cout << cadena << endl;

   return 0;
}
