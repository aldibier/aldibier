# Despliegue en Coolify con Nixpacks

Este proyecto está configurado para desplegarse en Coolify usando Nixpacks o Docker.

## 🚀 Despliegue Rápido

### Opción 1: Usando Nixpacks (Recomendado)

Coolify detectará automáticamente `nixpacks.toml` y usará Nixpacks para el build.

1. **Conecta tu repositorio en Coolify**
   - Ve a tu instancia de Coolify
   - Crea un nuevo proyecto
   - Conecta este repositorio Git

2. **Coolify detectará automáticamente**:
   - PHP 8.3
   - Composer (se ejecutará en la raíz)
   - Node.js 20
   - Configuración de Drupal

3. **Configura las variables de entorno** (ver sección abajo)

4. **Despliega**
   - Coolify construirá y desplegará automáticamente

### Opción 2: Usando Dockerfile

Si Nixpacks no funciona, Coolify usará el `Dockerfile` incluido.

## 🔧 Variables de Entorno Requeridas

Configura estas variables en Coolify:

### Base de Datos (Requeridas)
```bash
DB_HOST=your-db-host
DB_PORT=3306
DB_NAME=aldibier
DB_USER=drupal
DB_PASSWORD=your-secure-password
```

### Drupal (Requeridas)
```bash
DRUPAL_HASH_SALT=generate-a-random-hash-salt-here
```

Genera el hash salt con:
```bash
php -r 'echo bin2hex(random_bytes(32));'
```

### Opcionales
```bash
# Directorio de configuración
DRUPAL_CONFIG_SYNC_DIRECTORY=../config/sync

# Límites PHP
PHP_MEMORY_LIMIT=256M
PHP_MAX_EXECUTION_TIME=300

# Puerto (Coolify lo asigna automáticamente)
PORT=8080
```

## 📦 Base de Datos

### Opción 1: Base de Datos en Coolify

1. En Coolify, crea un servicio de base de datos (MySQL/MariaDB)
2. Conecta el servicio a tu aplicación
3. Coolify configurará automáticamente las variables de entorno

### Opción 2: Base de Datos Externa

Configura manualmente las variables `DB_*` con los datos de tu servidor externo.

### Importar Base de Datos Existente

```bash
# Desde tu máquina local
mysql -h your-db-host -u drupal -p aldibier < aldibier.sql

# O usando Coolify CLI
coolify exec app -- mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME < aldibier.sql
```

## 🔐 Configuración de settings.php

Crea `web/sites/default/settings.local.php` o modifica `settings.php`:

```php
<?php
// Configuración de base de datos desde variables de entorno
$databases['default']['default'] = [
  'database' => getenv('DB_NAME'),
  'username' => getenv('DB_USER'),
  'password' => getenv('DB_PASSWORD'),
  'host' => getenv('DB_HOST'),
  'port' => getenv('DB_PORT') ?: '3306',
  'driver' => 'mysql',
  'prefix' => '',
  'collation' => 'utf8mb4_general_ci',
];

// Hash salt
$settings['hash_salt'] = getenv('DRUPAL_HASH_SALT');

// Directorio de configuración
$settings['config_sync_directory'] = getenv('DRUPAL_CONFIG_SYNC_DIRECTORY') ?: '../config/sync';

// Trusted host patterns (ajusta según tu dominio)
$settings['trusted_host_patterns'] = [
  '^aldibier\.com$',
  '^.*\.aldibier\.com$',
];

// Configuración de archivos
$settings['file_private_path'] = '/var/www/html/private';
$settings['file_temp_path'] = '/tmp';

// Reverse proxy configuration (para Coolify)
$settings['reverse_proxy'] = TRUE;
$settings['reverse_proxy_addresses'] = [$_SERVER['REMOTE_ADDR']];
```

## 📁 Volúmenes Persistentes

Coolify creará automáticamente volúmenes para:

- `/var/www/html/web/sites/default/files` - Archivos subidos
- `/var/www/html/private` - Archivos privados

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
coolify exec app -- vendor/bin/drush cron
```

### Limpiar Caché

```bash
coolify exec app -- vendor/bin/drush cr
```

### Backup de Base de Datos

```bash
coolify exec app -- vendor/bin/drush sql:dump --gzip --result-file=/tmp/backup.sql
```

## 🐛 Troubleshooting

### Error: "Cannot write to files directory"

```bash
# Conectarse al contenedor
coolify exec app -- bash

# Arreglar permisos
chmod -R 775 web/sites/default/files
chown -R www-data:www-data web/sites/default/files
```

### Error: "Database connection failed"

1. Verifica que las variables de entorno estén configuradas correctamente
2. Verifica que el servicio de base de datos esté corriendo
3. Verifica la conectividad de red entre servicios

### Ver Logs

```bash
# Logs de la aplicación
coolify logs app

# Logs de Nginx
coolify exec app -- tail -f /var/log/nginx/error.log

# Logs de PHP
coolify exec app -- tail -f /var/log/php_errors.log
```

### Rebuild Completo

Si algo sale mal:

1. En Coolify, ve a tu aplicación
2. Click en "Rebuild"
3. Espera a que termine el build
4. Verifica los logs

## 🔒 Seguridad en Producción

### 1. Configurar HTTPS

Coolify maneja automáticamente SSL con Let's Encrypt. Solo asegúrate de:
- Configurar tu dominio correctamente
- Habilitar "Force HTTPS" en Coolify

### 2. Proteger settings.php

```bash
coolify exec app -- chmod 444 web/sites/default/settings.php
```

### 3. Deshabilitar módulos de desarrollo

```bash
coolify exec app -- vendor/bin/drush pm:uninstall devel webprofiler -y
```

### 4. Configurar trusted_host_patterns

Edita `settings.php` y configura correctamente los patrones de host confiables.

## 📊 Monitoreo

### Health Check

Coolify ejecuta automáticamente health checks en:
- `http://localhost:8080/`

### Métricas

Coolify proporciona métricas de:
- CPU
- Memoria
- Disco
- Red

## 🚀 CI/CD

### Despliegue Automático

Coolify puede configurarse para desplegar automáticamente cuando:
- Haces push a la rama principal
- Creas un nuevo tag
- Abres un pull request

Configura webhooks en tu repositorio Git para activar despliegues automáticos.

## 📝 Archivos de Configuración

- `nixpacks.toml` - Configuración de Nixpacks
- `Dockerfile` - Dockerfile alternativo
- `.coolify.yml` - Configuración de servicios
- `docker/` - Archivos de configuración de Docker
  - `php.ini` - Configuración PHP
  - `nginx.conf` - Configuración Nginx
  - `default.conf` - Virtual host de Nginx
  - `supervisord.conf` - Supervisor para múltiples procesos

## 🆘 Soporte

- [Documentación de Coolify](https://coolify.io/docs)
- [Nixpacks Documentation](https://nixpacks.com/docs)
- [Drupal Documentation](https://www.drupal.org/docs)

## 📋 Checklist de Despliegue

- [ ] Repositorio conectado en Coolify
- [ ] Variables de entorno configuradas
- [ ] Base de datos creada y conectada
- [ ] Base de datos importada
- [ ] settings.php configurado
- [ ] Dominio configurado
- [ ] SSL habilitado
- [ ] Health checks pasando
- [ ] Sitio accesible
- [ ] Cron configurado (opcional)
- [ ] Backups configurados (opcional)

## 🎉 ¡Listo!

Tu sitio Drupal 11 debería estar corriendo en Coolify. Visita tu dominio para verificar.
