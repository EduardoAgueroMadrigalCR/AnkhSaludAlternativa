CREATE PROCEDURE [dbo].[ObtenerUsuarioLogin]
@CorreoElectronico VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.Id, u.Nombre, u.CorreoElectronico, u.PasswordHash, u.IdRol, r.Nombre AS Rol, u.Activo, u.DebeCambiarPassword, u.UltimoLogin, u.BloqueadoHasta,
           CAST(CASE WHEN u.BloqueadoHasta IS NOT NULL AND u.BloqueadoHasta > GETDATE() THEN 1 ELSE 0 END AS BIT) AS Bloqueado
    FROM [dbo].[Usuarios] u
    INNER JOIN [dbo].[Roles] r ON r.Id = u.IdRol
    WHERE u.CorreoElectronico = @CorreoElectronico;
END
