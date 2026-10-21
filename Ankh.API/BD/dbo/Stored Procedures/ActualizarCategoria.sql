CREATE PROCEDURE [dbo].[ActualizarCategoria]
@Id     UNIQUEIDENTIFIER,
@Nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Categorias] WHERE Id = @Id)
        THROW 50075, N'La categoría no existe', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Categorias] WHERE Nombre = @Nombre AND Id <> @Id)
        THROW 50074, N'Esa categoría ya existe', 1;

    UPDATE [dbo].[Categorias] SET Nombre = @Nombre WHERE Id = @Id;
END
