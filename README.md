# Task Management System

Aplicacion para prueba tecnica desarrollada con ASP.NET Web Forms, C#, SQL Server 2019 y ADO.NET puro, compatible con Visual Studio 2015.

## 1) Alcance funcional implementado

- Login con usuario/contraseña y persistencia por cookie.
- CRUD de usuarios.
- CRUD de proyectos.
- CRUD de tareas.
- Asignación de tareas y colaboradores por proyecto.
- Comentarios y adjuntos por tarea.
- Filtros de consulta en usuarios, proyectos, tareas e historial.
- Reportes con Report Viewer respetando filtros activos.
- Catálogos desde BD: roles, género y estado civil.
- Datepicker para fecha de nacimiento y tooltips en campos de entrada.

## 2) Stack y restricciones cumplidas

- Visual Studio 2015 (solution format VS14).
- .NET Framework 4.6.1.
- ASP.NET Web Forms (`.aspx`).
- SQL Server 2019.
- ADO.NET puro (sin Entity Framework).
- Frontend con HTML, JavaScript, jQuery y jQuery UI.
- Sin controles de servidor ASP.NET para formularios/listados (`TextBox`, `GridView`, etc.).

## 3) Arquitectura del repositorio

- `src/TaskManagementSystem/Presentation`: paginas `.aspx`, code-behind, estilos, scripts, login, validacion de sesion.
- `src/TaskManagementSystem/Logic`: servicios de negocio y validaciones.
- `src/TaskManagementSystem/DataAccess`: repositorios ADO.NET, ejecucion de SPs, mapeo de datos.
- `src/TaskManagementSystem/Objects`: entidades, filtros y respuestas comunes.
- `Database`: creacion de esquema, stored procedures, alter scripts y datos demo.

## 4) Prerrequisitos

- Windows con Visual Studio 2015.
- .NET Framework 4.6.1 Developer Pack.
- SQL Server 2019.
- SSMS (recomendado para ejecutar scripts SQL).
- NuGet habilitado en Visual Studio.

Opcional (entorno de BD con contenedor):

- Docker Desktop.
- `docker-compose.yml` levanta SQL Server en `localhost,1455`.

## 5) Preparacion de base de datos

Ejecutar scripts en este orden exacto:

1. `Database/001_CreateDatabase.sql`
2. `Database/002_CreateStoredProcedures.sql`
3. `Database/003_SeedDemoData.sql`

La base resultante es `TaskManagementDb`.

## 6) Cadena de conexion

Editar `src/TaskManagementSystem/Presentation/Web.config` segun su instancia SQL:

```xml
<add name="TaskManagementDb"
     connectionString="Data Source=localhost,1455;Initial Catalog=TaskManagementDb;User ID=sa;Password=Your_password123;Encrypt=False;TrustServerCertificate=True"
     providerName="System.Data.SqlClient" />
```

## 7) Restaurar dependencias

Abrir `src/TaskManagementSystem/TaskManagementSystem.sln` y ejecutar:

1. Click derecho sobre la solucion -> `Restore NuGet Packages`.
2. Compilar una vez (`Build Solution`).

Si en una maquina limpia faltan assemblies de Report Viewer o SQL Types, instalar en Package Manager Console:

```powershell
Install-Package Microsoft.ReportingServices.ReportViewerControl.WebForms -Version 150.1652.0 -ProjectName Presentation
Install-Package Microsoft.SqlServer.Types -Version 14.0.314.76 -ProjectName Presentation
```

## 8) Ejecutar la aplicacion

1. Establecer `Presentation` como proyecto de inicio.
2. Verificar que la cadena de conexion apunte a la BD restaurada.
3. Ejecutar con IIS Express.
4. Navegar a `Login.aspx`.

## 9) Credenciales de prueba

Usuario base (script 001):

- Usuario: `admin`
- Contrasena: `Admin123*`

Usuarios demo (script 008):

- Administrador: `demo_admin_01`
- Lider de Proyecto: `demo_leader_01`
- Colaborador: `demo_col_01`
- Contrasena para todos los demo: `Demo123*`

## 10) Reportes disponibles

- `src/TaskManagementSystem/Presentation/Pages/Reports.aspx`
- `src/TaskManagementSystem/Presentation/Pages/ProjectStatusReport.aspx`
- `src/TaskManagementSystem/Presentation/Pages/ProjectTaskStatusReport.aspx`
- `src/TaskManagementSystem/Presentation/Pages/UserTaskAssignmentReport.aspx`

## 11) Zona horaria y visualizacion de horas

- La aplicacion muestra comentarios, actividad y adjuntos en hora local del navegador del usuario.
- Esto evita confusion entre usuarios de distintos paises.

## 12) Documentacion de entrega

- Decisiones tecnicas y arquitectura: `Documentacion/DecisionesTecnicas.md`

## 13) Levantar proyecto

Objetivo: asegurar el levantamiento del proyecto.

Pasos sugeridos:

1. Clonar el repo en otra PC (o en una VM limpia).
2. Verificar instalacion minima: VS2015 + .NET 4.6.1 + SQL Server 2019.
3. Ejecutar scripts SQL (`001` a `003`) en orden.
4. Abrir la solucion y restaurar NuGet (`Restore NuGet Packages`).
5. Si falla por ReportViewer/SqlTypes, instalar paquetes con los comandos de la seccion 7.
6. Compilar solucion completa en `Debug`.
7. Ejecutar `Presentation` y validar login + flujo basico (`QA-01`, `QA-12`, `QA-18`, `QA-29`).

Resultado esperado:

- Build exitoso.
- App levanta sin errores de assemblies faltantes.
- Login y operaciones base funcionando.
