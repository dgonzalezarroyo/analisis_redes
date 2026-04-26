#!/bin/bash

BASE_DIR=$(dirname "$(realpath "$0")")
TARGET_DIR="$BASE_DIR/informe_web"

# Crear la carpeta si no existe
if [ ! -d "$TARGET_DIR" ]; then
    echo "La carpeta informe_web no existe. Creándola..."
    mkdir -p "$TARGET_DIR" 
fi

# Entrar en la carpeta
cd "$TARGET_DIR"

# Levantar el servidor
python3 -m http.server 8000

