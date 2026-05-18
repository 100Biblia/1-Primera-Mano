@echo off
color 0c
title BOT DESTRUCTOR DE RASTROS (NIVEL MAXIMO)
mode con: cols=90 lines=32

echo =================================================================================
echo    🔥  B O T   R E S E T E O   D E   H U E L L A S   (ANTI-BAN)  🔥
echo =================================================================================
echo.
echo Para evitar la "Alarma de Seguridad", este bot tiene que destruir el rastro
echo criptografico de WhatsApp y resetear el identificador de Google de tu movil.
echo.
echo ---------------------------------------------------------------------------------
echo [Fase 1/3] Preparando Entorno...
echo.

if exist "%~dp0platform-tools\adb.exe" goto adb_ready

curl -L -o "%temp%\tools.zip" "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" >nul 2>&1
powershell -Command "Expand-Archive -Path '%temp%\tools.zip' -DestinationPath '%~dp0' -Force" >nul 2>&1
del "%temp%\tools.zip" >nul 2>&1

:adb_ready
echo [Buscando celular...]
"%~dp0platform-tools\adb.exe" devices
echo.
echo IMPORTANTE: Acepta la depuracion USB en la pantalla del celular.
pause > nul

echo.
echo =================================================================================
echo [Fase 2/3] ELIMINACION DE RASTROS Y RESETEO DE GOOGLE
echo =================================================================================
echo.
echo 1. Borrando huella criptografica (Desinstalando WhatsApp obligatoriamente)...
"%~dp0platform-tools\adb.exe" shell pm uninstall --user 0 com.whatsapp >nul 2>&1
"%~dp0platform-tools\adb.exe" uninstall com.whatsapp >nul 2>&1

echo 2. Reseteando huella digital de Google Play Services (Anti-Ban)...
"%~dp0platform-tools\adb.exe" shell pm clear com.google.android.gms >nul 2>&1
"%~dp0platform-tools\adb.exe" shell pm clear com.android.vending >nul 2>&1

echo 3. Limpiando Google Services Framework (ID de Dispositivo)...
"%~dp0platform-tools\adb.exe" shell pm clear com.google.android.gsf >nul 2>&1

echo 4. Borrando archivos fisicos basura de la memoria...
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/Android/media/com.whatsapp >nul 2>&1
"%~dp0platform-tools\adb.exe" shell rm -rf /sdcard/WhatsApp >nul 2>&1

echo.
echo =================================================================================
echo [Fase 3/3] REINICIANDO EL TELEFONO
echo =================================================================================
echo.
echo El bot va a reiniciar tu telefono para aplicar el nuevo identificador limpio.
"%~dp0platform-tools\adb.exe" reboot
echo.
echo ✅ LISTO. Tu telefono se esta reiniciando ahora mismo.
echo.
echo Cuando el telefono encienda:
echo 1. Entra a la Play Store y descarga el WhatsApp ORIGINAL.
echo 2. Apaga el Wi-Fi y usa DATOS MOVILES.
echo 3. Inicia sesion.
echo.
pause
