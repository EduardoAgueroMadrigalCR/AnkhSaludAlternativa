-- RF-04: genera el registro del token (se guarda solo su hash)
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
