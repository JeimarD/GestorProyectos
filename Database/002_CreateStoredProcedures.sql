USE TaskManagementDb;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Role_List
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RoleId AS Id, Name
    FROM dbo.Roles
    WHERE IsActive = 1
    ORDER BY Name;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Gender_List
AS
BEGIN
    SET NOCOUNT ON;

    SELECT GenderId AS Id, Name
    FROM dbo.Genders
    WHERE IsActive = 1
    ORDER BY Name;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_MaritalStatus_List
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MaritalStatusId AS Id, Name
    FROM dbo.MaritalStatuses
    WHERE IsActive = 1
    ORDER BY Name;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_User_Login
    @UserName NVARCHAR(50),
    @PasswordHash NVARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        u.UserId,
        u.RoleId,
        r.Name AS RoleName,
        u.FirstName,
        u.LastName,
        u.UserName
    FROM dbo.Users u
    INNER JOIN dbo.Roles r ON r.RoleId = u.RoleId
    WHERE u.UserName = @UserName
      AND u.PasswordHash = @PasswordHash
      AND u.IsActive = 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_User_List
    @FirstName NVARCHAR(100) = NULL,
    @LastName NVARCHAR(100) = NULL,
    @Identification NVARCHAR(50) = NULL,
    @RoleId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.UserId,
        u.RoleId,
        r.Name AS RoleName,
        u.GenderId,
        g.Name AS GenderName,
        u.MaritalStatusId,
        m.Name AS MaritalStatusName,
        u.FirstName,
        u.LastName,
        u.Identification,
        u.BirthDate,
        u.UserName,
        u.IsActive
    FROM dbo.Users u
    INNER JOIN dbo.Roles r ON r.RoleId = u.RoleId
    INNER JOIN dbo.Genders g ON g.GenderId = u.GenderId
    INNER JOIN dbo.MaritalStatuses m ON m.MaritalStatusId = u.MaritalStatusId
    WHERE (@FirstName IS NULL OR u.FirstName LIKE '%' + @FirstName + '%')
      AND (@LastName IS NULL OR u.LastName LIKE '%' + @LastName + '%')
      AND (@Identification IS NULL OR u.Identification LIKE '%' + @Identification + '%')
      AND (@RoleId IS NULL OR u.RoleId = @RoleId)
    ORDER BY u.CreatedAt DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_User_Create
    @RoleId INT,
    @GenderId INT,
    @MaritalStatusId INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Identification NVARCHAR(50),
    @BirthDate DATE,
    @UserName NVARCHAR(50),
    @PasswordHash NVARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

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
        @RoleId,
        @GenderId,
        @MaritalStatusId,
        @FirstName,
        @LastName,
        @Identification,
        @BirthDate,
        @UserName,
        @PasswordHash
    );

    SELECT SCOPE_IDENTITY() AS NewId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_User_Update
    @UserId INT,
    @RoleId INT,
    @GenderId INT,
    @MaritalStatusId INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Identification NVARCHAR(50),
    @BirthDate DATE,
    @UserName NVARCHAR(50),
    @PasswordHash NVARCHAR(64) = NULL,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Users
    SET RoleId = @RoleId,
        GenderId = @GenderId,
        MaritalStatusId = @MaritalStatusId,
        FirstName = @FirstName,
        LastName = @LastName,
        Identification = @Identification,
        BirthDate = @BirthDate,
        UserName = @UserName,
        PasswordHash = ISNULL(@PasswordHash, PasswordHash),
        IsActive = @IsActive
    WHERE UserId = @UserId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_User_Delete
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Users
    SET IsActive = 0
    WHERE UserId = @UserId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Project_List
    @Name NVARCHAR(150) = NULL,
    @Status NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProjectId,
        p.Name,
        p.ClientName,
        p.Description,
        p.StartDate,
        p.EndDate,
        p.Status,
        p.Priority,
        CASE
            WHEN p.Status = N'Completado' THEN 100
            WHEN EXISTS (SELECT 1 FROM dbo.Tasks taskProgress WHERE taskProgress.ProjectId = p.ProjectId)
                THEN CONVERT(INT, ROUND((SELECT AVG(CAST(taskAverage.Progress AS DECIMAL(5,2))) FROM dbo.Tasks taskAverage WHERE taskAverage.ProjectId = p.ProjectId), 0))
            ELSE 0
        END AS Progress,
        p.CreatedByUserId,
        ISNULL(u.FirstName + ' ' + u.LastName, N'Sistema') AS CreatedByName
    FROM dbo.Projects p
    LEFT JOIN dbo.Users u ON u.UserId = p.CreatedByUserId
    WHERE (@Name IS NULL OR p.Name LIKE '%' + @Name + '%')
      AND (@Status IS NULL OR p.Status = @Status)
    ORDER BY p.CreatedAt DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Project_GetById
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        p.ProjectId,
        p.Name,
        p.ClientName,
        p.Description,
        p.StartDate,
        p.EndDate,
        p.Status,
        p.Priority,
        CASE
            WHEN p.Status = N'Completado' THEN 100
            WHEN EXISTS (SELECT 1 FROM dbo.Tasks taskProgress WHERE taskProgress.ProjectId = p.ProjectId)
                THEN CONVERT(INT, ROUND((SELECT AVG(CAST(taskAverage.Progress AS DECIMAL(5,2))) FROM dbo.Tasks taskAverage WHERE taskAverage.ProjectId = p.ProjectId), 0))
            ELSE 0
        END AS Progress,
        p.CreatedByUserId,
        ISNULL(u.FirstName + ' ' + u.LastName, N'Sistema') AS CreatedByName
    FROM dbo.Projects p
    LEFT JOIN dbo.Users u ON u.UserId = p.CreatedByUserId
    WHERE p.ProjectId = @ProjectId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Project_Create
    @Name NVARCHAR(150),
    @ClientName NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @StartDate DATE,
    @EndDate DATE = NULL,
    @Status NVARCHAR(50),
    @Priority NVARCHAR(20),
    @CreatedByUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Projects (Name, ClientName, Description, StartDate, EndDate, Status, Priority, CreatedByUserId)
    VALUES (@Name, @ClientName, @Description, @StartDate, @EndDate, @Status, @Priority, @CreatedByUserId);

    SELECT SCOPE_IDENTITY() AS NewId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Project_Update
    @ProjectId INT,
    @Name NVARCHAR(150),
    @ClientName NVARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @StartDate DATE,
    @EndDate DATE = NULL,
    @Status NVARCHAR(50),
    @Priority NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Projects
    SET Name = @Name,
        ClientName = @ClientName,
        Description = @Description,
        StartDate = @StartDate,
        EndDate = @EndDate,
        Status = @Status,
        Priority = @Priority
    WHERE ProjectId = @ProjectId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Project_Delete
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Tasks WHERE ProjectId = @ProjectId)
    BEGIN
        SELECT CAST(0 AS INT) AS AffectedRows;
        RETURN;
    END;

    IF OBJECT_ID(N'dbo.ActivityLog', N'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.ActivityLog
        WHERE RelatedProjectId = @ProjectId;
    END;

    IF OBJECT_ID(N'dbo.ProjectCollaborators', N'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.ProjectCollaborators
        WHERE ProjectId = @ProjectId;
    END;

    DELETE FROM dbo.Projects
    WHERE ProjectId = @ProjectId;

    SELECT @@ROWCOUNT AS AffectedRows;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Task_List
    @Name NVARCHAR(150) = NULL,
    @ProjectId INT = NULL,
    @AssignedUserId INT = NULL,
    @Status NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.TaskId,
        t.ProjectId,
        p.Name AS ProjectName,
        t.AssignedUserId,
        ISNULL(u.FirstName + ' ' + u.LastName, N'Sin asignar') AS AssignedUserName,
        t.CreatedByUserId,
        t.Name,
        t.Description,
        t.Status,
        t.Priority,
        t.StartDate,
        t.Progress,
        t.EstimatedHours,
        t.DueDate AS EstimatedEndDate,
        (SELECT COUNT(1) FROM dbo.TaskComments commentCounter WHERE commentCounter.TaskId = t.TaskId) AS CommentCount,
        (SELECT COUNT(1) FROM dbo.TaskAttachments attachmentCounter WHERE attachmentCounter.TaskId = t.TaskId) AS AttachmentCount,
        t.CreatedAt
    FROM dbo.Tasks t
    INNER JOIN dbo.Projects p ON p.ProjectId = t.ProjectId
    LEFT JOIN dbo.Users u ON u.UserId = t.AssignedUserId
    WHERE (@Name IS NULL OR t.Name LIKE '%' + @Name + '%')
      AND (@ProjectId IS NULL OR t.ProjectId = @ProjectId)
      AND (@AssignedUserId IS NULL OR t.AssignedUserId = @AssignedUserId)
      AND (@Status IS NULL OR t.Status = @Status)
    ORDER BY t.CreatedAt DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Task_GetById
    @TaskId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        t.TaskId,
        t.ProjectId,
        p.Name AS ProjectName,
        t.AssignedUserId,
        ISNULL(u.FirstName + ' ' + u.LastName, N'Sin asignar') AS AssignedUserName,
        t.CreatedByUserId,
        t.Name,
        t.Description,
        t.Status,
        t.Priority,
        t.StartDate,
        t.Progress,
        t.EstimatedHours,
        t.DueDate AS EstimatedEndDate,
        (SELECT COUNT(1) FROM dbo.TaskComments commentCounter WHERE commentCounter.TaskId = t.TaskId) AS CommentCount,
        (SELECT COUNT(1) FROM dbo.TaskAttachments attachmentCounter WHERE attachmentCounter.TaskId = t.TaskId) AS AttachmentCount,
        t.CreatedAt
    FROM dbo.Tasks t
    INNER JOIN dbo.Projects p ON p.ProjectId = t.ProjectId
    LEFT JOIN dbo.Users u ON u.UserId = t.AssignedUserId
    WHERE t.TaskId = @TaskId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_TaskAttachment_List
    @TaskId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AttachmentId,
        TaskId,
        FileName,
        FilePath,
        UploadedByUserId,
        UploadedAt
    FROM dbo.TaskAttachments
    WHERE TaskId = @TaskId
    ORDER BY UploadedAt DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_TaskAttachment_GetById
    @AttachmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        AttachmentId,
        TaskId,
        FileName,
        FilePath,
        UploadedByUserId,
        UploadedAt
    FROM dbo.TaskAttachments
    WHERE AttachmentId = @AttachmentId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_TaskAttachment_Create
    @TaskId INT,
    @FileName NVARCHAR(255),
    @FilePath NVARCHAR(500),
    @UploadedByUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.TaskAttachments
    (
        TaskId,
        FileName,
        FilePath,
        UploadedByUserId
    )
    VALUES
    (
        @TaskId,
        @FileName,
        @FilePath,
        @UploadedByUserId
    );

    SELECT SCOPE_IDENTITY() AS NewId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Task_Create
    @ProjectId INT,
    @AssignedUserId INT = NULL,
    @CreatedByUserId INT = NULL,
    @Name NVARCHAR(150),
    @Description NVARCHAR(1000) = NULL,
    @Status NVARCHAR(50),
    @Priority NVARCHAR(20),
    @StartDate DATE,
    @Progress INT,
    @EstimatedHours DECIMAL(10,2) = NULL,
    @EstimatedEndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

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
        @ProjectId,
        @AssignedUserId,
        @CreatedByUserId,
        @Name,
        @Description,
        @Status,
        @Priority,
        @StartDate,
        @Progress,
        @EstimatedHours,
        @EstimatedEndDate
    );

    SELECT SCOPE_IDENTITY() AS NewId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Task_Update
    @TaskId INT,
    @ProjectId INT,
    @AssignedUserId INT = NULL,
    @Name NVARCHAR(150),
    @Description NVARCHAR(1000) = NULL,
    @Status NVARCHAR(50),
    @Priority NVARCHAR(20),
    @StartDate DATE,
    @Progress INT,
    @EstimatedHours DECIMAL(10,2) = NULL,
    @EstimatedEndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Tasks
    SET ProjectId = @ProjectId,
        AssignedUserId = @AssignedUserId,
        Name = @Name,
        Description = @Description,
        Status = @Status,
        Priority = @Priority,
        StartDate = @StartDate,
        Progress = @Progress,
        EstimatedHours = @EstimatedHours,
        DueDate = @EstimatedEndDate
    WHERE TaskId = @TaskId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Task_Delete
    @TaskId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID(N'dbo.ActivityLog', N'U') IS NOT NULL
    BEGIN
        DELETE FROM dbo.ActivityLog
        WHERE RelatedTaskId = @TaskId;
    END;

    DELETE FROM dbo.TaskAttachments WHERE TaskId = @TaskId;
    DELETE FROM dbo.TaskComments WHERE TaskId = @TaskId;
    DELETE FROM dbo.Tasks WHERE TaskId = @TaskId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_TaskComment_List
    @TaskId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.CommentId,
        c.TaskId,
        c.UserId,
        u.FirstName + ' ' + u.LastName AS UserName,
        c.CommentText,
        c.CreatedAt
    FROM dbo.TaskComments c
    INNER JOIN dbo.Users u ON u.UserId = c.UserId
    WHERE c.TaskId = @TaskId
    ORDER BY c.CreatedAt DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_TaskComment_Create
    @TaskId INT,
    @UserId INT,
    @CommentText NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.TaskComments (TaskId, UserId, CommentText)
    VALUES (@TaskId, @UserId, @CommentText);

    SELECT SCOPE_IDENTITY() AS NewId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ActivityLog_Create
    @EntityType NVARCHAR(40),
    @ActivityType NVARCHAR(40),
    @Description NVARCHAR(500),
    @RelatedProjectId INT = NULL,
    @RelatedTaskId INT = NULL,
    @PerformedByUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ActivityLog
    (
        EntityType,
        ActivityType,
        Description,
        RelatedProjectId,
        RelatedTaskId,
        PerformedByUserId
    )
    VALUES
    (
        @EntityType,
        @ActivityType,
        @Description,
        @RelatedProjectId,
        @RelatedTaskId,
        @PerformedByUserId
    );
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ActivityLog_ListRecent
    @MaxRows INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@MaxRows)
        al.ActivityId,
        al.EntityType,
        al.ActivityType,
        al.Description,
        al.RelatedProjectId,
        al.RelatedTaskId,
        al.PerformedByUserId,
        ISNULL(u.FirstName + ' ' + u.LastName, N'Sistema') AS PerformedByName,
        al.CreatedAt
    FROM dbo.ActivityLog al
    LEFT JOIN dbo.Users u ON u.UserId = al.PerformedByUserId
    ORDER BY al.CreatedAt DESC;
END;
GO
