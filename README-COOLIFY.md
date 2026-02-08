# Despliegue en Coolify con Nixpacks

Este proyecto está configurado para desplegarse en Coolify usando **Nixpacks con Nginx + PHP-FPM**.

## 🚀 Despliegue Rápido

### 1. Conectar Repositorio

1. Ve a tu instancia de Coolify
2. Crea un nuevo proyecto
3. Conecta este repositorio Git

### 2. Configuración en Coolify

- **Base Directory**: `/` (raíz del proyecto)
- **Publish Directory**: `/web` (opcional)
- **Build Pack**: Nixpacks (detectado automáticamente)

Coolify detectará automáticamente:
- ✅ PHP 8.3
- ✅ Composer (se ejecutará en la raíz)
- ✅ Node.js 20
- ✅ Nginx + PHP-FPM

### 3. Configurar Variables de Entorno

Ve a tu aplicación en Coolify → **Environment Variables** y agrega:

#### Variables Requeridas:

```bash
# Base de datos
DB_HOST=tu-servidor-mysql
DB_PORT=3306
DB_NAME=aldibier
DB_USER=drupal
DB_PASSWORD=tu-password-seguro

# Drupal
DRUPAL_HASH_SALT=genera-un-hash-aleatorio-aqui
DRUPAL_ENV=production
```

#### Generar Hash Salt:

```bash
php -r 'echo bin2hex(random_bytes(32)) . "\n";'
```

O usa:
```bash
openssl rand -hex 32
```

#### Variables Opcionales:

```bash
# Configuración adicional
DRUPAL_CONFIG_SYNC_DIRECTORY=../config/sync
DRUPAL_TRUSTED_HOST_PATTERNS=^tu-dominio\.com$,^www\.tu-dominio\.com$

# Límites PHP (si necesitas ajustarlos)
PHP_MEMORY_LIMIT=256M
PHP_MAX_EXECUTION_TIME=300

# SMTP (si usas correo)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=tu-email@gmail.com
SMTP_PASSWORD=tu-password
SMTP_PROTOCOL=tls

# Redis (si usas caché)
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=tu-redis-password
```

### 4. Crear Base de Datos

**Opción A: Usar servicio de base de datos de Coolify**

1. En Coolify, ve a tu proyecto
2. Click en **"Add Service"** → **"MySQL"** o **"MariaDB"**
3. Configura el servicio
4. Coolify creará automáticamente las variables `DB_HOST`, `DB_NAME`, etc.

**Opción B: Usar base de datos externa**

Configura manualmente las variables `DB_*` con los datos de tu servidor.

### 5. Desplegar

1. Click en **"Deploy"**
2. Espera a que termine el build (3-5 minutos)
3. Verifica en los logs que veas:
   - `composer install ... Installing dependencies`
   - `Starting Nginx...`

### 6. Importar Base de Datos

```bash
# Desde tu máquina local
mysql -h tu-servidor-db -u drupal -p aldibier < aldibier.sql

# O usando Coolify CLI (si está disponible)
coolify exec app -- mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME < aldibier.sql
```

### 7. Verificar

Visita tu dominio. ¡Debería funcionar! 🎉

## 🔧 Cómo Funciona

### Nixpacks + Nginx + PHP-FPM

El proyecto usa la configuración de Nixpacks para PHP similar a Symfony/Laravel:

1. **Setup Phase**: Instala PHP 8.3, Composer, Node.js, Nginx, PHP-FPM
2. **Install Phase**: Ejecuta `composer install` en la raíz
3. **Start Phase**: Inicia Nginx + PHP-FPM sirviendo desde `/app/web`

### Archivos de Configuración

- **`nixpacks.toml`** - Configuración de Nixpacks
- **`nginx.template.conf`** - Configuración de Nginx optimizada para Drupal
- **`settings.local.php`** - Configuración de Drupal (cargada automáticamente)

### Variables de Nixpacks

```toml
NIXPACKS_PHP_ROOT_DIR = "/app/web"        # Sirve desde /web (como Symfony/Laravel)
NIXPACKS_PHP_FALLBACK_PATH = "/index.php" # Usa index.php como router
```

## 🔍 Verificación Post-Despliegue

### Verificar que vendor existe:

```bash
coolify exec app -- ls -la /app/vendor
```

### Verificar Drupal:

```bash
coolify exec app -- /app/vendor/bin/drush status
```

### Limpiar caché:

```bash
coolify exec app -- /app/vendor/bin/drush cr
```

### Ejecutar actualizaciones de base de datos:

```bash
coolify exec app -- /app/vendor/bin/drush updatedb -y
```

### Ver logs:

```bash
# Logs de la aplicación
coolify logs app --follow

# Logs de Nginx
coolify exec app -- tail -f /var/log/nginx/access.log
coolify exec app -- tail -f /var/log/nginx/error.log
```

## 🐛 Troubleshooting

### Error: "502 Bad Gateway"

Significa que Nginx no puede conectarse a PHP-FPM.

```bash
# Verificar que PHP-FPM está corriendo
coolify exec app -- ps aux | grep php-fpm

# Verificar socket
coolify exec app -- ls -la /var/run/php-fpm.sock
```

### Error: "Database connection failed"

1. Verifica que las variables de entorno estén configuradas correctamente
2. Verifica que el servicio de base de datos esté corriendo
3. Prueba la conexión:

```bash
coolify exec app -- mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "SHOW DATABASES;"
```

### Error: "Trusted host settings"

Agrega la variable de entorno:

```bash
DRUPAL_TRUSTED_HOST_PATTERNS=^tu-dominio\.com$,^www\.tu-dominio\.com$
```

### Error: "Cannot write to files directory"

```bash
coolify exec app -- chmod -R 775 /app/web/sites/default/files
```

## 🔄 Actualizaciones y Mantenimiento

### Actualizar Drupal

```bash
# Conectarse al contenedor
coolify exec app -- bash

# Actualizar dependencias
composer update drupal/core* --with-all-dependencies

# Ejecutar actualizaciones de base de datos
vendor/bin/drush updatedb -y

# Limpiar caché
vendor/bin/drush cr

# Exportar configuración
vendor/bin/drush config:export -y
```

### Ejecutar Cron

```bash
coolify exec app -- /app/vendor/bin/drush cron
```

### Backup de Base de Datos

```bash
coolify exec app -- /app/vendor/bin/drush sql:dump --gzip --result-file=/tmp/backup.sql
```

## 🔐 Seguridad en Producción

### 1. Proteger settings.php:

```bash
coolify exec app -- chmod 444 /app/web/sites/default/settings.php
coolify exec app -- chmod 444 /app/web/sites/default/settings.local.php
```

### 2. Configurar HTTPS:

Coolify maneja automáticamente SSL con Let's Encrypt. Solo asegúrate de:
- Configurar tu dominio correctamente
- Habilitar "Force HTTPS" en Coolify

### 3. Configurar Trusted Host Patterns:

Agrega la variable de entorno con tu dominio real:

```bash
DRUPAL_TRUSTED_HOST_PATTERNS=^aldibier\.com$,^www\.aldibier\.com$
```

### 4. Deshabilitar módulos de desarrollo:

```bash
coolify exec app -- /app/vendor/bin/drush pm:uninstall devel webprofiler -y
```

## 📊 Estructura del Proyecto

```
/app/                          # Directorio de trabajo en Coolify
├── composer.json              # ✅ Composer install se ejecuta aquí
├── composer.lock
├── vendor/                    # ✅ Dependencias instaladas
├── nixpacks.toml             # ✅ Configuración de Nixpacks
├── nginx.template.conf       # ✅ Configuración de Nginx
├── web/                      # ✅ Drupal se sirve desde aquí (Nginx root)
│   ├── index.php             # ✅ Router de Drupal
│   ├── core/
│   ├── modules/
│   ├── themes/
│   └── sites/
│       └── default/
│           ├── settings.php       # ✅ Carga settings.local.php
│           ├── settings.local.php # ✅ Configuración de Coolify
│           └── files/             # ✅ Archivos subidos
└── config/
    └── sync/                 # ✅ Configuración exportada
```

## 📚 Documentación Adicional

- **`NIXPACKS_NGINX_PHPFPM.md`** - Explicación técnica de la configuración
- **`ACCION_INMEDIATA.md`** - Guía rápida de despliegue
- **`DESPLIEGUE_COOLIFY_FINAL.md`** - Guía detallada paso a paso

## 🆘 Soporte

- [Documentación de Coolify](https://coolify.io/docs)
- [Nixpacks PHP Provider](https://nixpacks.com/docs/providers/php)
- [Drupal Documentation](https://www.drupal.org/docs)

## 📋 Checklist de Despliegue

- [ ] Repositorio conectado en Coolify
- [ ] Base Directory configurado en `/`
- [ ] Variables de entorno configuradas
- [ ] Base de datos creada y conectada
- [ ] Despliegue ejecutado
- [ ] Logs verificados (composer install + Nginx)
- [ ] Base de datos importada
- [ ] Sitio accesible
- [ ] SSL habilitado
- [ ] Trusted host patterns configurados

---

**¡Listo para desplegar!** 🎉
