USE TaskManagementDb;
GO

SET NOCOUNT ON;

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Name = N'Lider de Proyecto')
BEGIN
    INSERT INTO dbo.Roles (Name, IsActive)
    VALUES (N'Lider de Proyecto', 1);
END;

IF OBJECT_ID(N'dbo.ProjectCollaborators', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProjectCollaborators
    (
        ProjectId INT NOT NULL,
        UserId INT NOT NULL,
        AssignedAt DATETIME NOT NULL CONSTRAINT DF_ProjectCollaborators_AssignedAt DEFAULT (GETDATE()),
        CONSTRAINT PK_ProjectCollaborators PRIMARY KEY (ProjectId, UserId),
        CONSTRAINT FK_ProjectCollaborators_Projects FOREIGN KEY (ProjectId) REFERENCES dbo.Projects(ProjectId),
        CONSTRAINT FK_ProjectCollaborators_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
    );
END;
GO

DECLARE @AdminRoleId INT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE Name = N'Administrador');
DECLARE @LeaderRoleId INT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE Name = N'Lider de Proyecto');
DECLARE @CollaboratorRoleId INT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE Name = N'Colaborador');
DECLARE @GenderId INT = (SELECT TOP 1 GenderId FROM dbo.Genders WHERE IsActive = 1 ORDER BY GenderId);
DECLARE @MaritalStatusId INT = (SELECT TOP 1 MaritalStatusId FROM dbo.MaritalStatuses WHERE IsActive = 1 ORDER BY MaritalStatusId);

IF @AdminRoleId IS NULL OR @LeaderRoleId IS NULL OR @CollaboratorRoleId IS NULL
BEGIN
    THROW 50001, 'No se encontraron los roles requeridos. Verifique los scripts base.', 1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE ta
    FROM dbo.TaskAttachments ta
    INNER JOIN dbo.Tasks t ON t.TaskId = ta.TaskId
    INNER JOIN dbo.Projects p ON p.ProjectId = t.ProjectId
    WHERE p.Name LIKE N'Proyecto Demo %';

    DELETE tc
    FROM dbo.TaskComments tc
    INNER JOIN dbo.Tasks t ON t.TaskId = tc.TaskId
    INNER JOIN dbo.Projects p ON p.ProjectId = t.ProjectId
    WHERE p.Name LIKE N'Proyecto Demo %';

    DELETE al
    FROM dbo.ActivityLog al
    LEFT JOIN dbo.Projects p ON p.ProjectId = al.RelatedProjectId
    LEFT JOIN dbo.Tasks t ON t.TaskId = al.RelatedTaskId
    LEFT JOIN dbo.Projects pt ON pt.ProjectId = t.ProjectId
    WHERE (p.ProjectId IS NOT NULL AND p.Name LIKE N'Proyecto Demo %')
       OR (pt.ProjectId IS NOT NULL AND pt.Name LIKE N'Proyecto Demo %')
       OR (al.PerformedByUserId IN (SELECT UserId FROM dbo.Users WHERE UserName LIKE N'demo_%'));

    DELETE pc
    FROM dbo.ProjectCollaborators pc
    INNER JOIN dbo.Projects p ON p.ProjectId = pc.ProjectId
    WHERE p.Name LIKE N'Proyecto Demo %';

    DELETE t
    FROM dbo.Tasks t
    INNER JOIN dbo.Projects p ON p.ProjectId = t.ProjectId
    WHERE p.Name LIKE N'Proyecto Demo %';

    DELETE FROM dbo.Projects WHERE Name LIKE N'Proyecto Demo %';
    DELETE FROM dbo.Users WHERE UserName LIKE N'demo_%';

    DECLARE @PasswordHash NVARCHAR(64) = CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Demo123*'), 2);

    INSERT INTO dbo.Users (RoleId, GenderId, MaritalStatusId, FirstName, LastName, Identification, BirthDate, UserName, PasswordHash, IsActive)
    VALUES
    (@AdminRoleId, @GenderId, @MaritalStatusId, N'Adriana', N'Mendoza', N'DEMO-ADM-0001', '1989-04-12', N'demo_admin_01', @PasswordHash, 1),
    (@AdminRoleId, @GenderId, @MaritalStatusId, N'Carlos', N'Salcedo', N'DEMO-ADM-0002', '1986-08-30', N'demo_admin_02', @PasswordHash, 1),
    (@LeaderRoleId, @GenderId, @MaritalStatusId, N'Lorena', N'Pineda', N'DEMO-LDR-0001', '1991-02-17', N'demo_leader_01', @PasswordHash, 1),
    (@LeaderRoleId, @GenderId, @MaritalStatusId, N'Mario', N'Figueroa', N'DEMO-LDR-0002', '1990-11-05', N'demo_leader_02', @PasswordHash, 1);

    INSERT INTO dbo.Users (RoleId, GenderId, MaritalStatusId, FirstName, LastName, Identification, BirthDate, UserName, PasswordHash, IsActive)
    VALUES
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador01', N'Demo', N'DEMO-COL-0001', '1994-01-11', N'demo_col_01', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador02', N'Demo', N'DEMO-COL-0002', '1993-02-12', N'demo_col_02', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador03', N'Demo', N'DEMO-COL-0003', '1992-03-13', N'demo_col_03', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador04', N'Demo', N'DEMO-COL-0004', '1991-04-14', N'demo_col_04', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador05', N'Demo', N'DEMO-COL-0005', '1990-05-15', N'demo_col_05', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador06', N'Demo', N'DEMO-COL-0006', '1995-06-16', N'demo_col_06', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador07', N'Demo', N'DEMO-COL-0007', '1996-07-17', N'demo_col_07', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador08', N'Demo', N'DEMO-COL-0008', '1997-08-18', N'demo_col_08', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador09', N'Demo', N'DEMO-COL-0009', '1998-09-19', N'demo_col_09', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador10', N'Demo', N'DEMO-COL-0010', '1992-10-20', N'demo_col_10', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador11', N'Demo', N'DEMO-COL-0011', '1993-11-21', N'demo_col_11', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador12', N'Demo', N'DEMO-COL-0012', '1994-12-22', N'demo_col_12', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador13', N'Demo', N'DEMO-COL-0013', '1990-01-23', N'demo_col_13', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador14', N'Demo', N'DEMO-COL-0014', '1991-02-24', N'demo_col_14', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador15', N'Demo', N'DEMO-COL-0015', '1992-03-25', N'demo_col_15', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador16', N'Demo', N'DEMO-COL-0016', '1993-04-26', N'demo_col_16', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador17', N'Demo', N'DEMO-COL-0017', '1994-05-27', N'demo_col_17', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador18', N'Demo', N'DEMO-COL-0018', '1995-06-28', N'demo_col_18', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador19', N'Demo', N'DEMO-COL-0019', '1996-07-12', N'demo_col_19', @PasswordHash, 1),
    (@CollaboratorRoleId, @GenderId, @MaritalStatusId, N'Colaborador20', N'Demo', N'DEMO-COL-0020', '1997-08-13', N'demo_col_20', @PasswordHash, 1);

    DECLARE @Leader01Id INT = (SELECT UserId FROM dbo.Users WHERE UserName = N'demo_leader_01');
    DECLARE @Leader02Id INT = (SELECT UserId FROM dbo.Users WHERE UserName = N'demo_leader_02');

    INSERT INTO dbo.Projects (Name, ClientName, Description, StartDate, EndDate, Status, Priority, CreatedByUserId)
    VALUES
    (N'Proyecto Demo 01 - Portal Comercial', N'Cliente Atlas', N'Modernización del portal comercial y flujo de cotizaciones.', '2025-01-08', '2025-04-30', N'En ejecución', N'Alto', @Leader01Id),
    (N'Proyecto Demo 02 - Integración ERP', N'Cliente Boreal', N'Integración de inventario y facturación con ERP central.', '2025-02-03', '2025-06-20', N'Planificado', N'Medio', @Leader02Id),
    (N'Proyecto Demo 03 - App de Ventas', N'Cliente Celta', N'Aplicación móvil para fuerza de ventas y seguimiento.', '2025-01-15', '2025-05-15', N'Bloqueado', N'Alto', @Leader01Id),
    (N'Proyecto Demo 04 - Data Warehouse', N'Cliente Delta', N'Consolidación de datos y reportes ejecutivos.', '2025-03-01', '2025-08-25', N'En ejecución', N'Medio', @Leader02Id),
    (N'Proyecto Demo 05 - Mesa de Ayuda', N'Cliente Épsilon', N'Implementación del nuevo flujo de soporte interno.', '2025-01-25', '2025-03-22', N'Completado', N'Bajo', @Leader01Id),
    (N'Proyecto Demo 06 - Automatización QA', N'Cliente Futura', N'Automatización de pruebas regresivas y smoke tests.', '2025-04-10', '2025-09-30', N'Planificado', N'Alto', @Leader02Id),
    (N'Proyecto Demo 07 - Gestión Documental', N'Cliente Galia', N'Gestión documental con aprobación por etapas.', '2025-02-18', '2025-07-12', N'En ejecución', N'Medio', @Leader01Id),
    (N'Proyecto Demo 08 - Backoffice RRHH', N'Cliente Horizonte', N'Backoffice para procesos de recursos humanos.', '2025-03-11', '2025-06-28', N'Bloqueado', N'Medio', @Leader02Id),
    (N'Proyecto Demo 09 - API de Pagos', N'Cliente Ícaro', N'API de pagos y conciliación bancaria.', '2025-01-05', '2025-04-02', N'Completado', N'Alto', @Leader01Id),
    (N'Proyecto Demo 10 - Observabilidad', N'Cliente Júpiter', N'Trazabilidad, métricas y alertas de plataforma.', '2025-04-01', '2025-10-31', N'Planificado', N'Bajo', @Leader02Id);

    DECLARE @Projects TABLE (RowNumber INT IDENTITY(1,1), ProjectId INT);
    INSERT INTO @Projects (ProjectId)
    SELECT ProjectId
    FROM dbo.Projects
    WHERE Name LIKE N'Proyecto Demo %'
    ORDER BY ProjectId;

    DECLARE @Collaborators TABLE (RowNumber INT IDENTITY(1,1), UserId INT);
    INSERT INTO @Collaborators (UserId)
    SELECT UserId
    FROM dbo.Users
    WHERE UserName LIKE N'demo_col_%'
    ORDER BY UserName;

    DECLARE @ProjectCount INT = (SELECT COUNT(1) FROM @Projects);
    DECLARE @CollaboratorCount INT = (SELECT COUNT(1) FROM @Collaborators);
    DECLARE @ProjectIndex INT = 1;

    WHILE @ProjectIndex <= @ProjectCount
    BEGIN
        DECLARE @ProjectId INT = (SELECT ProjectId FROM @Projects WHERE RowNumber = @ProjectIndex);
        DECLARE @AssignIndex INT = 0;

        WHILE @AssignIndex < 6
        BEGIN
            DECLARE @CollaboratorRow INT = ((@ProjectIndex + @AssignIndex - 1) % @CollaboratorCount) + 1;
            DECLARE @CollaboratorUserId INT = (SELECT UserId FROM @Collaborators WHERE RowNumber = @CollaboratorRow);

            INSERT INTO dbo.ProjectCollaborators (ProjectId, UserId)
            VALUES (@ProjectId, @CollaboratorUserId);

            SET @AssignIndex = @AssignIndex + 1;
        END;

        SET @ProjectIndex = @ProjectIndex + 1;
    END;

    DECLARE @TaskCounter INT = 1;
    SET @ProjectIndex = 1;

    WHILE @ProjectIndex <= @ProjectCount
    BEGIN
        DECLARE @CurrentProjectId INT = (SELECT ProjectId FROM @Projects WHERE RowNumber = @ProjectIndex);
        DECLARE @CurrentProjectStartDate DATE = (SELECT StartDate FROM dbo.Projects WHERE ProjectId = @CurrentProjectId);
        DECLARE @CreatedByUserId INT = (SELECT CreatedByUserId FROM dbo.Projects WHERE ProjectId = @CurrentProjectId);
        DECLARE @TaskPerProject INT = 1;

        WHILE @TaskPerProject <= 4
        BEGIN
            DECLARE @TaskStatus NVARCHAR(50);
            DECLARE @TaskPriority NVARCHAR(20);
            DECLARE @TaskProgress INT;
            DECLARE @AssignedRow INT = ((@TaskCounter - 1) % @CollaboratorCount) + 1;
            DECLARE @AssignedUserId INT = (SELECT UserId FROM @Collaborators WHERE RowNumber = @AssignedRow);
            DECLARE @TaskStartDate DATE = DATEADD(DAY, @TaskPerProject * 3, @CurrentProjectStartDate);
            DECLARE @TaskEndDate DATE = DATEADD(DAY, @TaskPerProject * 7 + 10, @TaskStartDate);

            IF (@TaskCounter % 4 = 1)
            BEGIN
                SET @TaskStatus = N'Planificado';
                SET @TaskProgress = 15;
            END
            ELSE IF (@TaskCounter % 4 = 2)
            BEGIN
                SET @TaskStatus = N'En ejecución';
                SET @TaskProgress = 45;
            END
            ELSE IF (@TaskCounter % 4 = 3)
            BEGIN
                SET @TaskStatus = N'Bloqueado';
                SET @TaskProgress = 30;
            END
            ELSE
            BEGIN
                SET @TaskStatus = N'Completado';
                SET @TaskProgress = 100;
            END;

            IF (@TaskCounter % 3 = 1)
            BEGIN
                SET @TaskPriority = N'Alto';
            END
            ELSE IF (@TaskCounter % 3 = 2)
            BEGIN
                SET @TaskPriority = N'Medio';
            END
            ELSE
            BEGIN
                SET @TaskPriority = N'Bajo';
            END;

            INSERT INTO dbo.Tasks
            (
                ProjectId,
                AssignedUserId,
                CreatedByUserId,
                Name,
                Description,
                Status,
                Priority,
                StartDate,
                Progress,
                EstimatedHours,
                DueDate
            )
            VALUES
            (
                @CurrentProjectId,
                @AssignedUserId,
                @CreatedByUserId,
                N'Tarea Demo ' + RIGHT('000' + CAST(@TaskCounter AS NVARCHAR(10)), 3),
                N'Tarea de prueba para validar permisos y flujo operativo del proyecto.',
                @TaskStatus,
                @TaskPriority,
                @TaskStartDate,
                @TaskProgress,
                6 + (@TaskPerProject * 2),
                @TaskEndDate
            );

            SET @TaskCounter = @TaskCounter + 1;
            SET @TaskPerProject = @TaskPerProject + 1;
        END;

        SET @ProjectIndex = @ProjectIndex + 1;
    END;

    INSERT INTO dbo.ActivityLog
    (
        EntityType,
        ActivityType,
        Description,
        RelatedProjectId,
        RelatedTaskId,
        PerformedByUserId
    )
    SELECT
        N'Project',
        N'Create',
        N'Se creó el proyecto "' + p.Name + N'".',
        p.ProjectId,
        NULL,
        p.CreatedByUserId
    FROM dbo.Projects p
    WHERE p.Name LIKE N'Proyecto Demo %';

    INSERT INTO dbo.ActivityLog
    (
        EntityType,
        ActivityType,
        Description,
        RelatedProjectId,
        RelatedTaskId,
        PerformedByUserId
    )
    SELECT
        N'Project',
        N'StatusChange',
        N'Se cambió el estado del proyecto "' + p.Name + N'" de "Planificado" a "' + p.Status + N'".',
        p.ProjectId,
        NULL,
        p.CreatedByUserId
    FROM dbo.Projects p
    WHERE p.Name LIKE N'Proyecto Demo %'
      AND p.Status <> N'Planificado';

    INSERT INTO dbo.ActivityLog
    (
        EntityType,
        ActivityType,
        Description,
        RelatedProjectId,
        RelatedTaskId,
        PerformedByUserId
    )
    SELECT
        N'Task',
        N'Create',
        N'Se creó la tarea "' + t.Name + N'".',
        t.ProjectId,
        t.TaskId,
        t.CreatedByUserId
    FROM dbo.Tasks t
    INNER JOIN dbo.Projects p ON p.ProjectId = t.ProjectId
    WHERE p.Name LIKE N'Proyecto Demo %';

    INSERT INTO dbo.ActivityLog
    (
        EntityType,
        ActivityType,
        Description,
        RelatedProjectId,
        RelatedTaskId,
        PerformedByUserId
    )
    SELECT
        N'Task',
        N'StatusChange',
        N'La tarea "' + t.Name + N'" cambió de estado de "Planificado" a "' + t.Status + N'".',
        t.ProjectId,
        t.TaskId,
        ISNULL(t.AssignedUserId, t.CreatedByUserId)
    FROM dbo.Tasks t
    INNER JOIN dbo.Projects p ON p.ProjectId = t.ProjectId
    WHERE p.Name LIKE N'Proyecto Demo %'
      AND t.Status <> N'Planificado';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    THROW;
END CATCH;

SELECT
    (SELECT COUNT(1) FROM dbo.Users WHERE UserName LIKE N'demo_%') AS DemoUsers,
    (SELECT COUNT(1) FROM dbo.Projects WHERE Name LIKE N'Proyecto Demo %') AS DemoProjects,
    (SELECT COUNT(1) FROM dbo.Tasks t INNER JOIN dbo.Projects p ON p.ProjectId = t.ProjectId WHERE p.Name LIKE N'Proyecto Demo %') AS DemoTasks,
    (SELECT COUNT(1) FROM dbo.ProjectCollaborators pc INNER JOIN dbo.Projects p ON p.ProjectId = pc.ProjectId WHERE p.Name LIKE N'Proyecto Demo %') AS DemoProjectCollaborators;
GO
