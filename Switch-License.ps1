<#
    .SYNOPSIS
    Siemens NX License Auditor & Switcher (DX-CORE)
    
    .DESCRIPTION
    Herramienta para gestionar y auditar licencias de Siemens NX localmente.
    Permite alternar entre servidores locales y configuración Cloud, protegiendo versiones antiguas.

    .AUTHOR
    Oskar Blazquez (ATS Global Spain)
    Contacto: Oskar.Blazquez@ats-global.com
    GitHub: https://github.com/DeXon18

    .CHANGELOG
    [2025-12-18] - Actualización Mayor
      - Soporte añadido: Detección de claves 'Designcenter' (v2512+).
      - Audit Log: Registro de cambios en archivo local 'audit.log'.
      - Safety Check: Detección de procesos (ugraf, DesignCenter) antes de aplicar cambios.
      - Cleanup: Eliminado soporte legacy para HKCU Common Licensing.
      - UI: Ajuste de resolución de ventana (120x40) y tablas expandidas.
#>

# Comprobar privilegios de Administrador
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning 'Se recomienda ejecutar como Administrador para asegurar acceso completo al registro.'
}

# --- CONFIGURACION VENTANA ---
try {
    $host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (120, 60)
    $host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size (120, 40)
} catch {
    # Ignorar errores si se ejecuta en un host que no soporta redimensionar (ej. ISE o VSCode integrated)
}

# --- PALETA DE COLORES (INDUSTRIAL THEME) ---
$global:colorFrame = "DarkYellow"
$global:colorBrand = "DarkGray"
$global:colorText = "White"
$global:colorHeader = "Gray"
$global:colorInfo = "DarkCyan"
$global:colorVersion = "Cyan"
$global:colorPath = "DarkGray" 
$global:colorSuccess = "Green"
$global:colorWarning = "Yellow"
$global:colorError = "Red"
$global:colorProtected = "DarkGreen" 

# --- CONFIGURACION PERSISTENTE (JSON) ---
$configFile = Join-Path $PSScriptRoot "config.json"
$global:LocalServerConfig = ""

function Initialize-SiemensConfig {
    # 1. Chequear si existe config.json
    if (Test-Path $configFile) {
        try {
            $json = Get-Content $configFile -Raw | ConvertFrom-Json
            if ($json.LocalServer) {
                $global:LocalServerConfig = $json.LocalServer
                return
            }
        } catch {
            Write-Warning "Error leyendo config.json. Se regenerara."
        }
    }

    # 2. Si no existe o fallo, determinar valor inicial
    $currentEnv = [Environment]::GetEnvironmentVariable("SPLM_LICENSE_SERVER", "Machine")
    $detectedLocal = ""

    if ($currentEnv -and $currentEnv -match "@" -and $currentEnv -notmatch "cloud") {
        # Asumimos que es un servidor local valido
        $detectedLocal = $currentEnv
    } else {
        # Preguntar al usuario una unica vez
        Clear-Host
        Write-Host " █ CONFIGURACION INICIAL REQUERIDA" -ForegroundColor $global:colorWarning
        Write-Host ""
        Write-Host " No se detecto un servidor de licencias local configurado."
        Write-Host " Por favor, introduzca el servidor de licencias LOCAL."
        Write-Host " Ejemplos: 29000@servidor  o  28000@servidor1;29000@servidor2" -ForegroundColor $global:colorHeader
        Write-Host ""
        $inputVal = Read-Host " Servidor Local > "
        
        if ([string]::IsNullOrWhiteSpace($inputVal)) {
            $detectedLocal = "29000@localhost" # Fallback por defecto si no escribe nada
        } else {
            $detectedLocal = $inputVal.Trim()
        }
    }

    # 3. Guardar en JSON
    Save-SiemensConfig $detectedLocal
}

function Save-SiemensConfig {
    param ([string]$NewServer)
    $global:LocalServerConfig = $NewServer
    $configObj = @{
        LocalServer = $NewServer
    }
    $configJson = $configObj | ConvertTo-Json
    Set-Content $configFile $configJson
}

function Set-LocalConfiguration {
    Clear-Host
    Write-Host " █ MODIFICAR SERVIDOR LOCAL" -ForegroundColor $global:colorWarning
    Write-Host ""
    Write-Host " Valor actual: $global:LocalServerConfig" -ForegroundColor $global:colorHeader
    Write-Host ""
    Write-Host " Introduzca el nuevo valor del servidor local."
    Write-Host " (Presione ENTER sin escribir nada para cancelar)" -ForegroundColor $global:colorPath
    Write-Host ""
    $inputVal = Read-Host " Nuevo Servidor Local > "
    
    if (-not [string]::IsNullOrWhiteSpace($inputVal)) {
        Save-SiemensConfig $inputVal.Trim()
        Write-Host ""
        Write-Host " [ OK ] Configuracion actualizada exitosamente." -ForegroundColor $global:colorSuccess
        Start-Sleep -Seconds 2
    } else {
        Write-Host " [ CANCELADO ] No se realizaron cambios." -ForegroundColor $global:colorWarning
        Start-Sleep -Seconds 1
    }
}

function Write-AuditLog {
    param ([string]$Message)
    $logFile = Join-Path $PSScriptRoot "audit.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $user = [Environment]::UserName
    $logLine = "[$timestamp] [$user] $Message"
    Add-Content -Path $logFile -Value $logLine
}

function Test-NXProcesses {
    $processes = Get-Process -Name "ugraf", "DesignCenter" -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host " [ ! ] ATENCION: SE DETECTARON APLICACIONES DE SIEMENS EJECUTANDOSE" -ForegroundColor $global:colorWarning
        Write-Host "       Es recomendable cerrarlas antes de cambiar la licencia." -ForegroundColor $global:colorText
        Write-Host "       (El cambio no surtira efecto hasta reiniciar la aplicacion)" -ForegroundColor $global:colorPath
        Write-Host ""
        return $true
    }
    return $false
}

# --- FUNCIONES AUXILIARES ---
function Get-NXVersionNumber {
    param ([string]$Name)
    # Extraer numero de "NX 2312" o "Designcenter 2512"
    if ($Name -match "(?:NX|Designcenter)\s*(\d+)") {
        return [int]$matches[1]
    }
    return 0
}

function Get-SiemensLicenseStatus {
    Clear-Host
    Write-Host ""
    # --- HEADER ---
    Write-Host ' █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█' -ForegroundColor $global:colorFrame
    Write-Host ' █  ' -NoNewline -ForegroundColor $global:colorFrame
    Write-Host 'DX-CORE ' -NoNewline -ForegroundColor $global:colorText
    Write-Host ':: ' -NoNewline -ForegroundColor $global:colorFrame
    Write-Host 'SIEMENS NX LICENSE AUDITOR' -NoNewline -ForegroundColor $global:colorFrame
    Write-Host '                                    ' -NoNewline 
    Write-Host '█' -ForegroundColor $global:colorFrame
    Write-Host ' █  ' -NoNewline -ForegroundColor $global:colorFrame
    Write-Host '▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀' -NoNewline -ForegroundColor $global:colorBrand
    Write-Host '                           ' -NoNewline
    Write-Host '█' -ForegroundColor $global:colorFrame
    Write-Host ' █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█' -ForegroundColor $global:colorFrame
    Write-Host ''
    
    Write-Host '   ATS GLOBAL SPAIN' -ForegroundColor $global:colorHeader
    # User requested change: colorFrame for Developer
    Write-Host '   Developer: Oskar Blazquez (Oskar.Blazquez@ats-global.com)' -ForegroundColor $global:colorFrame 
    Write-Host '   --------------------------------------------------------------------------' -ForegroundColor $global:colorBrand
    Write-Host ''

    # --- 1. SYSTEM VARIABLE ---
    $envLicense = [Environment]::GetEnvironmentVariable("SPLM_LICENSE_SERVER", "Machine")
    Write-Host ' [ SISTEMA ] ' -NoNewline -ForegroundColor $global:colorInfo
    Write-Host 'SPLM_LICENSE_SERVER : ' -NoNewline -ForegroundColor $global:colorFrame
    
    if ($envLicense) {
        Write-Host "$envLicense" -ForegroundColor $global:colorSuccess
    } else {
        Write-Host '( NO DEFINIDA )' -ForegroundColor $global:colorWarning
    }
    
    # Mostrar config cargada
    Write-Host ' [ CONFIG  ] ' -NoNewline -ForegroundColor $global:colorInfo
    Write-Host 'Servidor Local (Guardado)  : ' -NoNewline -ForegroundColor $global:colorFrame
    Write-Host "$global:LocalServerConfig" -ForegroundColor $global:colorInfo

    Write-Host ''

    # --- 2. TABLE HEADER ---
    Write-Host ' [ VERSIONES INSTALADAS ]' -ForegroundColor $global:colorInfo
    Write-Host ''
    
    Write-Host '   VERSION                      ARQ.      ESTADO          CONFIGURACION LICENCIA' -ForegroundColor $global:colorHeader
    Write-Host '   ===========================  ========  ==============  =========================================' -ForegroundColor $global:colorBrand

    $siemensRoots = @(
        @{ Path = "HKLM:\SOFTWARE\Siemens"; Arch = "x64" },
        @{ Path = "HKLM:\SOFTWARE\WOW6432Node\Siemens"; Arch = "x86" }
    )

    $totalFound = 0

    foreach ($rootObj in $siemensRoots) {
        $root = $rootObj.Path
        $arch = $rootObj.Arch

        if (Test-Path $root) {
            $nxVersions = Get-ChildItem -Path $root | Where-Object { $_.PSChildName -match "^(NX|Designcenter)\s*\d+" }
            
            if ($nxVersions) {
                foreach ($versionKey in $nxVersions) {
                    $totalFound++
                    $fullPath = $versionKey.PSPath
                    $versionName = $versionKey.PSChildName # ej "NX 2312"
                    
                    # Col 1: Version
                    Write-Host "   > $versionName".PadRight(32) -NoNewline -ForegroundColor $global:colorVersion
                    
                    # Col 2: Arquitectura
                    Write-Host "$arch".PadRight(10) -NoNewline -ForegroundColor $global:colorPath
                    
                    # Col 3 & 4: Estado y Valor
                    try {
                        $prop = Get-ItemProperty -Path $fullPath -Name "LICENSESERVER" -ErrorAction SilentlyContinue
                        
                        if ($prop -and $prop.LICENSESERVER) {
                            $val = $prop.LICENSESERVER
                            # Check if protected (Legacy <= 2312) AND Cloud
                            $vNum = Get-NXVersionNumber -Name $versionName
                            $isLegacy = ($vNum -gt 0 -and $vNum -le 2312)
                            
                            if ($val -match "cloud") {
                                Write-Host '[ NUBE ]'.PadRight(16) -NoNewline -ForegroundColor $global:colorVersion
                            } else {
                                if ($isLegacy) {
                                    Write-Host '[ PROTEGIDO ]'.PadRight(16) -NoNewline -ForegroundColor $global:colorProtected
                                } else {
                                    Write-Host '[ OK ]'.PadRight(16) -NoNewline -ForegroundColor $global:colorSuccess
                                }
                            }
                            Write-Host "$val" -ForegroundColor $global:colorText
                        } else {
                            Write-Host '[ VACIO ]'.PadRight(16) -NoNewline -ForegroundColor $global:colorError
                            Write-Host '(No definida)' -ForegroundColor $global:colorPath
                        }
                    } catch {
                        Write-Host '[ ERROR ]'.PadRight(16) -NoNewline -ForegroundColor $global:colorError
                        Write-Host 'Acceso Denegado' -ForegroundColor $global:colorError
                    }
                }
            }
        }
    }



    if ($totalFound -eq 0) {
        Write-Host ''
        Write-Host '   ( ! ) No se encontraron instalaciones de NX.' -ForegroundColor $global:colorWarning
    }
    
    Write-Host ''
    Write-Host '   --------------------------------------------------------------------------' -ForegroundColor $global:colorBrand
    Write-Host "   TOTAL: $totalFound Entradas Encontradas." -ForegroundColor $global:colorInfo
}

function Invoke-SiemensLicenseSwitch {
    param ([string]$Mode) # 'cloud' or 'local'

    $targetVal = ""
    if ($Mode -eq "cloud") { 
        $targetVal = "cloud" 
    } else { 
        # USAR VALOR DEL CONFIG
        $targetVal = $global:LocalServerConfig
    }

    # CHEQUEO DE PROCESOS (Feature 7)
    Test-NXProcesses | Out-Null
    
    # LOG INICIO (Feature 5)
    Write-AuditLog "Inicio de cambio de licencia. Modo: $Mode | Target: $targetVal"

    Write-Host ""

    Write-Host ""
    Write-Host " [ PROCESANDO CAMBIOS... ]" -ForegroundColor $global:colorWarning
    Write-Host ""

    # 1. Variable Entorno (Global) 
    try {
        [Environment]::SetEnvironmentVariable("SPLM_LICENSE_SERVER", $targetVal, "Machine")
        Write-Host "   [ SISTEMA ] Variable de entorno actualizada a: $targetVal" -ForegroundColor $global:colorSuccess
        Write-AuditLog "SUCCESS: Variable de entorno SPLM_LICENSE_SERVER actualizada."
    } catch {
        Write-Host "   [ ERROR ] No se pudo cambiar variable de entorno (¿Permisos?)" -ForegroundColor $global:colorError
        Write-AuditLog "ERROR: Fallo al actualizar Variable de entorno. $_"
    }

    # 2. Registro (Filtrado)
    $siemensRoots = @("HKLM:\SOFTWARE\Siemens", "HKLM:\SOFTWARE\WOW6432Node\Siemens")

    foreach ($root in $siemensRoots) {
        if (Test-Path $root) {
            $nxVersions = Get-ChildItem -Path $root | Where-Object { $_.PSChildName -match "^(NX|Designcenter)\s*\d+" }
            foreach ($key in $nxVersions) {
                $vName = $key.PSChildName
                $vNum = Get-NXVersionNumber -Name $vName
                
                # REGLA: Si Version <= 2312 Y Mode == Cloud -> NO TOCAR (Legacy Protection)
                if ($vNum -gt 0 -and $vNum -le 2312 -and $Mode -eq "cloud") {
                    Write-Host "   [ PROTEGIDO ] $vName es version legacy (<= 2312). Se mantiene en LOCAL." -ForegroundColor $global:colorPath
                    # No actualizamos el valor de registro
                    continue 
                }

                # Aplicar cambio
                try {
                    Set-ItemProperty -Path $key.PSPath -Name "LICENSESERVER" -Value $targetVal -ErrorAction Stop
                    Write-Host "   [ OK ] $vName actualizado a $targetVal" -ForegroundColor $global:colorSuccess
                    Write-AuditLog "SUCCESS: Registro actualizado para $vName -> $targetVal"
                } catch {
                    Write-Host "   [ ERROR ] $vName fallo al actualizar." -ForegroundColor $global:colorError
                    Write-AuditLog "ERROR: Fallo al actualizar registro para $vName ($key.PSPath). $_"
                }
            }
        }
    }
    


    Start-Sleep -Seconds 2
}

# --- INICIALIZACION ---
Initialize-SiemensConfig

# --- BUCLE PRINCIPAL ---
do {
    Get-SiemensLicenseStatus
    
    Write-Host ""
    Write-Host " ACCIONES DISPONIBLES:" -ForegroundColor $global:colorInfo
    Write-Host " [1] " -NoNewline -ForegroundColor $global:colorVersion; Write-Host "Cambiar a NUBE (Cloud)" -NoNewline -ForegroundColor $global:colorText; Write-Host " (Versiones <= 2312 se omiten)" -ForegroundColor $global:colorPath
    Write-Host " [2] " -NoNewline -ForegroundColor $global:colorSuccess; Write-Host "Cambiar a LOCAL ($global:LocalServerConfig)" -ForegroundColor $global:colorText
    Write-Host " [3] " -NoNewline -ForegroundColor $global:colorWarning; Write-Host "Modificar Servidor Local" -ForegroundColor $global:colorText
    Write-Host " [4] " -NoNewline -ForegroundColor $global:colorError; Write-Host "Recargar / Re-escanear" -ForegroundColor $global:colorText
    Write-Host " [Q] " -NoNewline -ForegroundColor $global:colorPath; Write-Host "Salir" -ForegroundColor $global:colorText
    Write-Host ""
    $sel = Read-Host " Seleccione una opcion"
    
    if ($sel -eq "1") { Invoke-SiemensLicenseSwitch -Mode "cloud" }
    if ($sel -eq "2") { Invoke-SiemensLicenseSwitch -Mode "local" }
    if ($sel -eq "3") { Set-LocalConfiguration }
    if ($sel -eq "4") { continue } # Reload
    if ($sel -eq "Q" -or $sel -eq "q") { break }
    
} while ($true)
