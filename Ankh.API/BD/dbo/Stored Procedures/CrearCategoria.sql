CREATE PROCEDURE [dbo].[CrearCategoria]
@Nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    IF NULLIF(LTRIM(RTRIM(@Nombre)), '') IS NULL
        THROW 50070, N'El nombre de la categoría es obligatorio', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Categorias] WHERE Nombre = @Nombre)
        THROW 50074, N'Esa categoría ya existe', 1;

    DECLARE @Id UNIQUEIDENTIFIER = NEWID();
    INSERT INTO [dbo].[Categorias] (Id, Nombre) VALUES (@Id, @Nombre);
    SELECT @Id AS Id;
END
