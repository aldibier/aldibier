#!/bin/bash
set -e

# Usar el puerto de la variable de entorno PORT o 8080 por defecto
PORT=${PORT:-8080}

echo "=== Configurando Nginx para usar puerto $PORT ==="

# Reemplazar el puerto en la configuración de Nginx
sed -i "s/listen 8080;/listen $PORT;/g" /etc/nginx/http.d/default.conf

echo "=== Verificando configuración de Nginx ==="
nginx -t

echo "=== Iniciando servicios con Supervisor ==="
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
