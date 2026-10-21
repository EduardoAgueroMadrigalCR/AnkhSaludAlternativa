CREATE PROCEDURE [dbo].[ObtenerProductoPorId]
@Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Id, p.CodigoProducto, p.Nombre, p.Descripcion, p.ImagenUrl, p.Precio, p.Stock, p.Descontinuado,
           p.IdMarca, m.Nombre AS Marca, p.IdCategoria, c.Nombre AS Categoria,
           p.FechaCreacion, p.FechaModificacion
    FROM [dbo].[Productos] p
    INNER JOIN [dbo].[Marcas] m ON m.Id = p.IdMarca
    INNER JOIN [dbo].[Categorias] c ON c.Id = p.IdCategoria
    WHERE p.Id = @Id;
END
