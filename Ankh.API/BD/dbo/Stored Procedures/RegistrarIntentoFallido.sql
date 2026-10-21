-- RF-01: cuenta un intento fallido y bloquea la cuenta al llegar al maximo configurado
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
