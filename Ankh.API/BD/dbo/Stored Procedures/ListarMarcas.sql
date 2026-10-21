CREATE PROCEDURE [dbo].[ListarMarcas]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Nombre, Activa FROM [dbo].[Marcas] ORDER BY Nombre;
END
