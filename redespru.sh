#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "=============================================="
echo "  PRACTICA DE CIBERSEGURIDAD - AUTOMATIZADA"
echo "=============================================="

echo ""
echo "=== DETECTANDO RED E INTERFAZ ==="
echo ""

# Detectar primera interfaz activa que no sea 'lo'
INTERFAZ=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n 1)

# Detectar IP + máscara de esa interfaz (ej: 192.168.1.23/24)
IP_CIDR=$(ip -4 addr show "$INTERFAZ" | grep inet | awk '{print $2}')

# Si quieres usar exactamente la red detectada (recomendado):
RED="$IP_CIDR"

echo "Interfaz detectada: $INTERFAZ"
echo "Red a escanear:     $RED"
echo ""

echo "=== Comprobando herramientas necesarias ==="

instalar_si_falta() {
    if ! command -v "$1" &> /dev/null; then
        echo "→ Instalando $1 ..."
        apt install -y "$1"
    else
        echo "→ $1 ya está instalado."
    fi
}

apt update

instalar_si_falta arp-scan
instalar_si_falta nmap
instalar_si_falta tcpdump
instalar_si_falta tshark
instalar_si_falta xsltproc

echo ""
echo "=== FASE 1: Descubrimiento de la red (arp-scan) ==="
arp-scan -I "$INTERFAZ" "$RED" > dispositivos.txt
echo "Guardado en dispositivos.txt"

echo ""
echo "=== FASE 2: Análisis de servicios (Nmap -sV) ==="
nmap -sV -oX servicios.xml "$RED"
echo "Guardado en servicios.xml"

echo ""
echo "=== FASE 3: Detección de vulnerabilidades (Nmap --script vuln) ==="
nmap -sV --script vuln -oX vulnerabilidades.xml "$RED"
echo "Guardado en vulnerabilidades.xml"

sed -i '/Script execution failed/d' vulnerabilidades.xml

echo ""
echo "=== FASE 4: Captura de tráfico durante 30 segundos ==="
tcpdump -i "$INTERFAZ" -w captura.pcap -G 30 -W 1
echo "Guardado en captura.pcap"

echo ""
echo "=== FASE 5: Análisis de tráfico HTTP con tshark ==="
tshark -r captura.pcap -Y "http.request" > http_requests.txt
echo "Guardado en http_requests.txt"

echo ""
echo "=== FASE 6: Generando informes HTML ==="
mkdir -p informe_web

xsltproc /usr/share/nmap/nmap.xsl servicios.xml > informe_web/servicios.html
xsltproc /usr/share/nmap/nmap.xsl vulnerabilidades.xml > informe_web/vulnerabilidades.html

cp dispositivos.txt informe_web/
cp http_requests.txt informe_web/

###############################################
# Crear index.html automáticamente
###############################################

cat > informe_web/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Analizador de Redes</title>
</head>
<body>
    <h1>Analizador de Redes</h1>
    <p>Selecciona un informe:</p>

    <a href="servicios.html">Servicios detectados</a><br>
    <a href="vulnerabilidades.html">Vulnerabilidades</a><br>
    <a href="dispositivos.txt">Dispositivos detectados</a><br>
    <a href="http_requests.txt">Peticiones HTTP capturadas</a><br>
</body>
</html>
EOF

echo "Informes HTML generados en informe_web/"

echo ""
echo "=== FASE 7: Abrir navegador si no está abierto ==="

if ss -tuln | grep -q ":8000"; then
    echo "Servidor web ya está activo en el puerto 8000."
else
    echo "Iniciando servidor web en puerto 8000..."
    cd informe_web || exit 1
    python3 -m http.server 8000 &
    sleep 2
fi

if ! pgrep -f "http://localhost:8000" > /dev/null; then
    xdg-open http://localhost:8000 2>/dev/null
    echo "Abriendo navegador en http://localhost:8000"
else
    echo "El navegador ya está mostrando http://localhost:8000"
fi

echo ""
echo "=============================================="
echo "  PROCESO COMPLETADO"
echo "=============================================="

