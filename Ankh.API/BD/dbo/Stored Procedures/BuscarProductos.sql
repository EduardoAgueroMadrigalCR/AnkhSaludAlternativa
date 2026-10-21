-- RF-11: combina texto libre + marca + categoria; @SoloActivos=1 oculta descontinuados (catalogo publico)
CREATE PROCEDURE [dbo].[BuscarProductos]
@Texto       VARCHAR(150)     = NULL,
@IdMarca     UNIQUEIDENTIFIER = NULL,
@IdCategoria UNIQUEIDENTIFIER = NULL,
@SoloActivos BIT              = 1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Id, p.CodigoProducto, p.Nombre, p.Descripcion, p.ImagenUrl, p.Precio, p.Stock, p.Descontinuado,
           p.IdMarca, m.Nombre AS Marca, p.IdCategoria, c.Nombre AS Categoria, p.FechaCreacion
    FROM [dbo].[Productos] p
    INNER JOIN [dbo].[Marcas] m ON m.Id = p.IdMarca
    INNER JOIN [dbo].[Categorias] c ON c.Id = p.IdCategoria
    WHERE (@SoloActivos = 0 OR p.Descontinuado = 0)
      AND (@Texto IS NULL OR p.Nombre LIKE '%' + @Texto + '%')
      AND (@IdMarca IS NULL OR p.IdMarca = @IdMarca)
      AND (@IdCategoria IS NULL OR p.IdCategoria = @IdCategoria)
    ORDER BY p.Nombre;
END
