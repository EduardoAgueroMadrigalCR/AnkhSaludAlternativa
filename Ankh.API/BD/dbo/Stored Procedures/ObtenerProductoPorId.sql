CREATE OR ALTER PROCEDURE [dbo].[ObtenerProductoPorId]
@Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Id, p.Nombre, p.Descripcion, p.Detalles, p.IdCategoria, c.Nombre AS Categoria,
           p.Precio, p.Imagen, p.Activo
    FROM [dbo].[Productos] p
    INNER JOIN [dbo].[Categorias] c ON c.Id = p.IdCategoria
    WHERE p.Id = @Id;
END
