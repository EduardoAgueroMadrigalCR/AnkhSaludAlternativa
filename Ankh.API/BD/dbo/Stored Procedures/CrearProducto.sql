-- RF-09
CREATE PROCEDURE [dbo].[CrearProducto]
@CodigoProducto VARCHAR(30),
@Nombre         VARCHAR(150),
@Descripcion    VARCHAR(500) = NULL,
@IdMarca        UNIQUEIDENTIFIER,
@IdCategoria    UNIQUEIDENTIFIER,
@Precio         DECIMAL(10,2),
@Stock          INT,
@IdUsuario      UNIQUEIDENTIFIER,
@ImagenUrl      VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NULLIF(LTRIM(RTRIM(@CodigoProducto)), '') IS NULL OR NULLIF(LTRIM(RTRIM(@Nombre)), '') IS NULL
        THROW 50080, N'El código y el nombre del producto son obligatorios', 1;
    IF @Precio < 0 OR @Stock < 0
        THROW 50081, N'El precio y el stock no pueden ser negativos', 1;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Marcas] WHERE Id = @IdMarca)
        THROW 50072, N'La marca no existe', 1;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Categorias] WHERE Id = @IdCategoria)
        THROW 50075, N'La categoría no existe', 1;
    -- RF-09 escenario 3
    IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE CodigoProducto = @CodigoProducto)
        THROW 50082, N'El código de producto ya existe', 1;

    DECLARE @Id UNIQUEIDENTIFIER = NEWID();
    INSERT INTO [dbo].[Productos] (Id, CodigoProducto, Nombre, Descripcion, ImagenUrl, IdMarca, IdCategoria, Precio, Stock, UsuarioCrea)
    VALUES (@Id, @CodigoProducto, @Nombre, @Descripcion, @ImagenUrl, @IdMarca, @IdCategoria, @Precio, @Stock, @IdUsuario);

    SELECT @Id AS Id;
END
