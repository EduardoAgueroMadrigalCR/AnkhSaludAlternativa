CREATE OR ALTER PROCEDURE [dbo].[ObtenerCategoriaPorId]
@Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.Id, c.Nombre, c.Descripcion, c.Activa,
           (SELECT COUNT(*) FROM [dbo].[Productos] p WHERE p.IdCategoria = c.Id AND p.Activo = 1) AS ProductosActivos
    FROM [dbo].[Categorias] c
    WHERE c.Id = @Id;
END
