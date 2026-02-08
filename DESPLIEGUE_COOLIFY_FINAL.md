# 🚀 Despliegue en Coolify - Configuración Final

## ✅ Configuración Actual

### En Coolify:
- **Base Directory**: `/` ✅ (raíz del proyecto)
- **Publish Directory**: `/web` ✅ (donde está index.php)
- **Build Pack**: Nixpacks ✅

### En el Proyecto:
- ✅ `nixpacks.toml` configurado correctamente
- ✅ `settings.local.php` creado (carga automáticamente desde settings.php)
- ✅ `composer.json` en la raíz
- ✅ Estructura Drupal en `/web`

## 📋 Pasos para Desplegar

### 1. Commit y Push

```bash
git add .
git commit -m "Configure Coolify deployment with settings.local.php"
git push
```

### 2. Configurar Variables de Entorno en Coolify

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

O usa este comando en tu terminal:
```bash
openssl rand -hex 32
```

#### Variables Opcionales:

```bash
# Configuración adicional
DRUPAL_CONFIG_SYNC_DIRECTORY=../config/sync
DRUPAL_TRUSTED_HOST_PATTERNS=^tu-dominio\.com$,^www\.tu-dominio\.com$

# Límites PHP
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

### 3. Crear Base de Datos en Coolify

**Opción A: Usar servicio de base de datos de Coolify**

1. En Coolify, ve a tu proyecto
2. Click en **"Add Service"** → **"MySQL"** o **"MariaDB"**
3. Configura el servicio
4. Coolify creará automáticamente las variables `DB_HOST`, `DB_NAME`, etc.

**Opción B: Usar base de datos externa**

Configura manualmente las variables `DB_*` con los datos de tu servidor.

### 4. Redeploy

1. En Coolify, click en **"Redeploy"**
2. Espera a que termine el build (3-5 minutos)
3. Verifica en los logs que veas:

```
[phases.install]
composer install --no-dev --optimize-autoloader
Loading composer repositories with package information
Installing dependencies from lock file
Package operations: 150 installs, 0 updates, 0 removals
  - Installing drupal/core (11.3.3): Extracting archive
  ...
Generating optimized autoload files
```

### 5. Importar Base de Datos

Una vez desplegado, importa tu base de datos:

```bash
# Opción 1: Desde tu máquina local
mysql -h tu-servidor-db -u drupal -p aldibier < aldibier.sql

# Opción 2: Usando Coolify CLI (si está disponible)
coolify exec app -- mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME < aldibier.sql
```

### 6. Verificar el Sitio

1. Visita tu dominio en el navegador
2. Deberías ver tu sitio Drupal cargando correctamente
3. Si ves errores, revisa los logs (ver sección Troubleshooting)

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

## 🐛 Troubleshooting

### Error: "vendor/autoload.php not found"

Esto significa que `composer install` no se ejecutó. Verifica:

1. **Base Directory** en Coolify debe ser `/` (no `/web`)
2. En los logs, busca `composer install` y verifica que se ejecutó
3. Si el problema persiste, cambia a Dockerfile (ver `SOLUCION_VENDOR_FALTANTE.md`)

### Error: "Database connection failed"

1. Verifica que las variables de entorno estén configuradas correctamente
2. Verifica que el servicio de base de datos esté corriendo
3. Prueba la conexión manualmente:

```bash
coolify exec app -- mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "SHOW DATABASES;"
```

### Error: "Trusted host settings"

Agrega la variable de entorno:

```bash
DRUPAL_TRUSTED_HOST_PATTERNS=^tu-dominio\.com$,^www\.tu-dominio\.com$
```

O edita `settings.local.php` y agrega tu dominio manualmente.

### Error: "Cannot write to files directory"

```bash
coolify exec app -- chmod -R 775 /app/web/sites/default/files
coolify exec app -- chown -R www-data:www-data /app/web/sites/default/files
```

### Ver Logs en Tiempo Real:

```bash
coolify logs app --follow
```

## 📊 Estructura del Proyecto

```
/app/                          # Directorio de trabajo en Coolify
├── composer.json              # ✅ Composer install se ejecuta aquí
├── composer.lock
├── vendor/                    # ✅ Dependencias instaladas
├── web/                       # ✅ Drupal se sirve desde aquí
│   ├── index.php
│   ├── core/
│   ├── modules/
│   ├── themes/
│   └── sites/
│       └── default/
│           ├── settings.php   # ✅ Carga settings.local.php
│           ├── settings.local.php  # ✅ Configuración de Coolify
│           └── files/         # ✅ Archivos subidos
└── config/
    └── sync/                  # ✅ Configuración exportada
```

## 🎯 Checklist Final

- [ ] Commit y push de los cambios
- [ ] Variables de entorno configuradas en Coolify
- [ ] Base de datos creada y conectada
- [ ] Redeploy ejecutado
- [ ] Logs verificados (composer install ejecutado)
- [ ] Base de datos importada
- [ ] Sitio accesible en el navegador
- [ ] Caché limpiada
- [ ] Actualizaciones de BD ejecutadas (si es necesario)

## 🔐 Seguridad en Producción

### 1. Proteger settings.php y settings.local.php:

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

## 📚 Documentación Adicional

- `README-COOLIFY.md` - Guía completa de despliegue
- `SOLUCION_VENDOR_FALTANTE.md` - Troubleshooting detallado
- `nixpacks.toml` - Configuración de Nixpacks
- `settings.local.php` - Configuración de Drupal para Coolify

## 🆘 Soporte

Si tienes problemas:

1. Revisa los logs de Coolify
2. Verifica las variables de entorno
3. Lee `SOLUCION_VENDOR_FALTANTE.md` para troubleshooting
4. Si nada funciona, cambia a Dockerfile (más confiable)

---

**¡Todo está listo para desplegar!** 🎉

Haz commit, push, configura las variables de entorno y redeploy.
