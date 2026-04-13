IF DB_ID(N'TaskManagementDb') IS NULL
BEGIN
    CREATE DATABASE TaskManagementDb;
END;
GO

USE TaskManagementDb;
GO

IF OBJECT_ID(N'dbo.TaskComments', N'U') IS NOT NULL DROP TABLE dbo.TaskComments;
IF OBJECT_ID(N'dbo.ActivityLog', N'U') IS NOT NULL DROP TABLE dbo.ActivityLog;
IF OBJECT_ID(N'dbo.ProjectCollaborators', N'U') IS NOT NULL DROP TABLE dbo.ProjectCollaborators;
IF OBJECT_ID(N'dbo.Tasks', N'U') IS NOT NULL DROP TABLE dbo.Tasks;
IF OBJECT_ID(N'dbo.Projects', N'U') IS NOT NULL DROP TABLE dbo.Projects;
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID(N'dbo.Roles', N'U') IS NOT NULL DROP TABLE dbo.Roles;
IF OBJECT_ID(N'dbo.Genders', N'U') IS NOT NULL DROP TABLE dbo.Genders;
IF OBJECT_ID(N'dbo.MaritalStatuses', N'U') IS NOT NULL DROP TABLE dbo.MaritalStatuses;
GO

CREATE TABLE dbo.Roles
(
    RoleId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Roles_IsActive DEFAULT (1)
);
GO

CREATE TABLE dbo.Genders
(
    GenderId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Genders_IsActive DEFAULT (1)
);
GO

CREATE TABLE dbo.MaritalStatuses
(
    MaritalStatusId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_MaritalStatuses_IsActive DEFAULT (1)
);
GO

CREATE TABLE dbo.Users
(
    UserId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RoleId INT NOT NULL,
    GenderId INT NOT NULL,
    MaritalStatusId INT NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Identification NVARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    UserName NVARCHAR(50) NOT NULL,
    PasswordHash NVARCHAR(64) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT (1),
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT UQ_Users_Identification UNIQUE (Identification),
    CONSTRAINT UQ_Users_UserName UNIQUE (UserName),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId),
    CONSTRAINT FK_Users_Genders FOREIGN KEY (GenderId) REFERENCES dbo.Genders(GenderId),
    CONSTRAINT FK_Users_MaritalStatuses FOREIGN KEY (MaritalStatusId) REFERENCES dbo.MaritalStatuses(MaritalStatusId)
);
GO

CREATE TABLE dbo.Projects
(
    ProjectId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    ClientName NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500) NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    Status NVARCHAR(50) NOT NULL,
    Priority NVARCHAR(20) NOT NULL,
    CreatedByUserId INT NULL,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Projects_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT CK_Projects_Status CHECK (Status IN (N'Planificado', N'En ejecución', N'Bloqueado', N'Completado')),
    CONSTRAINT CK_Projects_Priority CHECK (Priority IN (N'Bajo', N'Medio', N'Alto')),
    CONSTRAINT FK_Projects_Users FOREIGN KEY (CreatedByUserId) REFERENCES dbo.Users(UserId)
);
GO

CREATE TABLE dbo.ProjectCollaborators
(
    ProjectId INT NOT NULL,
    UserId INT NOT NULL,
    AssignedAt DATETIME NOT NULL CONSTRAINT DF_ProjectCollaborators_AssignedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_ProjectCollaborators PRIMARY KEY (ProjectId, UserId),
    CONSTRAINT FK_ProjectCollaborators_Projects FOREIGN KEY (ProjectId) REFERENCES dbo.Projects(ProjectId),
    CONSTRAINT FK_ProjectCollaborators_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);
GO

CREATE TABLE dbo.Tasks
(
    TaskId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProjectId INT NOT NULL,
    AssignedUserId INT NULL,
    CreatedByUserId INT NULL,
    Name NVARCHAR(150) NOT NULL,
    Description NVARCHAR(1000) NULL,
    Status NVARCHAR(50) NOT NULL,
    Priority NVARCHAR(20) NOT NULL,
    StartDate DATE NOT NULL,
    Progress INT NOT NULL CONSTRAINT DF_Tasks_Progress DEFAULT (0),
    EstimatedHours DECIMAL(10,2) NULL,
    DueDate DATE NULL,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Tasks_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT CK_Tasks_Status CHECK (Status IN (N'Planificado', N'En ejecución', N'Bloqueado', N'Completado')),
    CONSTRAINT CK_Tasks_Priority CHECK (Priority IN (N'Bajo', N'Medio', N'Alto')),
    CONSTRAINT FK_Tasks_Projects FOREIGN KEY (ProjectId) REFERENCES dbo.Projects(ProjectId),
    CONSTRAINT FK_Tasks_AssignedUsers FOREIGN KEY (AssignedUserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Tasks_CreatedUsers FOREIGN KEY (CreatedByUserId) REFERENCES dbo.Users(UserId)
);
GO

CREATE TABLE dbo.TaskAttachments
(
    AttachmentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TaskId INT NOT NULL,
    FileName NVARCHAR(255) NOT NULL,
    FilePath NVARCHAR(500) NOT NULL,
    UploadedByUserId INT NULL,
    UploadedAt DATETIME NOT NULL CONSTRAINT DF_TaskAttachments_UploadedAt DEFAULT (GETDATE()),
    CONSTRAINT FK_TaskAttachments_Tasks FOREIGN KEY (TaskId) REFERENCES dbo.Tasks(TaskId),
    CONSTRAINT FK_TaskAttachments_Users FOREIGN KEY (UploadedByUserId) REFERENCES dbo.Users(UserId)
);
GO

CREATE TABLE dbo.TaskComments
(
    CommentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TaskId INT NOT NULL,
    UserId INT NOT NULL,
    CommentText NVARCHAR(1000) NOT NULL,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_TaskComments_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT FK_TaskComments_Tasks FOREIGN KEY (TaskId) REFERENCES dbo.Tasks(TaskId),
    CONSTRAINT FK_TaskComments_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);
GO

CREATE TABLE dbo.ActivityLog
(
    ActivityId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EntityType NVARCHAR(40) NOT NULL,
    ActivityType NVARCHAR(40) NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    RelatedProjectId INT NULL,
    RelatedTaskId INT NULL,
    PerformedByUserId INT NULL,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_ActivityLog_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT FK_ActivityLog_Projects FOREIGN KEY (RelatedProjectId) REFERENCES dbo.Projects(ProjectId),
    CONSTRAINT FK_ActivityLog_Tasks FOREIGN KEY (RelatedTaskId) REFERENCES dbo.Tasks(TaskId),
    CONSTRAINT FK_ActivityLog_Users FOREIGN KEY (PerformedByUserId) REFERENCES dbo.Users(UserId)
);
GO

INSERT INTO dbo.Roles (Name) VALUES (N'Administrador'), (N'Lider de Proyecto'), (N'Colaborador');
INSERT INTO dbo.Genders (Name) VALUES (N'Masculino'), (N'Femenino'), (N'Otro');
INSERT INTO dbo.MaritalStatuses (Name) VALUES (N'Soltero'), (N'Casado'), (N'Divorciado'), (N'Viudo');
GO

INSERT INTO dbo.Users
(
    RoleId,
    GenderId,
    MaritalStatusId,
    FirstName,
    LastName,
    Identification,
    BirthDate,
    UserName,
    PasswordHash
)
VALUES
(
    1,
    1,
    1,
    N'Administrador',
    N'General',
    N'000000000',
    '1990-01-01',
    N'admin',
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Admin123*'), 2)
);
GO
