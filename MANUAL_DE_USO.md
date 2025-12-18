# MANUAL DE USO: SIEMENS NX LICENSE AUDITOR

Este documento explica cómo utilizar la herramienta **SIEMENS NX LICENSE AUDITOR (DX-CORE)** para gestionar las licencias de sus productos Siemens (NX y Designcenter).

---

## 1. Introducción

Esta herramienta permite a los usuarios cambiar rápida y seguramente entre dos tipos de licencias:

- **Licencia Local**: Servidor de licencias tradicional (ej: `29000@192.168.1.150`).
- **Licencia Cloud**: Nuevas licencias basadas en la nube.

Además, protege automáticamente las versiones antiguas que no soportan la nube.

## 2. Primeros Pasos

### Ejecución

Para iniciar el programa:

1.  Localice la carpeta donde descargó los archivos.
2.  Haga **doble clic** en el archivo **`Switch-License.bat`**.
3.  Windows le pedirá permisos de Administrador. Haga clic en **Sí**.
    - _Nota: Esto es necesario porque la herramienta modifica el Registro de Windows y Variables de Entorno._

### Configuración Inicial

La primera vez que abra el programa, le pedirá que indique su **Servidor de Licencias Local**.

- Escriba la dirección y puerto (ej: `29000@servidor_licencias`) y presione ENTER.
- Esta configuración se guardará para el futuro.

---

## 3. Pantalla Principal (Dashboard)

Una vez iniciado, verá una pantalla negra con una tabla.

### Columnas Explicadas

1.  **VERSION**: El nombre del producto instalado (ej: `NX 2312`, `Designcenter 2512`).
2.  **ARQ.**: Arquitectura del software (`x64` o `x86`).
3.  **ESTADO**: Indica cómo está configurado actualmente:
    - `[ OK ]`: Configurado correctamente en Local.
    - `[ NUBE ]`: Configurado para usar licencia Cloud.
    - `[ PROTEGIDO ]`: Versión antigua bloqueada en Local por seguridad.
    - `[ VACIO ]` o `[ ERROR ]`: Problemas de detección.
4.  **CONFIGURACION LICENCIA**: El valor real que tiene el registro (ej: `29000@...` o `cloud`).

---

## 4. Opciones Disponibles

Use los números del teclado para seleccionar una acción:

### `[1] Cambiar a NUBE (Cloud)`

- Cambia todas las versiones compatibles a modo `cloud`.
- **Protección**: Las versiones antiguas (NX 2312 o anteriores) NO se cambiarán, se quedarán en local para evitar que dejen de funcionar.

### `[2] Cambiar a LOCAL`

- Restaura todas las versiones al servidor que configuró (ej: `29000@...`).

### `[3] Modificar Servidor Local`

- Si su servidor de licencias IP cambia, use esta opción para actualizar la dirección guardada.

### `[4] Recargar`

- Vuelve a escanear el registro por si instaló algo nuevo mientras la herramienta estaba abierta.

---

## 5. Seguridad y Logs

### Advertencia de Procesos Abiertos

Si intenta cambiar la licencia mientras tiene **NX** o **DesignCenter** abierto:

- El programa detectará los procesos `ugraf` o `DesignCenter`.
- Le mostrará un aviso en amarillo recomendando cerrarlos.
- _Recuerde: Los cambios de licencia no afectan a programas ya abiertos hasta que los reinicie._

### Historial (Logs)

Cada vez que realice un cambio, el programa guarda un registro en el archivo **`audit.log`** dentro de la misma carpeta. Este archivo contiene:

- Fecha y Hora exactas.
- Usuario de Windows.
- Si el cambio fue exitoso o falló.
- Qué versiones fueron afectadas.

---

## 6. Solución de Problemas

- **"Acceso Denegado"**: Asegúrese de ejecutar siempre el archivo `.bat` (no el `.ps1` directamente) y aceptar permisos de Administrador.
- **"No se encuentran instalaciones"**: Verifique que tiene versiones de NX o Designcenter instaladas en el equipo.
- **El programa se cierra enseguida**: Puede que su política de ejecución de PowerShell sea muy estricta. El `.bat` intenta evitar esto, pero si persiste, contacte a soporte.

---

**Soporte Técnico**
Para más ayuda, contacte al administrador del sistema o al desarrollador indicado en el programa.
