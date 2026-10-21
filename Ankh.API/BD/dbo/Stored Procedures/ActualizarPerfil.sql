-- RF-07
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
