CREATE PROCEDURE [dbo].[ListarRoles]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Nombre, Descripcion FROM [dbo].[Roles] ORDER BY Id;
END
