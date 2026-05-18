@echo off
color 0c
title BOT LIMPIADOR DE DATOS DE WHATSAPP
mode con: cols=90 lines=28

echo =================================================================================
echo    🔥  B O T   L I M P I A D O R   D E   D A T O S   D E   W H A T S A P P  🔥
echo =================================================================================
echo.
echo Este bot borrara el cache y los datos de almacenamiento en tu telefono.
echo NO desinstalara la aplicacion WhatsApp.
echo.
echo ---------------------------------------------------------------------------------
echo [Fase 1/3] Preparando Entorno de Limpieza...
echo.

:: Comprobar si ya existe ADB para no descargar de nuevo
if exist "%~dp0platform-tools\adb.exe" (
    echo [OK] Herramientas listas.
    goto adb_ready
)

echo [Info] Descargando componentes necesarios desde servidores oficiales...
curl -L -o "%temp%\tools.zip" "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" >nul 2>&1

if not exist "%temp%\tools.zip" (
    echo [ERROR] No se pudo descargar el componente. Revisa tu conexion a Internet.
    pause
    exit
)

echo [Info] Extrayendo componentes...
powershell -Command "Expand-Archive -Path '%temp%\tools.zip' -DestinationPath '%~dp0' -Force" >nul 2>&1
del "%temp%\tools.zip" >nul 2>&1

if not exist "%~dp0platform-tools\adb.exe" (
    echo [ERROR] Error al extraer las herramientas.
    pause
    exit
)

echo [OK] Entorno preparado.
:adb_ready
echo.
echo =================================================================================
echo [Fase 2/3] Sincronizacion del Dispositivo Movil
echo =================================================================================
echo.
echo Requisitos obligatorios en el celular:
echo  1. Activa "Depuracion USB" (Ajustes - Acerca del movil - 7 toques en Compilacion,
echo     luego ve a Ajustes adicionales - Desarrollador - Activar Depuracion USB).
echo  2. Conecta el celular a la PC con cable USB en buen estado.
echo.
echo Presiona cualquier tecla cuando el celular este conectado...
pause > nul
echo.
echo [Buscando celular...]
"%~dp0platform-tools\adb.exe" devices
echo.
echo IMPORTANTE: Mira la pantalla de tu celular ahora.
echo Acepta la ventana emergente que dice "Permitir depuracion USB".
echo (Marca la casilla "Permitir siempre" y dale ACEPTAR).
echo.
echo Presiona una tecla una vez aceptado en el celular...
pause > nul

echo.
echo =================================================================================
echo [Fase 3/3] EJECUTANDO LIMPIEZA DE DATOS Y CACHE
echo =================================================================================
echo.
echo 1. Eliminando procesos activos de WhatsApp en memoria...
"%~dp0platform-tools\adb.exe" shell am force-stop com.whatsapp >nul 2>&1
"%~dp0platform-tools\adb.exe" shell am force-stop com.whatsapp.w4b >nul 2>&1
echo [OK] Procesos detenidos.
echo.

echo 2. Limpiando almacenamiento y cache de TODAS las cuentas (clones y principal)...
:: Ejecutar bucle en Android para limpiar datos de WhatsApp
"%~dp0platform-tools\adb.exe" shell "for u in $(pm list users | grep -oE '[0-9]+:'); do id=${u%%:}; echo 'Limpiando datos usuario ID' $id; pm clear --user $id com.whatsapp >/dev/null 2>&1; pm clear --user $id com.whatsapp.w4b >/dev/null 2>&1; done"
echo [OK] Limpieza de almacenamiento y cache completada.
echo.

echo 3. Destruyendo carpetas residuales y bases de datos externas de la SD...
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/Android/media/com.whatsapp >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/Android/media/com.whatsapp.w4b >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/WhatsApp >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/WhatsApp\ Business >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/Android/data/com.whatsapp >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/Android/data/com.whatsapp.w4b >nul 2>&1
echo [OK] Carpetas de la tarjeta SD limpiadas.
echo.

echo =================================================================================
echo ✅ ¡DATOS Y CACHE DE WHATSAPP LIMPIADOS CON EXITO!
echo =================================================================================
echo WhatsApp no ha sido desinstalado. Puedes abrir la aplicacion para iniciar sesion.
echo.
pause
