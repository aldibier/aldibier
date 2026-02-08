# 🚀 Despliegue en Coolify - Guía Completa

## ✅ Configuración del Proyecto

Este proyecto usa **Nixpacks con Nginx + PHP-FPM** para despliegue en Coolify.

### Archivos de Configuración:
- ✅ `nixpacks.toml` - Configuración de Nixpacks
- ✅ `nginx.template.conf` - Configuración de Nginx para Drupal
- ✅ `settings.local.php` - Configuración de Drupal (carga automáticamente)

## 📋 Pasos para Desplegar

### 1. Commit y Push

```bash
git add .
git commit -m "Configure Nixpacks with Nginx + PHP-FPM for Drupal"
git push
```

### 2. Conectar Repositorio en Coolify

1. Ve a tu instancia de Coolify
2. Crea un nuevo proyecto
3. Conecta este repositorio Git
4. Configura:
   - **Base Directory**: `/`
   - **Publish Directory**: `/web` (opcional)
   - **Build Pack**: Nixpacks (auto-detectado)

### 3. Configurar Variables de Entorno

En Coolify → Environment Variables:

#### Requeridas:

```bash
DB_HOST=tu-servidor-mysql
DB_PORT=3306
DB_NAME=aldibier
DB_USER=drupal
DB_PASSWORD=tu-password-seguro
DRUPAL_HASH_SALT=genera-hash-aqui
DRUPAL_ENV=production
```

Genera el hash salt:
```bash
php -r 'echo bin2hex(random_bytes(32)) . "\n";'
```

#### Opcionales:

```bash
DRUPAL_CONFIG_SYNC_DIRECTORY=../config/sync
DRUPAL_TRUSTED_HOST_PATTERNS=^tu-dominio\.com$,^www\.tu-dominio\.com$
PHP_MEMORY_LIMIT=256M
PHP_MAX_EXECUTION_TIME=300
```

### 4. Crear Base de Datos

**Opción A:** En Coolify, agrega un servicio MySQL/MariaDB

**Opción B:** Usa una base de datos externa

### 5. Desplegar

1. Click en **"Deploy"**
2. Espera 3-5 minutos
3. Verifica en logs:
   - `composer install ... Installing dependencies`
   - `Starting Nginx...`

### 6. Importar Base de Datos

```bash
mysql -h tu-servidor-db -u drupal -p aldibier < aldibier.sql
```

### 7. Verificar

Visita tu dominio. Prueba:
- `/` - Página principal
- `/user/login` - Login
- `/core/install.php` - Instalador (si es nuevo)

## 🔍 Verificación Post-Despliegue

### Verificar servicios:

```bash
# Nginx
coolify exec app -- ps aux | grep nginx

# PHP-FPM
coolify exec app -- ps aux | grep php-fpm

# Vendor directory
coolify exec app -- ls -la /app/vendor
```

### Comandos Drush:

```bash
# Estado del sitio
coolify exec app -- /app/vendor/bin/drush status

# Limpiar caché
coolify exec app -- /app/vendor/bin/drush cr

# Actualizar base de datos
coolify exec app -- /app/vendor/bin/drush updatedb -y

# Ejecutar cron
coolify exec app -- /app/vendor/bin/drush cron
```

## 🐛 Troubleshooting

### Error: "502 Bad Gateway"

PHP-FPM no está corriendo o no puede conectarse.

```bash
coolify exec app -- ps aux | grep php-fpm
coolify exec app -- ls -la /var/run/php-fpm.sock
```

### Error: "vendor/autoload.php not found"

Composer install no se ejecutó.

**Solución:**
1. Verifica que Base Directory sea `/` en Coolify
2. Revisa los logs de build
3. Busca errores en `composer install`

### Error: "Database connection failed"

```bash
# Verificar variables
coolify exec app -- env | grep DB_

# Probar conexión
coolify exec app -- mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "SHOW DATABASES;"
```

### Error: "File not found" en rutas

Verifica la configuración de Nginx:

```bash
coolify exec app -- cat /etc/nginx/nginx.conf
coolify exec app -- env | grep NIXPACKS
```

Debe mostrar:
```
NIXPACKS_PHP_ROOT_DIR=/app/web
NIXPACKS_PHP_FALLBACK_PATH=/index.php
```

### Error: "Cannot write to files directory"

```bash
coolify exec app -- chmod -R 775 /app/web/sites/default/files
```

### Ver Logs:

```bash
# Logs de aplicación
coolify logs app --follow

# Logs de Nginx
coolify exec app -- tail -f /var/log/nginx/access.log
coolify exec app -- tail -f /var/log/nginx/error.log
```

## 🔐 Seguridad en Producción

### 1. Proteger archivos de configuración:

```bash
coolify exec app -- chmod 444 /app/web/sites/default/settings.php
coolify exec app -- chmod 444 /app/web/sites/default/settings.local.php
```

### 2. Configurar HTTPS:

Coolify maneja SSL automáticamente. Asegúrate de:
- Configurar tu dominio
- Habilitar "Force HTTPS"

### 3. Trusted Host Patterns:

```bash
DRUPAL_TRUSTED_HOST_PATTERNS=^aldibier\.com$,^www\.aldibier\.com$
```

### 4. Deshabilitar módulos de desarrollo:

```bash
coolify exec app -- /app/vendor/bin/drush pm:uninstall devel webprofiler -y
```

## 🔄 Mantenimiento

### Actualizar Drupal:

```bash
coolify exec app -- bash
composer update drupal/core* --with-all-dependencies
vendor/bin/drush updatedb -y
vendor/bin/drush cr
vendor/bin/drush config:export -y
```

### Backup:

```bash
# Base de datos
coolify exec app -- /app/vendor/bin/drush sql:dump --gzip --result-file=/tmp/backup.sql

# Archivos
coolify exec app -- tar -czf /tmp/files-backup.tar.gz /app/web/sites/default/files
```

## 📊 Estructura del Proyecto

```
/app/
├── composer.json              # Composer install aquí
├── vendor/                    # Dependencias
├── nixpacks.toml             # Config Nixpacks
├── nginx.template.conf       # Config Nginx
└── web/                      # Nginx root
    ├── index.php             # Router Drupal
    ├── core/
    ├── modules/
    ├── themes/
    └── sites/
        └── default/
            ├── settings.php
            ├── settings.local.php
            └── files/
```

## 🎯 Checklist Final

- [ ] Commit y push
- [ ] Repositorio conectado en Coolify
- [ ] Base Directory = `/`
- [ ] Variables de entorno configuradas
- [ ] Base de datos creada
- [ ] Despliegue ejecutado
- [ ] Logs verificados
- [ ] Base de datos importada
- [ ] Sitio accesible
- [ ] SSL habilitado
- [ ] Trusted host patterns configurados
- [ ] Permisos de archivos correctos

## 📚 Documentación

- **`README-COOLIFY.md`** - Guía de despliegue
- **`NIXPACKS_NGINX_PHPFPM.md`** - Detalles técnicos
- **`ACCION_INMEDIATA.md`** - Guía rápida

---

**¡Todo listo para producción!** 🎉
