IF DB_ID('MacrobioticaDB') IS NULL CREATE DATABASE MacrobioticaDB;
GO
USE MacrobioticaDB;
GO
IF OBJECT_ID('dbo.Usuarios', 'U') IS NOT NULL
BEGIN
    PRINT 'AnkhDB ya tiene las tablas creadas. No se ejecuto nada.';
    SET NOEXEC ON;
END
GO

CREATE TABLE [dbo].[Roles] (
    [Id]          INT          NOT NULL,
    [Nombre]      VARCHAR(50)  NOT NULL,
    [Descripcion] VARCHAR(200) NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_Roles_Nombre] UNIQUE ([Nombre])
);

GO

CREATE TABLE [dbo].[Modulos] (
    [Id]     INT IDENTITY(1,1) NOT NULL,
    [Nombre] VARCHAR(50)       NOT NULL,
    CONSTRAINT [PK_Modulos] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_Modulos_Nombre] UNIQUE ([Nombre])
);

GO

CREATE TABLE [dbo].[RolesxModulo] (
    [IdRol]    INT NOT NULL,
    [IdModulo] INT NOT NULL,
    CONSTRAINT [PK_RolesxModulo] PRIMARY KEY CLUSTERED ([IdRol] ASC, [IdModulo] ASC),
    CONSTRAINT [FK_RolesxModulo_Roles]   FOREIGN KEY ([IdRol])    REFERENCES [dbo].[Roles] ([Id]),
    CONSTRAINT [FK_RolesxModulo_Modulos] FOREIGN KEY ([IdModulo]) REFERENCES [dbo].[Modulos] ([Id])
);

GO

CREATE TABLE [dbo].[Usuarios] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Nombre]             VARCHAR(100)     NOT NULL,
    [CorreoElectronico]  VARCHAR(150)     NOT NULL,
    [PasswordHash]       VARCHAR(255)     NOT NULL,
    [IdRol]              INT              NOT NULL,
    [Activo]             BIT              NOT NULL CONSTRAINT [DF_Usuarios_Activo] DEFAULT (1),
    [DebeCambiarPassword] BIT             NOT NULL CONSTRAINT [DF_Usuarios_DebeCambiar] DEFAULT (0),
    [IntentosFallidos]   INT              NOT NULL CONSTRAINT [DF_Usuarios_Intentos] DEFAULT (0),
    [BloqueadoHasta]     DATETIME         NULL,
    [UltimoLogin]        DATETIME         NULL,
    [FechaDesactivacion] DATETIME         NULL,
    [FechaCreacion]      DATETIME         NULL CONSTRAINT [DF_Usuarios_FechaCreacion] DEFAULT (GETDATE()),
    [FechaModificacion]  DATETIME         NULL,
    [UsuarioCrea]        UNIQUEIDENTIFIER NULL,
    [UsuarioModifica]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Usuarios] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Usuarios_Roles] FOREIGN KEY ([IdRol]) REFERENCES [dbo].[Roles] ([Id]),
    CONSTRAINT [UQ_Usuarios_Correo] UNIQUE ([CorreoElectronico])
);

GO

CREATE TABLE [dbo].[Sesiones] (
    [Id]              UNIQUEIDENTIFIER NOT NULL,
    [IdUsuario]       UNIQUEIDENTIFIER NOT NULL,
    [FechaInicio]     DATETIME         NOT NULL CONSTRAINT [DF_Sesiones_Inicio] DEFAULT (GETDATE()),
    [UltimaActividad] DATETIME         NOT NULL CONSTRAINT [DF_Sesiones_Actividad] DEFAULT (GETDATE()),
    [Activa]          BIT              NOT NULL CONSTRAINT [DF_Sesiones_Activa] DEFAULT (1),
    [MotivoCierre]    VARCHAR(30)      NULL,
    CONSTRAINT [PK_Sesiones] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Sesiones_Usuarios] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[Usuarios] ([Id])
);

GO

CREATE TABLE [dbo].[TokensRecuperacion] (
    [Id]              UNIQUEIDENTIFIER NOT NULL,
    [IdUsuario]       UNIQUEIDENTIFIER NOT NULL,
    [TokenHash]       CHAR(64)         NOT NULL,
    [FechaCreacion]   DATETIME         NOT NULL CONSTRAINT [DF_TokensRec_Creacion] DEFAULT (GETDATE()),
    [FechaExpiracion] DATETIME         NOT NULL,
    [Usado]           BIT              NOT NULL CONSTRAINT [DF_TokensRec_Usado] DEFAULT (0),
    CONSTRAINT [PK_TokensRecuperacion] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TokensRecuperacion_Usuarios] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[Usuarios] ([Id])
);
GO
CREATE INDEX [IX_TokensRecuperacion_Hash] ON [dbo].[TokensRecuperacion] ([TokenHash]);

GO

CREATE TABLE [dbo].[Configuracion] (
    [Clave]       VARCHAR(50)  NOT NULL,
    [Valor]       INT          NOT NULL,
    [Descripcion] VARCHAR(200) NULL,
    CONSTRAINT [PK_Configuracion] PRIMARY KEY CLUSTERED ([Clave] ASC)
);

GO

CREATE TABLE [dbo].[Bitacora] (
    [Id]        BIGINT IDENTITY(1,1) NOT NULL,
    [IdUsuario] UNIQUEIDENTIFIER     NULL,
    [Accion]    VARCHAR(50)          NOT NULL,
    [Detalle]   VARCHAR(300)         NULL,
    [Fecha]     DATETIME             NOT NULL CONSTRAINT [DF_Bitacora_Fecha] DEFAULT (GETDATE()),
    CONSTRAINT [PK_Bitacora] PRIMARY KEY CLUSTERED ([Id] ASC)
);

GO

CREATE FUNCTION [dbo].[fn_Config] (@Clave VARCHAR(50))
RETURNS INT
AS
BEGIN
    RETURN (SELECT [Valor] FROM [dbo].[Configuracion] WHERE [Clave] = @Clave);
END

GO

CREATE PROCEDURE [dbo].[ActualizarPerfil]
@IdUsuario         UNIQUEIDENTIFIER,
@Nombre            VARCHAR(100),
@CorreoElectronico VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuarios] WHERE Id = @IdUsuario AND Activo = 1)
        THROW 50054, N'El usuario no existe', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Usuarios] WHERE CorreoElectronico = @CorreoElectronico AND Id <> @IdUsuario)
        THROW 50053, N'El correo ya está en uso', 1;

    BEGIN TRAN
        UPDATE [dbo].[Usuarios]
        SET Nombre = @Nombre, CorreoElectronico = @CorreoElectronico,
            FechaModificacion = GETDATE(), UsuarioModifica = @IdUsuario
        WHERE Id = @IdUsuario;

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion) VALUES (@IdUsuario, 'ACTUALIZAR_PERFIL');
    COMMIT TRAN
END

GO

CREATE PROCEDURE [dbo].[CambiarPassword]
@IdUsuario      UNIQUEIDENTIFIER,
@NuevoHash      VARCHAR(255),
@IdSesionActual UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRAN
        UPDATE [dbo].[Usuarios]
        SET PasswordHash = @NuevoHash, DebeCambiarPassword = 0,
            FechaModificacion = GETDATE(), UsuarioModifica = @IdUsuario
        WHERE Id = @IdUsuario;

        UPDATE [dbo].[Sesiones] SET Activa = 0, MotivoCierre = 'CambioPassword'
        WHERE IdUsuario = @IdUsuario AND Activa = 1
          AND (@IdSesionActual IS NULL OR Id <> @IdSesionActual);

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion) VALUES (@IdUsuario, 'CAMBIO_PASSWORD');
    COMMIT TRAN
END

GO

CREATE PROCEDURE [dbo].[CambiarRol]
@IdUsuario UNIQUEIDENTIFIER,
@IdRol     INT,
@IdAdmin   UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @RolActual INT = (SELECT IdRol FROM [dbo].[Usuarios] WHERE Id = @IdUsuario);

    IF @RolActual IS NULL
        THROW 50054, N'El usuario no existe', 1;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Roles] WHERE Id = @IdRol)
        THROW 50052, N'El rol seleccionado no existe', 1;

    IF @RolActual = 1 AND @IdRol <> 1
       AND (SELECT COUNT(*) FROM [dbo].[Usuarios] WHERE IdRol = 1 AND Activo = 1) <= 1
        THROW 50061, N'Debe existir al menos un administrador activo', 1;

    BEGIN TRAN
        UPDATE [dbo].[Usuarios]
        SET IdRol = @IdRol, FechaModificacion = GETDATE(), UsuarioModifica = @IdAdmin
        WHERE Id = @IdUsuario;

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdAdmin, 'CAMBIAR_ROL', CONCAT(CAST(@IdUsuario AS VARCHAR(36)), ' -> rol ', @IdRol));
    COMMIT TRAN
END

GO

CREATE PROCEDURE [dbo].[CerrarSesion]
@IdSesion UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[Sesiones] SET Activa = 0, MotivoCierre = 'Manual'
    WHERE Id = @IdSesion AND Activa = 1;
END

GO

CREATE PROCEDURE [dbo].[CrearUsuario]
@Nombre            VARCHAR(100),
@CorreoElectronico VARCHAR(150),
@PasswordHash      VARCHAR(255),
@IdRol             INT,
@IdAdmin           UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NULLIF(LTRIM(RTRIM(@Nombre)), '') IS NULL OR NULLIF(LTRIM(RTRIM(@CorreoElectronico)), '') IS NULL
        THROW 50050, N'Faltan campos obligatorios', 1;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Roles] WHERE Id = @IdRol)
        THROW 50052, N'El rol seleccionado no existe', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Usuarios] WHERE CorreoElectronico = @CorreoElectronico)
        THROW 50053, N'El correo ya está en uso', 1;

    DECLARE @Id UNIQUEIDENTIFIER = NEWID();
    BEGIN TRAN
        INSERT INTO [dbo].[Usuarios] (Id, Nombre, CorreoElectronico, PasswordHash, IdRol, DebeCambiarPassword, UsuarioCrea)
        VALUES (@Id, @Nombre, @CorreoElectronico, @PasswordHash, @IdRol, 1, @IdAdmin);

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdAdmin, 'CREAR_USUARIO', @CorreoElectronico);
    COMMIT TRAN

    SELECT @Id;
END

GO

CREATE PROCEDURE [dbo].[DesactivarUsuario]
@IdUsuario UNIQUEIDENTIFIER,
@IdAdmin   UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuarios] WHERE Id = @IdUsuario)
        THROW 50054, N'El usuario no existe', 1;
    IF @IdUsuario = @IdAdmin
        THROW 50062, N'No puede desactivar su propia cuenta', 1;

    BEGIN TRAN
        UPDATE [dbo].[Usuarios]
        SET Activo = 0, FechaDesactivacion = GETDATE(), FechaModificacion = GETDATE(), UsuarioModifica = @IdAdmin
        WHERE Id = @IdUsuario;


        UPDATE [dbo].[Sesiones] SET Activa = 0, MotivoCierre = 'Desactivacion'
        WHERE IdUsuario = @IdUsuario AND Activa = 1;

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdAdmin, 'DESACTIVAR_USUARIO', CAST(@IdUsuario AS VARCHAR(36)));
    COMMIT TRAN
END

GO

CREATE PROCEDURE [dbo].[ListarRoles]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Nombre, Descripcion FROM [dbo].[Roles] ORDER BY Id;
END

GO

CREATE PROCEDURE [dbo].[ListarUsuarios]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.Id, u.Nombre, u.CorreoElectronico, u.IdRol, r.Nombre AS Rol, u.Activo,
           u.DebeCambiarPassword, u.UltimoLogin, u.BloqueadoHasta
    FROM [dbo].[Usuarios] u
    INNER JOIN [dbo].[Roles] r ON r.Id = u.IdRol
    ORDER BY u.Nombre;
END

GO

CREATE PROCEDURE [dbo].[ObtenerModulosxUsuario]
@IdUsuario UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.Nombre
    FROM [dbo].[Usuarios] u
    INNER JOIN [dbo].[RolesxModulo] rm ON rm.IdRol = u.IdRol
    INNER JOIN [dbo].[Modulos] m ON m.Id = rm.IdModulo
    WHERE u.Id = @IdUsuario AND u.Activo = 1
    ORDER BY m.Nombre;
END

GO

CREATE PROCEDURE [dbo].[ObtenerUsuarioLogin]
@CorreoElectronico VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.Id, u.Nombre, u.CorreoElectronico, u.PasswordHash, u.IdRol, r.Nombre AS Rol, u.Activo, u.DebeCambiarPassword, u.UltimoLogin, u.BloqueadoHasta,
           CAST(CASE WHEN u.BloqueadoHasta IS NOT NULL AND u.BloqueadoHasta > GETDATE() THEN 1 ELSE 0 END AS BIT) AS Bloqueado
    FROM [dbo].[Usuarios] u
    INNER JOIN [dbo].[Roles] r ON r.Id = u.IdRol
    WHERE u.CorreoElectronico = @CorreoElectronico;
END

GO

CREATE PROCEDURE [dbo].[ObtenerUsuarioPorId]
@Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.Id, u.Nombre, u.CorreoElectronico, u.PasswordHash, u.IdRol, r.Nombre AS Rol, u.Activo, u.DebeCambiarPassword, u.UltimoLogin, u.BloqueadoHasta,
           CAST(CASE WHEN u.BloqueadoHasta IS NOT NULL AND u.BloqueadoHasta > GETDATE() THEN 1 ELSE 0 END AS BIT) AS Bloqueado
    FROM [dbo].[Usuarios] u
    INNER JOIN [dbo].[Roles] r ON r.Id = u.IdRol
    WHERE u.Id = @Id;
END

GO

CREATE PROCEDURE [dbo].[ReactivarUsuario]
@IdUsuario UNIQUEIDENTIFIER,
@IdAdmin   UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuarios] WHERE Id = @IdUsuario)
        THROW 50054, N'El usuario no existe', 1;

    BEGIN TRAN
        UPDATE [dbo].[Usuarios]
        SET Activo = 1, FechaDesactivacion = NULL, IntentosFallidos = 0, BloqueadoHasta = NULL,
            FechaModificacion = GETDATE(), UsuarioModifica = @IdAdmin
        WHERE Id = @IdUsuario;

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdAdmin, 'REACTIVAR_USUARIO', CAST(@IdUsuario AS VARCHAR(36)));
    COMMIT TRAN
END

GO

CREATE PROCEDURE [dbo].[RegistrarIntentoFallido]
@CorreoElectronico VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Max INT = [dbo].[fn_Config]('MaxIntentosFallidos');
    DECLARE @Minutos INT = [dbo].[fn_Config]('MinutosBloqueo');
    DECLARE @Id UNIQUEIDENTIFIER = (SELECT Id FROM [dbo].[Usuarios] WHERE CorreoElectronico = @CorreoElectronico AND Activo = 1);

    IF @Id IS NOT NULL
    BEGIN
        UPDATE [dbo].[Usuarios] SET IntentosFallidos = IntentosFallidos + 1 WHERE Id = @Id;

        IF (SELECT IntentosFallidos FROM [dbo].[Usuarios] WHERE Id = @Id) >= @Max
            UPDATE [dbo].[Usuarios]
            SET BloqueadoHasta = DATEADD(MINUTE, @Minutos, GETDATE()), IntentosFallidos = 0
            WHERE Id = @Id;

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle) VALUES (@Id, 'LOGIN_FALLIDO', NULL);
    END

    SELECT CAST(CASE WHEN EXISTS (SELECT 1 FROM [dbo].[Usuarios] WHERE Id = @Id AND BloqueadoHasta > GETDATE())
                     THEN 1 ELSE 0 END AS BIT) AS Bloqueado;
END

GO

CREATE PROCEDURE [dbo].[RegistrarLoginExitoso]
@IdUsuario UNIQUEIDENTIFIER,
@IdSesion  UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRAN
        UPDATE [dbo].[Usuarios]
        SET IntentosFallidos = 0, BloqueadoHasta = NULL, UltimoLogin = GETDATE()
        WHERE Id = @IdUsuario;

        INSERT INTO [dbo].[Sesiones] (Id, IdUsuario) VALUES (@IdSesion, @IdUsuario);
        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion) VALUES (@IdUsuario, 'LOGIN_EXITOSO');
    COMMIT TRAN
END

GO

CREATE PROCEDURE [dbo].[RestablecerPassword]
@TokenHash CHAR(64),
@NuevoHash VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @IdToken UNIQUEIDENTIFIER, @IdUsuario UNIQUEIDENTIFIER;

    SELECT TOP 1 @IdToken = Id, @IdUsuario = IdUsuario
    FROM [dbo].[TokensRecuperacion]
    WHERE TokenHash = @TokenHash AND Usado = 0 AND FechaExpiracion > GETDATE();

    IF @IdToken IS NULL
        THROW 50041, N'El enlace expiró o no es válido. Solicite uno nuevo', 1;

    BEGIN TRAN
        UPDATE [dbo].[Usuarios]
        SET PasswordHash = @NuevoHash, DebeCambiarPassword = 0, IntentosFallidos = 0, BloqueadoHasta = NULL,
            FechaModificacion = GETDATE()
        WHERE Id = @IdUsuario;

        UPDATE [dbo].[TokensRecuperacion] SET Usado = 1 WHERE Id = @IdToken;

        UPDATE [dbo].[Sesiones] SET Activa = 0, MotivoCierre = 'CambioPassword'
        WHERE IdUsuario = @IdUsuario AND Activa = 1;

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion) VALUES (@IdUsuario, 'RESET_PASSWORD');
    COMMIT TRAN
END

GO

CREATE PROCEDURE [dbo].[SolicitarRecuperacion]
@CorreoElectronico VARCHAR(150),
@TokenHash         CHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Minutos INT = [dbo].[fn_Config]('MinutosTokenRecuperacion');
    DECLARE @Id UNIQUEIDENTIFIER = (SELECT Id FROM [dbo].[Usuarios] WHERE CorreoElectronico = @CorreoElectronico AND Activo = 1);

    IF @Id IS NULL
        THROW 50040, N'No existe una cuenta asociada a este correo', 1;

    BEGIN TRAN
        UPDATE [dbo].[TokensRecuperacion] SET Usado = 1 WHERE IdUsuario = @Id AND Usado = 0;

        INSERT INTO [dbo].[TokensRecuperacion] (Id, IdUsuario, TokenHash, FechaExpiracion)
        VALUES (NEWID(), @Id, @TokenHash, DATEADD(MINUTE, @Minutos, GETDATE()));

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion) VALUES (@Id, 'SOLICITUD_RECUPERACION');
    COMMIT TRAN

    SELECT Id, Nombre, CorreoElectronico, @Minutos AS MinutosVigencia
    FROM [dbo].[Usuarios] WHERE Id = @Id;
END

GO

CREATE PROCEDURE [dbo].[ValidarSesion]
@IdSesion  UNIQUEIDENTIFIER,
@Refrescar BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Inactividad INT = [dbo].[fn_Config]('MinutosInactividad');
    DECLARE @Aviso INT = [dbo].[fn_Config]('SegundosAvisoSesion');

    UPDATE [dbo].[Sesiones]
    SET Activa = 0, MotivoCierre = 'Inactividad'
    WHERE Id = @IdSesion AND Activa = 1
      AND DATEADD(MINUTE, @Inactividad, UltimaActividad) < GETDATE();

    IF @Refrescar = 1
        UPDATE s SET UltimaActividad = GETDATE()
        FROM [dbo].[Sesiones] s
        INNER JOIN [dbo].[Usuarios] u ON u.Id = s.IdUsuario
        WHERE s.Id = @IdSesion AND s.Activa = 1 AND u.Activo = 1;

    SELECT ISNULL(MAX(CASE WHEN s.Activa = 1 AND u.Activo = 1
                           THEN DATEDIFF(SECOND, GETDATE(), DATEADD(MINUTE, @Inactividad, s.UltimaActividad))
                           ELSE 0 END), 0) AS SegundosRestantes,
           @Aviso AS SegundosAviso
    FROM [dbo].[Sesiones] s
    INNER JOIN [dbo].[Usuarios] u ON u.Id = s.IdUsuario
    WHERE s.Id = @IdSesion;
END

GO

CREATE PROCEDURE [dbo].[VerificarAcceso]
@IdUsuario UNIQUEIDENTIFIER,
@Modulo    VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(CASE WHEN EXISTS (
        SELECT 1
        FROM [dbo].[Usuarios] u
        INNER JOIN [dbo].[RolesxModulo] rm ON rm.IdRol = u.IdRol
        INNER JOIN [dbo].[Modulos] m ON m.Id = rm.IdModulo
        WHERE u.Id = @IdUsuario AND u.Activo = 1 AND m.Nombre = @Modulo)
        THEN 1 ELSE 0 END AS BIT) AS TieneAcceso;
END

GO

INSERT INTO [dbo].[Configuracion] (Clave, Valor, Descripcion) VALUES
 ('MaxIntentosFallidos',      3,  'Intentos fallidos antes de bloquear la cuenta (RF-01)'),
 ('MinutosBloqueo',           15, 'Minutos de bloqueo de la cuenta (RF-01)'),
 ('MinutosInactividad',       10, 'Minutos de inactividad para cerrar la sesion (RF-02)'),
 ('SegundosAvisoSesion',      30, 'Segundos de aviso antes de cerrar la sesion (RF-02)'),
 ('MinutosTokenRecuperacion', 30, 'Vigencia del enlace de recuperacion (RF-04)');

INSERT INTO [dbo].[Roles] (Id, Nombre, Descripcion) VALUES
 (1, 'Administrador',           'Duena del negocio, acceso total'),
 (2, 'Vendedor',                'Consulta productos y registra ventas'),
 (3, 'Encargado de Inventario', 'Gestiona productos e inventario');

INSERT INTO [dbo].[Modulos] (Nombre) VALUES ('Usuarios'), ('Productos'), ('Inventario'), ('Ventas'), ('Reportes');

INSERT INTO [dbo].[RolesxModulo] (IdRol, IdModulo) SELECT 1, Id FROM [dbo].[Modulos];
INSERT INTO [dbo].[RolesxModulo] (IdRol, IdModulo) SELECT 2, Id FROM [dbo].[Modulos] WHERE Nombre IN ('Productos', 'Ventas');

INSERT INTO [dbo].[Usuarios] (Id, Nombre, CorreoElectronico, PasswordHash, IdRol, DebeCambiarPassword)
VALUES (NEWID(), 'Marina Madrigal Diaz', 'marina0759@hotmail.com',
        '$2b$11$AsIrYzl1I4ldFEASFLqL1Ou4qTAW5T2tONq6C.wSa7naHnolFz0Li', 1, 1);

GO
SET NOEXEC OFF;
GO
PRINT 'AnkhDB lista.';
