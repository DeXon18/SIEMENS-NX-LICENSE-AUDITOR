# SIEMENS NX LICENSE AUDITOR (DX-CORE)

**Herramienta de Auditoría y Gestión de Licencias para Siemens NX.**  
Desarrollada por **ATS Global Spain**.

Esta utilidad permite visualizar y conmutar rápidamente la configuración de licencias de Siemens NX (Variable de Entorno y Registro de Windows) entre un servidor local y la configuración en la nube (Cloud), con soporte para múltiples versiones y protección para instalaciones antiguas.

## 🚀 Características Principales

- **Auditoría Visual (Dashboard):** Visualización clara y tabular de todas las versiones de NX instaladas, su arquitectura (x64/x86) y su estado actual de licencia.
- **Gestión Multi-Versión:** Detecta dinámicamente versiones instaladas en `HKLM\SOFTWARE\Siemens` y `HKLM\SOFTWARE\WOW6432Node\Siemens`.
- **Soporte Common Licensing:** Gestiona también la clave `NX_SERVER` en `HKCU\Software\Siemens_PLM_Software\Common_Licensing`.
- **Modo Interactivo:**
  - **[1] NUBE:** Cambia las licencias modernas a "Cloud".
  - **[2] LOCAL:** Restaura las licencias al servidor local configurado.
  - **[3] CONFIGURAR:** Permite modificar el servidor local guardado.
- **Protección Legacy:** Las versiones **NX 2312 e inferiores** están protegidas y **NO** se cambian a modo Cloud (se mantienen siempre en Local para evitar errores).
- **Persistencia (Config.json):** Guarda tu servidor de licencias local preferido para no tener que escribirlo cada vez.
- **Launcher Automático (`.bat`):** Se encarga de solicitar permisos de Administrador y lanzar PowerShell con las políticas de ejecución correctas.

## 📋 Requisitos

- SO: Windows 10 / 11
- Permisos: **Administrador** (Requerido para modificar HKLM y Variables de Sistema).
- PowerShell 5.1 o superior.

## 🛠️ Instalación y Uso

1.  Descarga el repositorio o los archivos `.bat` y `.ps1`.
2.  Mantén ambos archivos en la misma carpeta.
3.  **Ejecución:**
    - Haz doble clic en **`Switch-License.bat`**.
    - Si se solicita, acepta el aviso de Control de Cuentas de Usuario (UAC).
4.  **Primera Vez:**
    - Si no tienes un archivo `config.json`, el script intentará detectar tu servidor local.
    - Si no lo detecta, te pedirá que lo ingreses (ej. `28000@servidor`).

## ⚙️ Estructura del Proyecto

- **`Switch-License.bat`**: Lanzador. Gestiona la elevación a Admin y lanza el script de PowerShell.
- **`Switch-License.ps1`**: Núcleo lógico. Contiene el dashboard, lógica de registro y menús.
- **`config.json`**: (Generado automáticamente) Almacena la dirección del servidor local.

## 👤 Autor

**Oskar Blazquez**  
ATS Global Spain  
Contacto: `Oskar.Blazquez@ats-global.com` | `Soporte@ats-global.com`
