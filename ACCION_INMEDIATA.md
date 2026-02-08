# ⚡ Acción Inmediata - Despliegue en Coolify

## ✅ Configuración Lista

Tu configuración en Coolify está correcta:
- **Base Directory**: `/` ✅
- **Publish Directory**: `/web` ✅
- **Build Pack**: Nixpacks ✅

Nixpacks usará **Nginx + PHP-FPM** automáticamente (como Symfony/Laravel).

## 🚀 Pasos para Desplegar (5 minutos)

### 1️⃣ Commit y Push

```bash
git add .
git commit -m "Configure Nixpacks with Nginx + PHP-FPM for Drupal"
git push
```

### 2️⃣ Configurar Variables de Entorno en Coolify

Ve a tu aplicación → **Environment Variables** y agrega:

```bash
# Base de datos (REQUERIDO)
DB_HOST=tu-servidor-mysql
DB_PORT=3306
DB_NAME=aldibier
DB_USER=drupal
DB_PASSWORD=tu-password-seguro

# Drupal (REQUERIDO)
DRUPAL_HASH_SALT=genera-con-comando-abajo
DRUPAL_ENV=production
```

**Generar Hash Salt:**
```bash
php -r 'echo bin2hex(random_bytes(32)) . "\n";'
```

### 3️⃣ Crear Base de Datos

**Opción A:** En Coolify, agrega un servicio MySQL/MariaDB

**Opción B:** Usa una base de datos externa y configura las variables manualmente

### 4️⃣ Redeploy

1. Click en **"Redeploy"**
2. Espera 3-5 minutos
3. Verifica en logs que veas: 
   - `composer install ... Installing dependencies`
   - `Starting Nginx...`

### 5️⃣ Importar Base de Datos

```bash
mysql -h tu-servidor-db -u drupal -p aldibier < aldibier.sql
```

### 6️⃣ Verificar

Visita tu dominio. ¡Debería funcionar! 🎉

Prueba también:
- `/core/install.php` - Debería cargar el instalador
- `/user/login` - Debería cargar el login

## 📋 Archivos Actualizados

- ✅ `nixpacks.toml` - Configurado para usar Nginx + PHP-FPM
- ✅ `nginx.template.conf` - Configuración de Nginx optimizada para Drupal
- ✅ `settings.local.php` - Configuración de Coolify (se carga automáticamente)

## 🎯 ¿Qué Hace Nixpacks Ahora?

1. **Setup**: Instala PHP 8.3, Composer, Node.js, Nginx, PHP-FPM
2. **Install**: Ejecuta `composer install` en `/` (raíz) ✅
3. **Start**: Inicia Nginx + PHP-FPM sirviendo desde `/app/web` ✅

**Ventajas sobre PHP built-in server:**
- ✅ Nginx maneja archivos estáticos eficientemente
- ✅ PHP-FPM maneja múltiples requests concurrentes
- ✅ Configuración lista para producción
- ✅ Mejor rendimiento y estabilidad

## 📚 Documentación Completa

Lee `DESPLIEGUE_COOLIFY_FINAL.md` para instrucciones detalladas y troubleshooting.

---

**TL;DR:** Commit → Push → Configura variables de entorno → Redeploy → Importa BD → ¡Listo!
