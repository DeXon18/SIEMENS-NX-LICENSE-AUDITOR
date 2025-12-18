@echo off
REM ============================================================================
REM   ATS GLOBAL SPAIN | SIEMENS NX MANAGER
REM   Developer: Oskar Blazquez
REM   Email:     Oskar.Blazquez@ats-global.com | Soporte@ats-global.com
REM ============================================================================

TITLE ATS GLOBAL - SIEMENS NX MANAGER
CLS

REM 1. Verificacion de Privilegios (Admin Check)
REM ----------------------------------------------------------------------------
openfiles >nul 2>&1
if %errorlevel% NEQ 0 (
    color 4F
    echo.
    echo  ======================================================================
    echo   [ ! ]  E R R O R   D E   P E R M I S O S
    echo  ======================================================================
    echo.
    echo    El script requiere privilegios elevados para cambiar configuraciones.
    echo.
    echo    INSTRUCCIONES:
    echo    1. Cierre esta ventana.
    echo    2. Haga CLIC DERECHO en el archivo "Switch-License.bat".
    echo    3. Seleccione "EJECUTAR COMO ADMINISTRADOR".
    echo.
    echo  ======================================================================
    echo.
    pause
    exit /b
)

REM 2. Secuencia de Arranque
REM ----------------------------------------------------------------------------
REM Color 0B = Fondo Negro, Letras Cian
color 0B

echo.
echo  ======================================================================
echo    SIEMENS NX  ::  LICENSE SWITCHER UTILITY
echo  ======================================================================
echo.

REM Situarse en la raiz
cd /d "%~dp0"
echo   [ OK ] Directorio Raiz Montado: %CD%

REM 3. Verificacion de Integridad
REM ----------------------------------------------------------------------------
if not exist "Switch-License.ps1" (
    color 0C
    echo.
    echo   [FAIL] ERROR CRITICO: Archivo "Switch-License.ps1" perdido.
    echo          Verifique que ambos archivos esten en la misma carpeta.
    pause
    exit /b
)

echo   [ OK ] Integridad de Archivos Verificada.
echo.
echo   [ ^>^> ] INICIANDO UTILIDAD DE CONFIGURACION...
echo.

REM Pequeña pausa dramática
timeout /t 1 >nul

REM 4. Ejecucion del Motor
REM ----------------------------------------------------------------------------
REM Lanzamos PowerShell en nueva ventana (start) pero NO maximizada (sin /MAX)
start "Siemens NX Configurator" powershell.exe -NoLogo -NoExit -NoProfile -ExecutionPolicy Bypass -File ".\Switch-License.ps1"

exit
