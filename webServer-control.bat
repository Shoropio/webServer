@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Directorios base
set BASEDIR=C:\webServer\bin
set LOGSDIR=C:\webServer\logs
set LOGFILE=%LOGSDIR%\webServer-control.log

:: Función para agregar timestamp
set "timestamp=[%date% %time%]"

:: Crear carpeta de logs si no existe
:: if not exist "%BASEDIR%\logs" mkdir "%BASEDIR%\logs"

:MENU
cls
echo ========================================================================
echo                       Panel de control - webServer
echo ========================================================================

echo [1] Iniciar Apache                    [A] Iniciar TODO
echo [2] Detener Apache                    [B] Detener TODO
echo [3] Iniciar Nginx                     [R] Reiniciar TODO
echo [4] Detener Nginx                     [C] Reiniciar Apache
echo [5] Iniciar MariaDB                   [D] Reiniciar Nginx
echo [6] Detener MariaDB                   [E] Reiniciar MariaDB
echo [7] Ejecutar PHP CLI                  [U] Desinstalar Nginx
echo [8] Ver estado de servicios           [X] Desinstalar Apache
echo [9] Abrir https://webserver.local     [M] Desinstalar MySQL
echo [10] Abrir phpMyAdmin                 [Y] Desinstalar MariaDB
echo [11] Abrir consola MariaDB            [Z] Desinstalar PHP
echo [0] Salir                             [W] Borrar instalacion completa
echo                                       [V] Verificar sintaxis de Apache
echo                                       [G] Verificar sintaxis de Nginx
echo                                       [L] Ver log

echo ========================================================================
set /p op=Selecciona una opcion:

:: Iniciar Apache
if /i "%op%"=="1" (
    call :startApache
    pause
    goto MENU
)

:: Detener Apache
if /i "%op%"=="2" (
    echo Deteniendo Apache...
    taskkill /F /IM httpd.exe >> "%LOGFILE%" 2>&1
    echo Apache detenido. >> "%LOGFILE%"
    pause
    goto MENU
)

:: Iniciar Nginx
if /i "%op%"=="3" (
    call :startNginx
    pause
    goto MENU
)

:: Detener Nginx
if /i "%op%"=="4" (
    echo Deteniendo Nginx y PHP FastCGI...
    taskkill /F /IM nginx.exe >> "%LOGFILE%" 2>&1
    taskkill /F /IM php-cgi.exe >> "%LOGFILE%" 2>&1
    echo Nginx y PHP detenidos. >> "%LOGFILE%"
    pause
    goto MENU
)

:: Iniciar MariaDB
if /i "%op%"=="5" (
    call :startMariaDB
    pause
    goto MENU
)

:: Detener MariaDB
if /i "%op%"=="6" (
    echo Deteniendo MariaDB...
    taskkill /F /IM mariadbd.exe >> "%LOGFILE%" 2>&1
    echo MariaDB detenida. >> "%LOGFILE%"
    pause
    goto MENU
)

:: Ejecutar PHP CLI
if /i "%op%"=="7" (
    echo Ejecutando PHP CLI...
    "%BASEDIR%\php\8.3.20\php.exe" -v >> "%LOGFILE%" 2>&1
    echo PHP ejecutado. >> "%LOGFILE%"
    pause
    goto MENU
)

:: Ver estado
if /i "%op%"=="8" (
    echo Estado de servicios:
    echo -------------------------
    tasklist | findstr /I "httpd.exe nginx.exe mysqld.exe mariadbd.exe php-cgi.exe MariaDB"
    echo -------------------------
    echo Log: %LOGFILE%
    pause
    goto MENU
)

:: Abrir navegador
if /i "%op%"=="9" (
    start https://webserver.local
    goto MENU
)

:: Abrir phpMyAdmin
if /i "%op%"=="10" (
    start https://phpmyadmin.local
    goto MENU
)

:: Iniciar TODO
if /i "%op%"=="A" (
    echo Iniciando todos los servicios...
    call :startApache
    call :startNginx
    call :startMariaDB
    echo Todos los servicios iniciados. >> "%LOGFILE%"
    pause
    goto MENU
)

:: Detener TODO
if /i "%op%"=="B" (
    echo Deteniendo todos los servicios...
    taskkill /F /IM httpd.exe >> "%LOGFILE%" 2>&1
    taskkill /F /IM nginx.exe >> "%LOGFILE%" 2>&1
    taskkill /F /IM php-cgi.exe >> "%LOGFILE%" 2>&1
    taskkill /F /IM mysqld.exe >> "%LOGFILE%" 2>&1
    taskkill /F /IM mariadbd.exe >> "%LOGFILE%" 2>&1
    echo Todos los servicios detenidos. >> "%LOGFILE%"
    echo Esperando que todos los servicios se detengan correctamente...

    :: Esperar 5 segundos para asegurar que los procesos se cierren correctamente.
    timeout /t 5 /nobreak >nul

    echo Todos los servicios detenidos correctamente. >> "%LOGFILE%"
    pause
    goto MENU
)

:: Reiniciar TODO
if /i "%op%"=="R" (
    call :restartAllServices
    pause
    goto MENU
)

:: Reiniciar Apache
if /i "%op%"=="C" (
    call :restartApache
    pause
    goto MENU
)

:: Reiniciar Nginx
if /i "%op%"=="D" (
    call :restartNginx
    pause
    goto MENU
)

:: Reiniciar MariaDB
if /i "%op%"=="E" (
    call :restartMariaDB
    pause
    goto MENU
)

:: Desinstalar Nginx
if /i "%op%"=="U" (
    call :uninstallNginx
    pause
    goto MENU
)

if /i "%op%"=="X" (
    call :uninstallApache
    pause
    goto MENU
)

:: Abrir consola MariaDB
if /i "%op%"=="11" (
    call :mariadbConsole
    pause
    goto MENU
)

:: Desinstalar MySQL
if /i "%op%"=="M" (
    call :uninstallMySQL
    pause
    goto MENU
)

if /i "%op%"=="Y" (
    call :uninstallMariaDB
    pause
    goto MENU
)

if /i "%op%"=="Z" (
    call :uninstallPHP
    pause
    goto MENU
)

if /i "%op%"=="W" (
    call :uninstallAllComponents
    pause
    goto MENU
)

:: Verificar sintaxis Apache
if /i "%op%"=="V" (
    echo Verificando sintaxis de Apache...
    "%BASEDIR%\apache\2.4.63\bin\httpd.exe" -t >> "%LOGFILE%" 2>&1
    "%BASEDIR%\apache\2.4.63\bin\httpd.exe" -t
    pause
    goto MENU
)

:: Verificar sintaxis Nginx
if /i "%op%"=="G" (
    echo Verificando sintaxis de Nginx...
    "%BASEDIR%\nginx\1.26.3\nginx.exe" -t >> "%LOGFILE%" 2>&1
    "%BASEDIR%\nginx\1.26.3\nginx.exe" -t
    pause
    goto MENU
)

:: Ver log
if /i "%op%"=="L" (
    start notepad "%LOGFILE%"
    goto MENU
)

:: Salir
if "%op%"=="0" (
    echo Cerrando el panel...
    exit
)

goto MENU

:: Funciones internas
:startApache
    tasklist | find /I "httpd.exe" >nul
    if not errorlevel 1 (
        echo !timestamp! Apache ya esta en ejecucion. >> "%LOGFILE%"
        echo Apache ya esta en ejecucion.
        exit /b
    )
    echo Iniciando Apache...
    pushd "%BASEDIR%\apache\2.4.63\bin"
    start "" httpd.exe
    popd
    echo !timestamp! Apache iniciado. >> "%LOGFILE%"
    exit /b

:: 1.27.5
:startNginx
    tasklist | find /I "php-cgi.exe" >nul
    if errorlevel 1 (
        echo Iniciando PHP FastCGI...
        pushd "%BASEDIR%\php\8.3.20"
        start "" php-cgi.exe -b 127.0.0.1:9000
        popd
        echo !timestamp! PHP FastCGI iniciado. >> "%LOGFILE%"
    ) else (
        echo PHP FastCGI ya esta corriendo.
    )

    tasklist | find /I "nginx.exe" >nul
    if not errorlevel 1 (
        echo !timestamp! Nginx ya esta en ejecucion. >> "%LOGFILE%"
        echo Nginx ya esta en ejecucion.
        exit /b
    )
    echo Iniciando Nginx...
    pushd "%BASEDIR%\nginx\1.26.3"
    start "" nginx.exe
    popd
    echo !timestamp! Nginx iniciado. >> "%LOGFILE%"
    exit /b

:startMariaDB
    tasklist | find /I "mariadbd.exe" >nul
    if not errorlevel 1 (
        echo !timestamp! MariaDB ya esta en ejecucion. >> "%LOGFILE%"
        echo MariaDB ya esta en ejecucion.
        exit /b
    )
    echo Iniciando MariaDB...
    pushd "%BASEDIR%\mariadb\11.4.5\bin"
    start "" mariadbd.exe
    popd
    echo !timestamp! MariaDB iniciada. >> "%LOGFILE%"
    exit /b

:restartAllServices
    echo Reiniciando todos los servicios...
    taskkill /F /IM httpd.exe >> "%LOGFILE%" 2>&1
    taskkill /F /IM nginx.exe >> "%LOGFILE%" 2>&1
    taskkill /F /IM php-cgi.exe >> "%LOGFILE%" 2>&1
    taskkill /F /IM mysqld.exe >> "%LOGFILE%" 2>&1
    taskkill /F /IM mariadbd.exe >> "%LOGFILE%" 2>&1
    timeout /t 2 >nul
    call :startApache
    call :startNginx
    call :startMariaDB
    echo Todos los servicios reiniciados. >> "%LOGFILE%"
    exit /b

:restartApache
    echo Reiniciando Apache...
    taskkill /F /IM httpd.exe >> "%LOGFILE%" 2>&1
    timeout /t 1 >nul
    call :startApache
    echo Apache reiniciado. >> "%LOGFILE%"
    exit /b

:restartNginx
    echo Reiniciando Nginx y PHP FastCGI...
    taskkill /F /IM nginx.exe >> "%LOGFILE%" 2>&1
    taskkill /F /IM php-cgi.exe >> "%LOGFILE%" 2>&1
    timeout /t 1 >nul
    call :startNginx
    echo Nginx y PHP FastCGI reiniciados. >> "%LOGFILE%"
    exit /b

:restartMariaDB
    echo Reiniciando MariaDB...
    taskkill /F /IM mariadbd.exe >> "%LOGFILE%" 2>&1
    timeout /t 1 >nul
    call :startMariaDB
    echo MariaDB reiniciada. >> "%LOGFILE%"
    exit /b

:mariadbConsole
    set MARIADB_BIN=%BASEDIR%\mariadb\11.4.5\bin

    if exist "%MARIADB_BIN%\mysql.exe" (
        echo Abriendo consola de MariaDB...
        pushd "%MARIADB_BIN%"
        start cmd /k "mysql -u root"
        popd
    ) else (
        echo MariaDB no está instalada o mysql.exe no se encontró.
    )
    exit /b

:uninstallNginx
    echo Desinstalando Nginx...
    taskkill /F /IM nginx.exe >nul 2>&1
    taskkill /F /IM php-cgi.exe >nul 2>&1

    set NGINX_VERSION_FILE=%BASEDIR%\..\config\nginx_version.conf

    if exist "!NGINX_VERSION_FILE!" (
        set /p NGINX_VERSION=<"!NGINX_VERSION_FILE!"
    ) else (
        echo No se encontro nginx_version.conf. Asumiendo 1.26.3
        set NGINX_VERSION=1.26.3
    )

    set NGINX_PATH=%BASEDIR%\nginx\!NGINX_VERSION!

    if exist "!NGINX_PATH!" (
        echo Eliminando carpeta: !NGINX_PATH!
        rmdir /S /Q "!NGINX_PATH!"
    )

    echo Eliminando configuracion de Nginx...
    rmdir /S /Q "%BASEDIR%\..\etc\nginx"
    del /Q "%BASEDIR%\..\config\nginx_version.conf"

    echo !timestamp! Nginx desinstalado. >> "%LOGFILE%"
    echo ✅ Nginx desinstalado correctamente.
    exit /b

:uninstallApache
    echo Desinstalando Apache...
    taskkill /F /IM httpd.exe >nul 2>&1

    set APACHE_PATH=%BASEDIR%\apache\2.4.63
    if exist "!APACHE_PATH!" (
        echo Eliminando carpeta: !APACHE_PATH!
        rmdir /S /Q "!APACHE_PATH!"
    )

    echo !timestamp! Apache desinstalado. >> "%LOGFILE%"
    echo ✅ Apache desinstalado correctamente.
    exit /b

:uninstallMySQL
    echo 🔥 Desinstalando MySQL...
    taskkill /F /IM mysqld.exe >nul 2>&1
    set MYSQL_DIR=%BASEDIR%\mysql

    if exist "%MYSQL_DIR%" (
        rmdir /S /Q "%MYSQL_DIR%"
        echo Eliminado: %MYSQL_DIR%
        echo !timestamp! MySQL eliminado. >> "%LOGFILE%"
    ) else (
        echo MySQL no está instalado o ya fue eliminado.
    )
    exit /b

:uninstallMariaDB
    echo Desinstalando MariaDB...
    taskkill /F /IM mariadbd.exe >nul 2>&1

    set MARIADB_PATH=%BASEDIR%\mariadb\11.4.5
    if exist "!MARIADB_PATH!" (
        echo Eliminando carpeta: !MARIADB_PATH!
        rmdir /S /Q "!MARIADB_PATH!"
    )

    echo !timestamp! MariaDB desinstalada. >> "%LOGFILE%"
    echo ✅ MariaDB desinstalada correctamente.
    exit /b

:uninstallPHP
    echo Desinstalando PHP...
    taskkill /F /IM php-cgi.exe >nul 2>&1
    taskkill /F /IM php.exe >nul 2>&1

    set PHP_PATH=%BASEDIR%\php\8.3.20
    if exist "!PHP_PATH!" (
        echo Eliminando carpeta: !PHP_PATH!
        rmdir /S /Q "!PHP_PATH!"
    )

    echo !timestamp! PHP desinstalado. >> "%LOGFILE%"
    echo ✅ PHP desinstalado correctamente.
    exit /b

:uninstallAllComponents
    echo ================================
    echo 🧨 Desinstalando TODO el stack...
    echo ================================
    call :uninstallApache
    call :uninstallNginx
    call :uninstallMariaDB
    call :uninstallPHP

    echo Eliminando directorios de configuracion y logs...

    set ETC_DIR=C:\webServer\etc
    set WWW_DIR=C:\webServer\www
    set DOWNLOADS_DIR=C:\webServer\downloads

    if exist "%ETC_DIR%" (
        rmdir /S /Q "%ETC_DIR%"
        echo Eliminado: %ETC_DIR%
    )

    if exist "%WWW_DIR%" (
        rmdir /S /Q "%WWW_DIR%"
        echo Eliminado: %WWW_DIR%
    )

    if exist "%LOGSDIR%" (
        rmdir /S /Q "%LOGSDIR%"
        echo Eliminado: %LOGSDIR%
    )

    if exist "%DOWNLOADS_DIR%" (
        rmdir /S /Q "%DOWNLOADS_DIR%"
        echo Eliminado: %DOWNLOADS_DIR%
    )

    echo ✅ ¡Stack desinstalado completamente!
    echo !timestamp! Todos los componentes fueron eliminados. >> "%LOGFILE%"
    exit /b
