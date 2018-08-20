#!/bin/bash

clear all
cd /home/juan/Documentos/cron
./nombre

while IFS=' ' read -r line || [[ -n "$line" ]]; do printf ""; done < nombre.txt

./pruebas

for linea in $(cat file.txt);

do

var=1

if [ $linea -eq $var ]; then
        cd /home/juan/Documentos/cron
	git add "$line"
#       git add .
        git commit -m "committing new configuration changes!"
        git push origin master
        echo ""
        echo "git repo updated"
else
        echo "Fallo las pruebas"
fi;

done
