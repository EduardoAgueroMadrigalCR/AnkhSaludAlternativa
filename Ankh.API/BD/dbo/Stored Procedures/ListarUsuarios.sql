CREATE PROCEDURE [dbo].[ListarUsuarios]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.Id, u.Nombre, u.CorreoElectronico, u.IdRol, r.Nombre AS Rol, u.Activo,
           u.DebeCambiarPassword, u.UltimoLogin, u.BloqueadoHasta
    FROM [dbo].[Usuarios] u
    INNER JOIN [dbo].[Roles] r ON r.Id = u.IdRol
    ORDER BY u.Nombre;
END
