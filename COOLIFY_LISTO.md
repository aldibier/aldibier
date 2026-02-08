# ✅ Coolify + Nixpacks - Configuración Lista

## Problema Resuelto

El problema era una variable conflictiva en `nixpacks.toml`:

```toml
NIXPACKS_PHP_ROOT_DIR = "/app/web"  # ❌ Esto causaba el problema
```

Esta variable hacía que Nixpacks buscara `composer.json` en `/web` en lugar de la raíz del proyecto.

## Solución Aplicada

✅ **Se eliminó la variable `NIXPACKS_PHP_ROOT_DIR`**

Ahora `nixpacks.toml` está correctamente configurado para:
- Detectar `composer.json` en la raíz
- Ejecutar `composer install` durante el build
- Servir la aplicación desde `/web`

## Archivos Modificados

- ✅ `nixpacks.toml` - Variable conflictiva eliminada
- ✅ `SOLUCION_COOLIFY_COMPOSER.md` - Documentación actualizada
- ✅ `README-COOLIFY.md` - Instrucciones simplificadas

## Próximos Pasos

### 1. Commit y Push

```bash
git add .
git commit -m "Fix: Remove NIXPACKS_PHP_ROOT_DIR to enable composer install"
git push
```

### 2. Desplegar en Coolify

- Ve a tu aplicación en Coolify
- Click en "Redeploy" (o espera el webhook automático si está configurado)

### 3. Verificar en los Logs

Deberías ver algo como:

```
[phases.install]
composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist
Loading composer repositories with package information
Installing dependencies from lock file
Package operations: 150 installs, 0 updates, 0 removals
  - Installing drupal/core (11.3.3): Extracting archive
  ...
Generating optimized autoload files
```

### 4. Configurar Variables de Entorno

En Coolify, configura estas variables:

**Base de Datos:**
```
DB_HOST=tu-servidor-db
DB_PORT=3306
DB_NAME=aldibier
DB_USER=drupal
DB_PASSWORD=tu-password-seguro
```

**Drupal:**
```
DRUPAL_HASH_SALT=genera-un-hash-aleatorio-aqui
```

Genera el hash salt con:
```bash
php -r 'echo bin2hex(random_bytes(32));'
```

### 5. Importar Base de Datos

Si tienes una base de datos existente:

```bash
# Opción 1: Desde tu máquina local
mysql -h tu-servidor-db -u drupal -p aldibier < aldibier.sql

# Opción 2: Usando Coolify
coolify exec app -- mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME < aldibier.sql
```

### 6. Verificar el Sitio

Visita tu dominio en Coolify y verifica que el sitio carga correctamente.

## Comandos Útiles

```bash
# Ver logs del despliegue
coolify logs app

# Conectarse al contenedor
coolify exec app -- bash

# Verificar que vendor existe
coolify exec app -- ls -la vendor

# Limpiar caché de Drupal
coolify exec app -- vendor/bin/drush cr

# Ver estado de Drupal
coolify exec app -- vendor/bin/drush status
```

## Estructura del Proyecto

```
/
├── composer.json          # ✅ En la raíz (Nixpacks lo encuentra)
├── composer.lock
├── nixpacks.toml         # ✅ Configuración corregida
├── web/                  # ✅ Drupal se sirve desde aquí
│   ├── index.php
│   ├── core/
│   ├── modules/
│   ├── themes/
│   └── sites/
│       └── default/
│           ├── files/    # ✅ Archivos subidos
│           └── settings.php
└── config/
    └── sync/             # ✅ Configuración exportada
```

## ¿Qué Hace Nixpacks Ahora?

1. **Setup**: Instala PHP 8.3, Composer, Node.js 20
2. **Install**: 
   - Ejecuta `composer install` en la raíz ✅
   - Crea directorio de archivos
   - Configura permisos
3. **Start**: Sirve la aplicación desde `/web` usando PHP built-in server

## Alternativa: Dockerfile

Si prefieres usar Docker en lugar de Nixpacks:

1. En Coolify, ve a Settings
2. Cambia Build Pack a "Dockerfile"
3. Coolify usará el `Dockerfile` incluido (que también funciona correctamente)

## Soporte

- 📖 [README-COOLIFY.md](README-COOLIFY.md) - Documentación completa
- 🔧 [SOLUCION_COOLIFY_COMPOSER.md](SOLUCION_COOLIFY_COMPOSER.md) - Detalles técnicos
- 🚀 [Documentación de Coolify](https://coolify.io/docs)
- 📦 [Nixpacks Documentation](https://nixpacks.com/docs)

---

**¡Todo listo para desplegar en Coolify!** 🎉
