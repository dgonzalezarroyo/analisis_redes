https://dgonzalezarroyo.github.io/analisis_redes/abrir_server.sh 

https://dgonzalezarroyo.github.io/analisis_redes/redespru.sh


Echo por Ulyses Huete y Aarón Barcenas

=========================

   1. Descripción general
=========================
El objetivo es simplificar el proceso completo, evitando configuraciones manuales y permitiendo visualizar los resultados desde un navegador. Además, el script incluye un sistema inteligente para gestionar el servidor web y la apertura del navegador, evitando duplicados y conflictos.

================================

   2. Funcionalidades del script
================================
    El script realiza las siguientes acciones:

    Detecta automáticamente la interfaz de red activa.

    Obtiene la dirección IP del equipo.

    Construye la red a escanear según la máscara detectada.

    Comprueba e instala las herramientas necesarias.

    Realiza un descubrimiento de dispositivos mediante ARP.

    Escanea servicios abiertos con Nmap.

    Ejecuta un análisis de vulnerabilidades con Nmap.

    Captura tráfico de red durante 30 segundos.

    Extrae peticiones HTTP de la captura.

    Genera informes HTML a partir de los resultados.

    Abre el navegador en http://localhost:8000 solo si no está ya abierto.

    Inicia el servidor web solo si no existe ya uno en el puerto 8000.

========================

   3. Requisitos previos
========================
    El script requiere un sistema basado en Debian/Ubuntu/MAX con permisos de sudo.

Herramientas utilizadas:

arp-scan
nmap
tcpdump
tshark
xsltproc
python3

El script instala automáticamente cualquier herramienta que falte.

=====================

   4. Uso del script
=====================
    Guardar el script en un archivo, por ejemplo:

nombre_del_script.sh

Dar permisos de ejecución:

chmod +x nombre_del_script.sh

Ejecutarlo:

./nombre_del_script.sh

El proceso completo se ejecutará de forma automática.

==========================================

   5. Explicación de conceptos utilizados
==========================================
    Interfaz de red: dispositivo por el que el equipo se conecta a la red (eth0, enp2	s0, wlp2s0…).
    Dirección IP: identifica al equipo dentro de la red, por ejemplo: 10.225.255.10/25.
    Máscara de subred: define el tamaño de la red (/24, /25, /26…).

=========================

   6. Archivos generados
=========================
    El script genera:

dispositivos.txt
servicios.xml
vulnerabilidades.xml
captura.pcap
http_requests.txt

Además, crea la carpeta informe_web/ con:

servicios.html
vulnerabilidades.html
dispositivos.txt
http_requests.txt
index.html

=============================================

   7. Volver a abrir el servidor más adelante
=============================================
    Si el servidor web no está activo, puede iniciarse manualmente:

cd informe_web
python3 -m http.server 8000

O ejecutando el script auxiliar:

abrir_server.sh

Si aparece “puerto 8000 en uso”:

lsof -i :8000
kill -9 PID

==========================================================

   8. Explicación detallada del funcionamiento del script
==========================================================

8.1. Detección automática de red e interfaz

El script identifica la primera interfaz activa que no sea “lo” y obtiene su IP con máscara. Con esa información construye automáticamente la red a escanear, por ejemplo:

192.168.1.23/24

Esto permite que el script funcione sin configuraciones manuales.

8.2. Comprobación e instalación de herramientas

Incluye una función que instala herramientas si no existen. Se verifica:

arp-scan
nmap
tcpdump
tshark
xsltproc

Esto garantiza que el script pueda ejecutarse incluso en sistemas recién instalados.

8.3. Fase 1: Descubrimiento de dispositivos

Se ejecuta:

arp-scan -I interfaz red > dispositivos.txt

Detecta todos los dispositivos conectados a la red mediante ARP.

8.4. Fase 2: Escaneo de servicios

Se ejecuta:

nmap -sV -oX servicios.xml red

Detecta puertos abiertos e identifica versiones de servicios.

8.5. Fase 3: Análisis de vulnerabilidades

Se ejecuta:

nmap -sV --script vuln -oX vulnerabilidades.xml red

Se eliminan líneas de errores de scripts fallidos.

8.6. Fase 4: Captura de tráfico

Se captura tráfico durante 30 segundos:

tcpdump -i interfaz -w captura.pcap -G 30 -W 1

8.7. Fase 5: Extracción de peticiones HTTP

Se extraen peticiones HTTP:

tshark -r captura.pcap -Y "http.request" > http_requests.txt

8.8. Fase 6: Generación de informes HTML

Se crea la carpeta informe_web/ y se generan informes HTML con xsltproc:

servicios.html
vulnerabilidades.html

Se copian también:

dispositivos.txt
http_requests.txt

Se genera un index.html que sirve como menú principal.

8.9. Fase 7: Gestión inteligente del servidor web

El script comprueba si el puerto 8000 ya está en uso.
Si no lo está, inicia:

python3 -m http.server 8000 &

Luego comprueba si el navegador ya tiene abierta la URL.
Si no está abierta, ejecuta:

xdg-open http://localhost:8000

==========================================

   9. Explicación del script auxiliar abrir_server.sh
==========================================
    Este script permite volver a levantar el servidor web sin repetir todo el análisis.

    Comprueba si existe la carpeta informe_web.

    Entra en ella.

    Ejecuta:

python3 -m http.server 8000

==========================================

   10. Gestión de errores del puerto 8000
==========================================
    Si aparece:

Address already in use

Ejecutar:

lsof -i :8000
kill -9 PID

Luego volver a ejecutar:

./abrir_server.sh

