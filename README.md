# SIEMENS NX LICENSE AUDITOR (DX-CORE)
![Imagen descriptiva](https://i.imgur.com/HQeoMtI.png)

**Herramienta de Auditoría y Gestión de Licencias para Siemens NX.**  
Desarrollada por **ATS Global Spain**.

Esta utilidad permite visualizar y conmutar rápidamente la configuración de licencias de Siemens NX (Variable de Entorno y Registro de Windows) entre un servidor local y la configuración en la nube (Cloud), con soporte para múltiples versiones y protección para instalaciones antiguas.

## 🚀 Características Principales

- **Auditoría Visual (Dashboard):** Visualización clara y tabular de todas las versiones de NX instaladas, su arquitectura (x64/x86) y su estado actual de licencia.
- **Gestión Multi-Versión:** Detecta dinámicamente versiones instaladas en `HKLM\SOFTWARE\Siemens` y `HKLM\SOFTWARE\WOW6432Node\Siemens`. Soporta tanto **NX** como **Designcenter** (v2512+).
- **Modo Interactivo:**
  - **[1] NUBE:** Cambia las licencias modernas a "Cloud".
  - **[2] LOCAL:** Restaura las licencias al servidor local configurado.
  - **[3] CONFIGURAR:** Permite modificar el servidor local guardado.
- **Seguridad y Auditoría:**
  - **Chequeo de Procesos:** Detecta si NX (`ugraf`) o DesignCenter están abiertos y avisa antes de aplicar cambios.
  - **Logs (`audit.log`):** Registra cada cambio realizado (fecha, usuario y éxito/error) en un archivo local.
- **Protección Legacy:** Las versiones **NX 2312 e inferiores** están protegidas y **NO** se cambian a modo Cloud.
- **Persistencia (Config.json):** Guarda tu servidor de licencias local preferido.
- **Launcher Automático (`.bat`):** Maneja la elevación de permisos y configuración de ventana (120x40).

## 📋 Requisitos

- SO: Windows 10 / 11
- Permisos: **Administrador** (Requerido para modificar HKLM y Variables de Sistema).
- PowerShell 5.1 o superior.

## 🛠️ Instalación y Uso

1.  **Descarga la última versión** desde la sección [Releases](https://github.com/DeXon18/SIEMENS-NX-LICENSE-AUDITOR/releases/latest).
    - _Busca el archivo `NX-License-Auditor_vX.X.zip` en la lista de "Assets"._
2.  Descomprime el archivo y mantén todos los archivos en la misma carpeta.
3.  **Ejecución:**
    - Haz doble clic en **`Switch-License.bat`**.
    - Si se solicita, acepta el aviso de Control de Cuentas de Usuario (UAC).
4.  **Primera Vez:**
    - El script detectará licencias instaladas (NX / Designcenter).
    - Si no tienes configurado un servidor local, te pedirá ingresarlo (ej. `29000@servidor`).

## ⚙️ Estructura del Proyecto

- **`Switch-License.bat`**: Lanzador. Gestiona permisos, colores y lanza PowerShell.
- **`Switch-License.ps1`**: Lógica principal. Dashboard, Registro, Safety Checks.
- **`config.json`**: Almacena la dirección del servidor local.
- **`audit.log`**: Historial de cambios realizados por la herramienta.
- **`MANUAL_DE_USO.md`**: Guía detallada para el usuario final.

## 👤 Autor

**Oskar Blazquez**  
_Software License Support Specialist & Automation Enthusiast_  
ATS Global Spain  
Contacto: `Oskar.Blazquez@ats-global.com` | `Soporte@ats-global.com`
