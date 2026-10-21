-- RF-01 / RF-02: reinicia intentos y abre una sesion
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
