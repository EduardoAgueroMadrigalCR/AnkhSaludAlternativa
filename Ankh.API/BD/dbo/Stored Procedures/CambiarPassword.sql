-- RF-03: guarda el nuevo hash y cierra las demas sesiones del usuario
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
