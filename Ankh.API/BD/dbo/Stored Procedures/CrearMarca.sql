CREATE PROCEDURE [dbo].[CrearMarca]
@Nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    IF NULLIF(LTRIM(RTRIM(@Nombre)), '') IS NULL
        THROW 50070, N'El nombre de la marca es obligatorio', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Marcas] WHERE Nombre = @Nombre)
        THROW 50071, N'Esa marca ya existe', 1;

    DECLARE @Id UNIQUEIDENTIFIER = NEWID();
    INSERT INTO [dbo].[Marcas] (Id, Nombre) VALUES (@Id, @Nombre);
    SELECT @Id AS Id;
END
