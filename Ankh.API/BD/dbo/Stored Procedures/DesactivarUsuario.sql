-- RF-08
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

        -- impide cualquier acceso posterior
        UPDATE [dbo].[Sesiones] SET Activa = 0, MotivoCierre = 'Desactivacion'
        WHERE IdUsuario = @IdUsuario AND Activa = 1;

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdAdmin, 'DESACTIVAR_USUARIO', CAST(@IdUsuario AS VARCHAR(36)));
    COMMIT TRAN
END
