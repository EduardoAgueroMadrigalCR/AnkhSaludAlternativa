CREATE PROCEDURE [dbo].[ListarCategorias]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Nombre, Activa FROM [dbo].[Categorias] ORDER BY Nombre;
END
