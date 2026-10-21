-- RF-10 escenario 2: no se elimina si tiene productos asociados
CREATE PROCEDURE [dbo].[EliminarCategoria]
@Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Categorias] WHERE Id = @Id)
        THROW 50075, N'La categoría no existe', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE IdCategoria = @Id)
        THROW 50076, N'No se puede eliminar la categoría porque tiene productos asociados. Reasigne los productos a otra categoría', 1;

    DELETE FROM [dbo].[Categorias] WHERE Id = @Id;
END
