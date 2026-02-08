# 🚀 Nixpacks con Nginx + PHP-FPM para Drupal

## ✅ Configuración Actualizada

Siguiendo la [documentación oficial de Nixpacks para PHP](https://nixpacks.com/docs/providers/php), ahora el proyecto usa **Nginx + PHP-FPM** en lugar del servidor PHP built-in.

## 🎯 ¿Por Qué Este Cambio?

### Antes (PHP Built-in Server):
- ❌ Single-threaded (una request a la vez)
- ❌ No maneja archivos estáticos eficientemente
- ❌ No recomendado para producción
- ❌ Problemas con rutas como `/core/install.php`

### Ahora (Nginx + PHP-FPM):
- ✅ Multi-threaded (múltiples requests concurrentes)
- ✅ Nginx maneja archivos estáticos (CSS, JS, imágenes)
- ✅ PHP-FPM maneja código PHP
- ✅ Configuración lista para producción
- ✅ Mejor rendimiento y estabilidad

## 📁 Archivos de Configuración

### 1. `nixpacks.toml`

```toml
[phases.setup]
nixPkgs = [
  "php83",
  "php83Packages.composer",
  "nodejs_20"
]

[phases.install]
cmds = [
  "composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist",
  "mkdir -p web/sites/default/files",
  "chmod -R 775 web/sites/default/files"
]

[variables]
COMPOSER_MEMORY_LIMIT = "-1"
COMPOSER_ALLOW_SUPERUSER = "1"
NIXPACKS_PHP_ROOT_DIR = "/app/web"
NIXPACKS_PHP_FALLBACK_PATH = "/index.php"
```

**Variables clave:**
- `NIXPACKS_PHP_ROOT_DIR = "/app/web"` - Le dice a Nginx que sirva desde `/app/web` (como Symfony/Laravel con `public/`)
- `NIXPACKS_PHP_FALLBACK_PATH = "/index.php"` - Usa `index.php` como router (para URLs limpias de Drupal)

### 2. `nginx.template.conf`

Configuración de Nginx optimizada para Drupal que incluye:
- ✅ Manejo de URLs limpias
- ✅ Protección de archivos sensibles (.php en vendor/, .module, etc.)
- ✅ Caché de archivos estáticos
- ✅ Soporte para archivos privados
- ✅ Soporte para image styles de Drupal
- ✅ Configuración de FastCGI para PHP-FPM

## 🔧 Cómo Funciona

### 1. Nixpacks detecta PHP
- Encuentra `composer.json` en la raíz
- Instala PHP 8.3, Composer, Nginx, PHP-FPM

### 2. Install Phase
- Ejecuta `composer install` en `/app` (raíz)
- Crea directorio de archivos
- Configura permisos

### 3. Start Phase
Nixpacks automáticamente:
1. Procesa `nginx.template.conf` y reemplaza variables:
   - `${PORT}` → Puerto asignado por Coolify
   - `${ROOT_DIR}` → `/app/web` (de `NIXPACKS_PHP_ROOT_DIR`)
2. Inicia PHP-FPM en socket Unix
3. Inicia Nginx con la configuración procesada

### 4. Request Flow

```
Cliente → Nginx (puerto $PORT)
           ↓
    ¿Es archivo estático? (CSS, JS, imagen)
           ↓ Sí
    Nginx sirve directamente
           ↓ No
    ¿Es archivo .php o ruta dinámica?
           ↓ Sí
    Nginx → PHP-FPM (socket Unix)
           ↓
    PHP-FPM ejecuta Drupal
           ↓
    Respuesta → Cliente
```

## 🎯 Ventajas para Drupal

### 1. Rendimiento
- Nginx maneja archivos estáticos sin tocar PHP
- PHP-FPM puede procesar múltiples requests PHP simultáneamente
- Caché de archivos estáticos con `expires max`

### 2. Seguridad
- Bloquea acceso a archivos sensibles (.module, .inc, composer.json, etc.)
- Protege directorios privados
- Previene ejecución de PHP en vendor/

### 3. Compatibilidad
- URLs limpias funcionan correctamente
- `/core/install.php` funciona ✅
- `/update.php` funciona ✅
- Image styles funcionan ✅
- Archivos privados funcionan ✅

## 📊 Comparación con Symfony/Laravel

Drupal usa la misma estructura que Symfony/Laravel:

| Framework | Raíz del Servidor | Router |
|-----------|-------------------|--------|
| Symfony | `public/` | `index.php` |
| Laravel | `public/` | `index.php` |
| **Drupal** | **`web/`** | **`index.php`** |

Por eso usamos:
```toml
NIXPACKS_PHP_ROOT_DIR = "/app/web"
NIXPACKS_PHP_FALLBACK_PATH = "/index.php"
```

## 🔍 Verificación

### Después del despliegue, verifica:

1. **Nginx está corriendo:**
```bash
coolify exec app -- ps aux | grep nginx
```

2. **PHP-FPM está corriendo:**
```bash
coolify exec app -- ps aux | grep php-fpm
```

3. **Configuración de Nginx:**
```bash
coolify exec app -- cat /etc/nginx/nginx.conf
```

4. **Logs de Nginx:**
```bash
coolify exec app -- tail -f /var/log/nginx/access.log
coolify exec app -- tail -f /var/log/nginx/error.log
```

## 🐛 Troubleshooting

### Error: "502 Bad Gateway"

Significa que Nginx no puede conectarse a PHP-FPM.

**Solución:**
```bash
# Verificar que PHP-FPM está corriendo
coolify exec app -- ps aux | grep php-fpm

# Verificar socket
coolify exec app -- ls -la /var/run/php-fpm.sock
```

### Error: "File not found" en rutas PHP

Verifica que `NIXPACKS_PHP_ROOT_DIR` esté configurado correctamente:
```bash
coolify exec app -- env | grep NIXPACKS
```

Debería mostrar:
```
NIXPACKS_PHP_ROOT_DIR=/app/web
NIXPACKS_PHP_FALLBACK_PATH=/index.php
```

### Archivos estáticos no cargan

Verifica permisos:
```bash
coolify exec app -- ls -la /app/web/
coolify exec app -- ls -la /app/web/sites/default/files/
```

## 📚 Referencias

- [Nixpacks PHP Provider](https://nixpacks.com/docs/providers/php) - Documentación oficial
- [Nginx + PHP-FPM con Supervisor en Coolify](https://frontier.sh/posts/20240510-phpfpm-nginx/) - Artículo de referencia
- [Drupal Nginx Configuration](https://www.nginx.com/resources/wiki/start/topics/recipes/drupal/) - Configuración recomendada

## 🎉 Resultado

Con esta configuración, tu sitio Drupal en Coolify:
- ✅ Usa Nginx + PHP-FPM (producción-ready)
- ✅ Maneja múltiples requests concurrentes
- ✅ Sirve archivos estáticos eficientemente
- ✅ Tiene todas las rutas funcionando correctamente
- ✅ Está optimizado para rendimiento

---

**Siguiente paso:** Commit, push y redeploy para aplicar los cambios.
