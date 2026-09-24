-- RF-08 escenario 3: conserva rol e historial
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
