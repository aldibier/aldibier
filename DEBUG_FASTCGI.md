# 🔍 Debug: FastCGI "Primary script unknown"

## Problema

```
FastCGI sent in stderr: "Primary script unknown"
```

Esto significa que PHP-FPM no puede encontrar el archivo PHP.

## Diagnóstico

Necesitamos verificar:

1. **¿Dónde está buscando Nginx?**
2. **¿Dónde están realmente los archivos?**
3. **¿Qué valor tiene `$document_root`?**

## Comandos de Diagnóstico

Ejecuta estos comandos en Coolify:

```bash
# 1. Verificar estructura de directorios
coolify exec app -- ls -la /app/
coolify exec app -- ls -la /app/web/
coolify exec app -- ls -la /app/web/core/

# 2. Verificar que install.php existe
coolify exec app -- ls -la /app/web/core/install.php

# 3. Verificar configuración de Nginx procesada
coolify exec app -- cat /nginx.conf | grep root
coolify exec app -- cat /nginx.conf | grep SCRIPT_FILENAME

# 4. Verificar variables de entorno
coolify exec app -- env | grep NIXPACKS

# 5. Verificar proceso PHP-FPM
coolify exec app -- ps aux | grep php-fpm
```

## Posibles Causas

### 1. Root directory incorrecto

Si `NIXPACKS_PHP_ROOT_DIR=/app/web`, entonces:
- Nginx root: `/app/web`
- Archivo: `/app/web/core/install.php`
- URL: `/core/install.php`
- SCRIPT_FILENAME debería ser: `/app/web/core/install.php`

### 2. Archivo no existe en el contenedor

Verifica que `composer install` copió todo correctamente.

### 3. Permisos incorrectos

PHP-FPM necesita poder leer el archivo.

## Solución Temporal

Mientras diagnosticamos, prueba acceder a:
- `/` - Página principal (debería funcionar)
- `/index.php` - Directamente (debería funcionar)

Si `/index.php` funciona pero `/core/install.php` no, el problema es específico de rutas con subdirectorios.

## Próximos Pasos

1. Ejecuta los comandos de diagnóstico
2. Comparte la salida
3. Ajustaremos la configuración según los resultados
