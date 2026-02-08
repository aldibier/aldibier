#!/bin/bash
set -e

# Usar el puerto de la variable de entorno PORT o 8080 por defecto
PORT=${PORT:-8080}

echo "=== Starting Drupal on port $PORT ==="
echo "=== Document root: $(pwd)/web ==="

# Verificar que vendor existe
if [ ! -d "vendor" ]; then
    echo "ERROR: vendor directory not found!"
    echo "Running composer install..."
    composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist
fi

# Verificar que web/core existe
if [ ! -d "web/core" ]; then
    echo "ERROR: web/core directory not found!"
    exit 1
fi

# Crear directorio de archivos si no existe
mkdir -p web/sites/default/files
chmod -R 775 web/sites/default/files

echo "=== Starting PHP built-in server ==="
echo "=== Access your site at http://localhost:$PORT ==="

# Iniciar servidor PHP con el router de Drupal
cd web
php -S 0.0.0.0:$PORT .ht.router.php
