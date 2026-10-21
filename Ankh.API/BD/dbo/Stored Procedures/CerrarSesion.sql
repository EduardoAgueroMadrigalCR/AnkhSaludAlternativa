CREATE PROCEDURE [dbo].[CerrarSesion]
@IdSesion UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[Sesiones] SET Activa = 0, MotivoCierre = 'Manual'
    WHERE Id = @IdSesion AND Activa = 1;
END
