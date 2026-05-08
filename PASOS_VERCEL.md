# Despliegue en Vercel

## Archivos listos

- `index.html`: pagina principal que debe abrir Vercel.
- `sistema-procesos-pro.html`: modulo embebido de Compras y Contrataciones.
- `SISTEMA DE PROYECTOS.html`: copia de trabajo con el mismo contenido principal.
- `vercel.json`: configuracion estatica para Vercel.
- `package.json`: scripts opcionales para usar Vercel CLI.

## Opcion 1: Subir por la web de Vercel

1. Crear una carpeta o repositorio con todos los archivos de este proyecto.
2. Entrar a Vercel y elegir Add New Project.
3. Importar el repositorio o cargar el proyecto segun el flujo disponible.
4. En Framework Preset, usar Other.
5. En Build Command, dejar vacio.
6. En Output Directory, dejar `.` o vacio para servir desde la raiz.
7. Hacer Deploy.
8. Abrir la URL publicada y verificar:
   - Dashboard principal.
   - Panel superior.
   - Boton Abrir procesos en Compras y Contrataciones.
   - Reportes, impresion y exportacion CSV.

## Opcion 2: Desplegar con Vercel CLI

1. Abrir PowerShell en esta carpeta:

```powershell
cd "C:\Users\reyesc\Documents\New project"
```

2. Instalar o ejecutar Vercel CLI:

```powershell
npx vercel
```

3. Responder las preguntas:

- Set up and deploy: `Y`
- Link to existing project: segun corresponda
- Project name: `coraamoca-proyectos`
- Directory: `./`
- Build command: dejar vacio
- Output directory: dejar vacio o `.`

4. Para publicar produccion:

```powershell
npx vercel --prod
```

## Nota importante

El sistema guarda registros en `localStorage` del navegador. En Vercel se publicara correctamente como sitio estatico, pero los datos que registre cada usuario quedaran guardados en el navegador de ese usuario, no en una base de datos central.
