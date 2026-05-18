@echo off
color 0b
title BOT DESTRUCTOR DE WHATSAPP
mode con: cols=85 lines=28

echo =================================================================================
echo       🤖  B O T   D E S T R U C T O R   D E   W H A T S A P P  🤖
echo =================================================================================
echo.
echo Este bot preparara todo de forma automatica en esta PC:
echo 1. Descargara las herramientas oficiales de comunicacion (ADB) en segundo plano.
echo 2. Forzara la eliminacion de datos residuales y desinstalara WhatsApp de tu movil.
echo.
echo ---------------------------------------------------------------------------------
echo [Fase 1/3] Preparando Entorno de Limpieza...
echo.

:: Comprobar si ya existe ADB para no volver a descargar
if exist "%~dp0platform-tools\adb.exe" (
    echo [OK] Herramientas ya instaladas.
    goto adb_ready
)

echo [Info] Descargando componentes necesarios desde servidores oficiales...
curl -L -o "%temp%\tools.zip" "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" >nul 2>&1

if not exist "%temp%\tools.zip" (
    echo [ERROR] No se pudo descargar el componente. Revisa tu conexion a Internet.
    pause
    exit
)

echo [Info] Extrayendo componentes de limpieza...
powershell -Command "Expand-Archive -Path '%temp%\tools.zip' -DestinationPath '%~dp0' -Force" >nul 2>&1
del "%temp%\tools.zip" >nul 2>&1

if not exist "%~dp0platform-tools\adb.exe" (
    echo [ERROR] Error al extraer las herramientas.
    pause
    exit
)

echo [OK] Entorno preparado con exito.
:adb_ready
echo.
echo =================================================================================
echo [Fase 2/3] Conexion con el Dispositivo Movil
echo =================================================================================
echo.
echo Ajustes a realizar en tu Celular antes de continuar:
echo  1. Ve a Ajustes del Celular - Acerca del telefono.
echo  2. Presiona 7 veces seguidas sobre "Numero de compilacion" o "Version MIUI".
echo  3. Ve a Ajustes - Ajustes Adicionales (o Sistema) - Opciones de Desarrollador.
echo  4. Activa la opcion "Depuracion USB".
echo  5. Conecta el celular a la PC usando un cable USB.
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
echo [Fase 3/3] Purga Absoluta del Bloqueo
echo =================================================================================
echo.
echo [1/2] Forzando destruccion de cache y almacenamiento congelado...
"%~dp0platform-tools\adb.exe" shell pm clear com.whatsapp
echo.
echo [2/2] Desinstalando aplicacion y borrando archivos fantasmas del sistema...
"%~dp0platform-tools\adb.exe" shell pm uninstall --user 0 com.whatsapp
"%~dp0platform-tools\adb.exe" uninstall com.whatsapp >nul 2>&1
echo.
echo =================================================================================
echo ✅ ¡PROCESO DE PURGA COMPLETADO CON EXITO!
echo =================================================================================
echo Ya puedes desconectar tu celular de la PC.
echo.
echo Recomendaciones finales antes de reinstalar:
echo  - Cambia tu IP (usa datos moviles o apaga tu router 5 minutos).
echo  - Borra tu ID de Anuncios (Ajustes del movil - Google - Anuncios).
echo  - Reinicia tu celular.
echo.
pause
