CREATE OR ALTER PROCEDURE [dbo].[ListarCategorias]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.Id, c.Nombre, c.Descripcion, c.Activa,
           (SELECT COUNT(*) FROM [dbo].[Productos] p WHERE p.IdCategoria = c.Id AND p.Activo = 1) AS ProductosActivos
    FROM [dbo].[Categorias] c
    ORDER BY c.Nombre;
END
