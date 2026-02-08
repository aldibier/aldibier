# Solución: Composer Install no se ejecuta en Coolify

## Problema Identificado y Resuelto ✅

El problema era que `nixpacks.toml` contenía una variable conflictiva:

```toml
NIXPACKS_PHP_ROOT_DIR = "/app/web"
```

Esto hacía que Nixpacks detectara `/web` como directorio base, pero `composer.json` está en la raíz del proyecto, por lo que `composer install` no se ejecutaba.

## Solución Aplicada

**Se eliminó la variable `NIXPACKS_PHP_ROOT_DIR` de `nixpacks.toml`**

Ahora Nixpacks:
1. Detecta automáticamente que el proyecto es PHP
2. Encuentra `composer.json` en la raíz
3. Ejecuta `composer install` correctamente
4. Sirve la aplicación desde `/web` usando el comando start

## Configuración Final

El archivo `nixpacks.toml` ahora contiene:

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

[start]
cmd = "php -S 0.0.0.0:$PORT -t web"

[variables]
COMPOSER_MEMORY_LIMIT = "-1"
COMPOSER_ALLOW_SUPERUSER = "1"
```

## Verificación

Después de aplicar la solución, verifica en los logs que veas:

```
[phases.install]
composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist
Loading composer repositories with package information
Installing dependencies from lock file
...
```

## Archivos Actualizados

- `nixpacks.toml` - Variable conflictiva eliminada
- `.coolifyignore` - Archivos a ignorar en el build
- `README-COOLIFY.md` - Documentación actualizada

## Próximos Pasos

1. **Haz commit y push de los cambios**:
   ```bash
   git add nixpacks.toml SOLUCION_COOLIFY_COMPOSER.md
   git commit -m "Fix: Remove NIXPACKS_PHP_ROOT_DIR to allow composer install"
   git push
   ```

2. **Redeploy en Coolify**:
   - Ve a tu aplicación en Coolify
   - Click en "Redeploy" o espera el webhook automático

3. **Verifica los logs** para confirmar que `composer install` se ejecuta:
   ```
   [phases.install]
   composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist
   Loading composer repositories with package information
   Installing dependencies from lock file
   ...
   ```

4. **Configura las variables de entorno** (si aún no lo has hecho):
   - `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
   - `DRUPAL_HASH_SALT`

5. **Importa la base de datos** (si es necesario)

6. **Verifica que el sitio carga correctamente**

## Comandos Útiles

```bash
# Ver logs del despliegue
coolify logs app

# Conectarse al contenedor
coolify exec app -- bash

# Verificar que vendor existe
coolify exec app -- ls -la vendor

# Verificar versión de Drupal
coolify exec app -- vendor/bin/drush status
```
