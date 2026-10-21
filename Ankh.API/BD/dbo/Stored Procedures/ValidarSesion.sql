-- RF-02: valida la sesion; si @Refrescar = 1 reinicia el contador de inactividad.
-- Devuelve los segundos que le quedan (0 = sesion invalida o expirada).
CREATE PROCEDURE [dbo].[ValidarSesion]
@IdSesion  UNIQUEIDENTIFIER,
@Refrescar BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Inactividad INT = [dbo].[fn_Config]('MinutosInactividad');
    DECLARE @Aviso INT = [dbo].[fn_Config]('SegundosAvisoSesion');

    UPDATE [dbo].[Sesiones]
    SET Activa = 0, MotivoCierre = 'Inactividad'
    WHERE Id = @IdSesion AND Activa = 1
      AND DATEADD(MINUTE, @Inactividad, UltimaActividad) < GETDATE();

    IF @Refrescar = 1
        UPDATE s SET UltimaActividad = GETDATE()
        FROM [dbo].[Sesiones] s
        INNER JOIN [dbo].[Usuarios] u ON u.Id = s.IdUsuario
        WHERE s.Id = @IdSesion AND s.Activa = 1 AND u.Activo = 1;

    SELECT ISNULL(MAX(CASE WHEN s.Activa = 1 AND u.Activo = 1
                           THEN DATEDIFF(SECOND, GETDATE(), DATEADD(MINUTE, @Inactividad, s.UltimaActividad))
                           ELSE 0 END), 0) AS SegundosRestantes,
           @Aviso AS SegundosAviso
    FROM [dbo].[Sesiones] s
    INNER JOIN [dbo].[Usuarios] u ON u.Id = s.IdUsuario
    WHERE s.Id = @IdSesion;
END
