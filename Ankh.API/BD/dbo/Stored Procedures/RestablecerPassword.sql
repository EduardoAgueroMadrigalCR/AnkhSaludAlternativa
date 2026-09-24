-- RF-04: valida el token (vigente y sin usar) y cambia la contrasena
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
