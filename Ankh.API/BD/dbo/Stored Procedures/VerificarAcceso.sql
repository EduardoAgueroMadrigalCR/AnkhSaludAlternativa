-- RF-06: 1 si el rol del usuario tiene acceso al modulo
CREATE PROCEDURE [dbo].[VerificarAcceso]
@IdUsuario UNIQUEIDENTIFIER,
@Modulo    VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(CASE WHEN EXISTS (
        SELECT 1
        FROM [dbo].[Usuarios] u
        INNER JOIN [dbo].[RolesxModulo] rm ON rm.IdRol = u.IdRol
        INNER JOIN [dbo].[Modulos] m ON m.Id = rm.IdModulo
        WHERE u.Id = @IdUsuario AND u.Activo = 1 AND m.Nombre = @Modulo)
        THEN 1 ELSE 0 END AS BIT) AS TieneAcceso;
END
