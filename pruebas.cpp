#include <iostream>
#include <cstdlib>

using namespace std;

int main(){
  int num, semilla;

  cout << "Ingrese una semilla para rand()" <<endl; //nueva linea
  cin >> semilla;
  srand(semilla);

  for(int i=0; i<10; i++){
    num=1+rand() % 50;
    cout << num << endl;
  }

  if(num % 2 == 0){
    num=1;
    cout << "número par = " << num << endl;
  }
  else{
    num=0;
    cout << "número impar = " << num << endl;
  }

}
