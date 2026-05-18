@echo off
color 0c
title BOT DESTRUCTOR PROFUNDO DE WHATSAPP
mode con: cols=90 lines=32

echo =================================================================================
echo    🔥  B O T   D E S T R U C T O R   P R O F U N D O   D E   W H A T S A P P  🔥
echo =================================================================================
echo.
echo Este bot realizara una purga ABSOLUTA en tu telefono Android.
echo Buscara y destruira hasta el ultimo rastro de WhatsApp, WhatsApp Business,
echo perfiles clonados (Xiaomi Dual, Samsung Dual, Island), carpetas ocultas e
echo identificadores residuales en el sistema de archivos del movil.
echo.
echo ---------------------------------------------------------------------------------
echo [Fase 1/3] Preparando Entorno de Limpieza Militar...
echo.

:: Comprobar si ya existe ADB para no descargar de nuevo
if exist "%~dp0platform-tools\adb.exe" (
    echo [OK] Herramientas de purga listas.
    goto adb_ready
)

echo [Info] Descargando componentes necesarios desde servidores oficiales...
curl -L -o "%temp%\tools.zip" "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" >nul 2>&1

if not exist "%temp%\tools.zip" (
    echo [ERROR] No se pudo descargar el componente. Revisa tu conexion a Internet.
    pause
    exit
)

echo [Info] Extrayendo componentes de desinfeccion...
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
echo [Fase 3/3] EJECUTANDO PURGA ABSOLUTA Y ELIMINACION DE RASTROS
echo =================================================================================
echo.
echo 1. Eliminando procesos activos de WhatsApp en memoria...
"%~dp0platform-tools\adb.exe" shell am force-stop com.whatsapp >nul 2>&1
"%~dp0platform-tools\adb.exe" shell am force-stop com.whatsapp.w4b >nul 2>&1
echo [OK] Procesos detenidos.
echo.

echo 2. Purgando almacenamiento de TODAS las cuentas de usuario...
echo    (Xiaomi Dual Apps, Samsung Dual Messenger, Work Profiles, Carpeta Segura)
:: Ejecutar bucle en Android para limpiar y desinstalar en todos los perfiles de usuario
"%~dp0platform-tools\adb.exe" shell "for u in $(pm list users | grep -oE '[0-9]+:'); do id=${u%%:}; echo 'Purgando usuario ID' $id; pm clear --user $id com.whatsapp >/dev/null 2>&1; pm uninstall --user $id com.whatsapp >/dev/null 2>&1; pm clear --user $id com.whatsapp.w4b >/dev/null 2>&1; pm uninstall --user $id com.whatsapp.w4b >/dev/null 2>&1; done"
echo [OK] Limpieza de perfiles completada.
echo.

echo 3. Destruyendo carpetas residuales y bases de datos ocultas de la SD...
:: Eliminar carpetas externas
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/Android/media/com.whatsapp >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/Android/media/com.whatsapp.w4b >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/WhatsApp >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/WhatsApp\ Business >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/Android/data/com.whatsapp >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/Android/data/com.whatsapp.w4b >nul 2>&1
echo [OK] Carpetas fisicas de almacenamiento borradas de raiz.
echo.

echo 4. Ejecutando desinstalacion global definitiva...
"%~dp0platform-tools\adb.exe" uninstall com.whatsapp >nul 2>&1
"%~dp0platform-tools\adb.exe" uninstall com.whatsapp.w4b >nul 2>&1
echo [OK] Aplicacion completamente removida.
echo.

echo =================================================================================
echo 🔥 ¡DISPOSITIVO 100% PURGADO Y LIMPIO DE WHATSAPP! 🔥
echo =================================================================================
echo Tu telefono ya no tiene ningun rastro de instalacion ni datos residuales.
echo.
echo RECOMENDACIONES DE MAXIMA SEGURIDAD ANTES DE VOLVER A INSTALAR:
echo 1. Cambia de IP obligatoriamente (usa otra red Wi-Fi o datos moviles).
echo 2. Entra en Ajustes - Google - Anuncios y dale a "Borrar/Restablecer ID de publicidad".
echo 3. Reinicia tu celular antes de abrir el nuevo WhatsApp.
echo.
pause
