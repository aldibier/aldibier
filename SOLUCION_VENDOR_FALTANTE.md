# 🔧 Solución: vendor/ faltante en Coolify

## Problema Actual

El error indica que el directorio `vendor/` no existe:

```
Warning: require(/app/../vendor/autoload.php): Failed to open stream: No such file or directory
```

Esto significa que **`composer install` NO se está ejecutando** durante el build en Coolify.

## Causa Raíz

Coolify/Nixpacks está detectando `/web` como directorio base en lugar de la raíz del proyecto, probablemente debido a:

1. Configuración de "Base Directory" en Coolify apuntando a `/web`
2. Nixpacks detectando automáticamente `/web` por la presencia de `index.php`

## ✅ Solución Recomendada: Usar Dockerfile

El método más confiable es usar el `Dockerfile` en lugar de Nixpacks.

### Pasos:

#### 1. Commit y Push de los cambios actuales

```bash
git add .
git commit -m "Add Dockerfile with dynamic port support"
git push
```

#### 2. Configurar Coolify para usar Dockerfile

**Opción A: Cambiar Build Pack (Recomendado)**

1. Ve a tu aplicación en Coolify
2. Click en **"Settings"** o **"Configuration"**
3. Busca **"Build Pack"** o **"Builder"**
4. Selecciona **"Dockerfile"** en lugar de "Nixpacks"
5. Guarda los cambios

**Opción B: Configurar Base Directory**

Si prefieres seguir usando Nixpacks:

1. Ve a tu aplicación en Coolify
2. Click en **"Settings"** o **"Configuration"**
3. Busca **"Base Directory"** o **"Build Directory"**
4. **Déjalo VACÍO** o escribe **`/`** (raíz del proyecto)
5. **NO uses** `/web`
6. Guarda los cambios

#### 3. Redeploy

1. En Coolify, click en **"Redeploy"** o **"Rebuild"**
2. Espera a que termine el build (puede tomar 5-10 minutos)

#### 4. Verificar en los Logs

Deberías ver en los logs:

```
Step 10/15 : RUN composer install --no-dev --optimize-autoloader
Loading composer repositories with package information
Installing dependencies from lock file
Package operations: 150 installs, 0 updates, 0 removals
  - Installing drupal/core (11.3.3): Extracting archive
  ...
Generating optimized autoload files
```

## 🔍 Verificación Post-Despliegue

### 1. Verificar que vendor existe

```bash
coolify exec app -- ls -la /var/www/html/vendor
```

Deberías ver directorios como `drupal/`, `symfony/`, `composer/`, etc.

### 2. Verificar que Drupal funciona

```bash
coolify exec app -- /var/www/html/vendor/bin/drush status
```

Debería mostrar información del sitio Drupal.

### 3. Acceder al sitio

Visita tu dominio en el navegador. Deberías ver tu sitio Drupal.

## 📋 Variables de Entorno Requeridas

Asegúrate de tener configuradas estas variables en Coolify:

```bash
# Base de datos
DB_HOST=tu-servidor-db
DB_PORT=3306
DB_NAME=aldibier
DB_USER=drupal
DB_PASSWORD=tu-password-seguro

# Drupal
DRUPAL_HASH_SALT=genera-un-hash-aleatorio-aqui

# Opcional
DRUPAL_CONFIG_SYNC_DIRECTORY=../config/sync
PHP_MEMORY_LIMIT=256M
PHP_MAX_EXECUTION_TIME=300
```

Genera el hash salt:
```bash
php -r 'echo bin2hex(random_bytes(32));'
```

## 🗄️ Importar Base de Datos

Si aún no has importado la base de datos:

```bash
# Opción 1: Desde tu máquina local
mysql -h tu-servidor-db -u drupal -p aldibier < aldibier.sql

# Opción 2: Copiar al contenedor e importar
coolify cp aldibier.sql app:/tmp/
coolify exec app -- mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME < /tmp/aldibier.sql
```

## 🐛 Troubleshooting

### Si el error persiste después de usar Dockerfile

1. **Verifica que Coolify esté usando el Dockerfile:**
   - En los logs de build, deberías ver `Step 1/15 : FROM php:8.3-fpm-alpine`
   - Si ves `nixpacks`, entonces Coolify no está usando el Dockerfile

2. **Verifica el directorio de trabajo:**
   ```bash
   coolify exec app -- pwd
   # Debería mostrar: /var/www/html
   ```

3. **Verifica que composer.json existe:**
   ```bash
   coolify exec app -- ls -la /var/www/html/composer.json
   ```

4. **Intenta ejecutar composer manualmente:**
   ```bash
   coolify exec app -- composer install --working-dir=/var/www/html
   ```

### Si Nixpacks sigue sin funcionar

El problema es que Nixpacks está detectando el proyecto incorrectamente. Opciones:

1. **Usa Dockerfile** (recomendado)
2. **Contacta soporte de Coolify** para verificar la configuración de Base Directory
3. **Verifica en los logs de Coolify** qué directorio está usando para el build

## 📊 Comparación: Dockerfile vs Nixpacks

| Característica | Dockerfile | Nixpacks |
|----------------|-----------|----------|
| Control total | ✅ Sí | ❌ Limitado |
| Configuración explícita | ✅ Sí | ⚠️ Auto-detecta |
| Composer install garantizado | ✅ Sí | ⚠️ Depende de detección |
| Tiempo de build | ~5-10 min | ~3-5 min |
| Recomendado para Drupal | ✅ Sí | ⚠️ Puede fallar |

## 📝 Archivos Actualizados

- ✅ `Dockerfile` - Configuración completa con soporte dinámico de puerto
- ✅ `docker/entrypoint.sh` - Script que configura el puerto dinámicamente
- ✅ `nixpacks.toml` - Comandos de debug agregados (por si quieres seguir intentando)

## 🎯 Próximos Pasos

1. ✅ Commit y push de los cambios
2. ✅ Cambiar a Dockerfile en Coolify
3. ✅ Redeploy
4. ✅ Verificar logs
5. ✅ Configurar variables de entorno
6. ✅ Importar base de datos
7. ✅ Acceder al sitio

## 🆘 Si Nada Funciona

Como último recurso, puedes:

1. **Crear un nuevo proyecto en Coolify**
2. **Asegurarte de NO configurar Base Directory** (dejarlo vacío)
3. **Seleccionar Dockerfile como Build Pack desde el inicio**
4. **Conectar el repositorio**
5. **Desplegar**

---

**Recomendación:** Usa el Dockerfile. Es más confiable para proyectos Drupal con estructura composer en la raíz.
