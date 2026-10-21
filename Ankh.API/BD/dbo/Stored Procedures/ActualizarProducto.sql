-- RF-09 escenario 2: guarda en ProductosHistorial cada campo que cambie
CREATE PROCEDURE [dbo].[ActualizarProducto]
@Id             UNIQUEIDENTIFIER,
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

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE Id = @Id)
        THROW 50083, N'El producto no existe', 1;
    IF @Precio < 0 OR @Stock < 0
        THROW 50081, N'El precio y el stock no pueden ser negativos', 1;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Marcas] WHERE Id = @IdMarca)
        THROW 50072, N'La marca no existe', 1;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Categorias] WHERE Id = @IdCategoria)
        THROW 50075, N'La categoría no existe', 1;

    DECLARE @Actual TABLE (Nombre VARCHAR(150), Descripcion VARCHAR(500), IdMarca UNIQUEIDENTIFIER,
                           IdCategoria UNIQUEIDENTIFIER, Precio DECIMAL(10,2), Stock INT);
    INSERT INTO @Actual
    SELECT Nombre, Descripcion, IdMarca, IdCategoria, Precio, Stock FROM [dbo].[Productos] WHERE Id = @Id;

    BEGIN TRAN
        UPDATE [dbo].[Productos]
        SET Nombre = @Nombre, Descripcion = @Descripcion, ImagenUrl = @ImagenUrl, IdMarca = @IdMarca, IdCategoria = @IdCategoria,
            Precio = @Precio, Stock = @Stock, FechaModificacion = GETDATE(), UsuarioModifica = @IdUsuario
        WHERE Id = @Id;

        INSERT INTO [dbo].[ProductosHistorial] (IdProducto, Campo, ValorAnterior, ValorNuevo, IdUsuario)
        SELECT @Id, 'Nombre', a.Nombre, @Nombre, @IdUsuario FROM @Actual a WHERE a.Nombre <> @Nombre
        UNION ALL
        SELECT @Id, 'Descripcion', a.Descripcion, @Descripcion, @IdUsuario FROM @Actual a
            WHERE ISNULL(a.Descripcion, '') <> ISNULL(@Descripcion, '')
        UNION ALL
        SELECT @Id, 'Precio', CAST(a.Precio AS VARCHAR(30)), CAST(@Precio AS VARCHAR(30)), @IdUsuario
            FROM @Actual a WHERE a.Precio <> @Precio
        UNION ALL
        SELECT @Id, 'Stock', CAST(a.Stock AS VARCHAR(30)), CAST(@Stock AS VARCHAR(30)), @IdUsuario
            FROM @Actual a WHERE a.Stock <> @Stock
        UNION ALL
        SELECT @Id, 'Marca', CAST(a.IdMarca AS VARCHAR(36)), CAST(@IdMarca AS VARCHAR(36)), @IdUsuario
            FROM @Actual a WHERE a.IdMarca <> @IdMarca
        UNION ALL
        SELECT @Id, 'Categoria', CAST(a.IdCategoria AS VARCHAR(36)), CAST(@IdCategoria AS VARCHAR(36)), @IdUsuario
            FROM @Actual a WHERE a.IdCategoria <> @IdCategoria;
    COMMIT TRAN
END
