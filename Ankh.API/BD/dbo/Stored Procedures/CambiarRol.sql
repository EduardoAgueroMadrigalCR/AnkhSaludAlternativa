-- RF-06: los permisos se aplican de inmediato porque se leen del rol en cada validacion
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
    -- Id 1 = Administrador: siempre debe quedar al menos uno activo
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
