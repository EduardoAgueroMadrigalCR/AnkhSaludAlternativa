CREATE PROCEDURE [dbo].[ObtenerModulosxUsuario]
@IdUsuario UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.Nombre
    FROM [dbo].[Usuarios] u
    INNER JOIN [dbo].[RolesxModulo] rm ON rm.IdRol = u.IdRol
    INNER JOIN [dbo].[Modulos] m ON m.Id = rm.IdModulo
    WHERE u.Id = @IdUsuario AND u.Activo = 1
    ORDER BY m.Nombre;
END
