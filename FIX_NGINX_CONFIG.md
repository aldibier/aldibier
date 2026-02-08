# 🔧 Fix: Nginx Configuration Error

## Problema

El contenedor se reiniciaba constantemente con el error:

```
nginx: [emerg] "server" directive is not allowed here in /nginx.conf:1
```

## Causa

El archivo `nginx.template.conf` solo tenía el bloque `server {}`, pero Nginx necesita la estructura completa con `worker_processes`, `events {}`, y `http {}`.

## Solución

Actualizado `nginx.template.conf` con la estructura completa de configuración de Nginx que incluye:

- `worker_processes` y `events {}`
- Bloque `http {}` que envuelve el `server {}`
- Configuración de logs a stdout
- Soporte para variables de Nixpacks (`$if` statements)
- Configuración completa de Drupal

## Pasos para Aplicar

```bash
# 1. Commit y push
git add nginx.template.conf
git commit -m "Fix: Add complete Nginx configuration structure"
git push

# 2. Redeploy en Coolify
# Ve a tu aplicación y click en "Redeploy"

# 3. Verificar logs
# Deberías ver:
# - "Server starting on port 8080" (solo una vez)
# - Sin errores de Nginx
```

## Verificación

Después del redeploy, verifica:

1. **Logs del contenedor** - No debe haber errores de Nginx
2. **Visita tu dominio** - El sitio debe cargar
3. **Prueba rutas** - `/user/login`, `/core/install.php`, etc.

---

**Estado:** Listo para redeploy
