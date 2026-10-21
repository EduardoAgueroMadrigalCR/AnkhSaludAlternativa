-- RF-10 escenario 2: no se elimina si tiene productos asociados
CREATE PROCEDURE [dbo].[EliminarMarca]
@Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Marcas] WHERE Id = @Id)
        THROW 50072, N'La marca no existe', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE IdMarca = @Id)
        THROW 50073, N'No se puede eliminar la marca porque tiene productos asociados. Reasigne los productos a otra marca', 1;

    DELETE FROM [dbo].[Marcas] WHERE Id = @Id;
END
