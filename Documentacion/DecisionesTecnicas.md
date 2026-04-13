# Decisiones Tecnicas - Task Management System

## 1. Contexto y objetivo

Se implemento una aplicacion de gestion de proyectos y tareas para prueba tecnica, cumpliendo restricciones de stack legacy:

- Visual Studio 2015.
- ASP.NET Web Forms.
- C# sobre .NET Framework 4.6.1.
- SQL Server 2019.
- ADO.NET puro.
- Frontend con HTML + JavaScript + jQuery + jQuery UI.

## 2. Arquitectura

Se uso arquitectura en 4 capas para separar responsabilidades y facilitar mantenimiento.

### 2.1 Capa Presentacion (`Presentation`)

- Paginas `.aspx` + code-behind.
- AJAX via `PageMethods` (`[WebMethod]`) para operaciones CRUD y consultas.
- Scripts compartidos en `Scripts/app-common.js` (utilidades de UI, fechas, mensajes, encoding).
- Validacion de sesion en `BasePage` y validacion de sesion para WebMethods en `WebMethodSessionValidator`.

### 2.2 Capa Logica (`Logic`)

- Servicios por modulo (`UserService`, `ProjectService`, `TaskService`, `AuthService`, etc.).
- Reglas de negocio y validaciones de consistencia antes de persistir.
- Orquestacion entre repositorios cuando un caso requiere varias entidades.

### 2.3 Capa Acceso a Datos (`DataAccess`)

- Repositorios por agregado (`UserRepository`, `ProjectRepository`, `TaskRepository`, etc.).
- ADO.NET con `SqlConnection`, `SqlCommand`, `SqlDataReader`.
- Consumo principal por stored procedures y parametros.
- Mapeo de registros a entidades de `Objects`.

### 2.4 Capa Objetos (`Objects`)

- Entidades de dominio.
- Objetos de filtro para consultas.
- Respuestas de operacion (`OperationResult`).

## 3. Patrones y enfoques de diseno usados

## 3.1 Layered Architecture

- Motivo: separar UI, negocio, persistencia y contratos.
- Beneficio: reduce acoplamiento y permite evolucionar una capa sin romper las otras.

## 3.2 Repository Pattern (en DAL)

- Motivo: encapsular acceso SQL y centralizar queries/SPs.
- Beneficio: code-behind y servicios no conocen detalles de SQL.

## 3.3 Service Layer (en BLL)

- Motivo: concentrar reglas de negocio y validaciones.
- Beneficio: evita duplicar logica entre paginas.

## 3.4 Page Controller de Web Forms

- Cada pagina controla su flujo y expone WebMethods para AJAX.
- Motivo: encajar con paradigma nativo de Web Forms y VS2015.

## 3.5 Helper-based Cross-Cutting

- Helpers para funciones transversales: sesion, autorizacion, cookies, logging de actividad, extensiones de lectura.
- Motivo: evitar duplicacion de codigo y errores repetidos.

## 4. Decisiones de seguridad

## 4.1 Autenticacion y sesion

- Password hashing con SHA-256 (sin texto plano).
- Cookie de autenticacion protegida (firma/cifrado con `MachineKey.Protect`), `HttpOnly` y validacion de expiracion.
- Redireccion a login cuando no hay sesion valida.

## 4.2 Prevencion XSS

- En salida server-side se aplica encode (`Server.HtmlEncode`) en campos visibles.
- En render dinamico cliente se usa `htmlEncode` antes de inyectar HTML.

## 4.3 Acceso a datos seguro

- Parametrizacion de comandos para evitar SQL injection.
- Reglas de permisos por rol en pagina y WebMethods.

## 5. Decisiones de datos y persistencia

- SQL Server 2019 como motor relacional.
- Stored procedures para operaciones principales y reportes.
- Catalogos en tablas maestras (`Roles`, `Genders`, `MaritalStatuses`).
- Script de seed demo para poblar usuarios/proyectos/tareas y acelerar QA.

## 6. Decisiones de frontend

- HTML semantico + CSS custom (sin plantillas externas).
- jQuery para manejo de eventos y llamadas AJAX.
- jQuery UI para `datepicker` y tooltips.
- Responsive por media queries en `Content/site.css`.

## 7. Reporteria

- Report Viewer (`Microsoft.ReportViewer.WebForms`) con RDLC local.
- Pagina central `Reports.aspx` y 3 reportes especializados.
- Los reportes reciben filtros activos via querystring.

## 8. Manejo de fechas y zona horaria

- Se normalizo la visualizacion para mostrar horas en la zona local del usuario en cliente.
- Se ajusto historial y reportes para considerar offset de zona horaria del navegador cuando aplica.
- Objetivo: evitar confusion entre usuarios de diferentes paises.

## 9. Librerias/tecnologias usadas y motivo

| Tecnologia | Uso | Motivo |
|---|---|---|
| ASP.NET Web Forms | UI server-rendered y ciclo de paginas | Restriccion de prueba y compatibilidad VS2015 |
| ADO.NET (`SqlClient`) | Persistencia SQL | Restriccion explicita, control fino de consultas |
| jQuery | DOM, AJAX, eventos | Simplicidad y compatibilidad en entorno legacy |
| jQuery UI | Datepicker, tooltip | Requisito funcional (fecha y ayuda en campos) |
| Report Viewer WebForms | Reportes RDLC | Requisito funcional de reporteria |
| SQL Server 2019 | Base de datos | Requisito de stack |

## 10. Justificacion de calidad de entrega

La solucion prioriza:

- Cumplimiento estricto del enunciado y stack obligatorio.
- Separacion clara por capas.
- Operabilidad: scripts SQL ordenados, datos demo y checklist de QA para validar rapido.
