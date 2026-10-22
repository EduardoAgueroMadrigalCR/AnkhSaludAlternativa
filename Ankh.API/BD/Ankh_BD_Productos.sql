
USE MacrobioticaDB;
GO
IF OBJECT_ID('dbo.Marcas','U') IS NULL
BEGIN
CREATE TABLE [dbo].[Marcas] (
    [Id]        UNIQUEIDENTIFIER NOT NULL,
    [Nombre]    VARCHAR(100)     NOT NULL,
    [Activa]    BIT              NOT NULL CONSTRAINT [DF_Marcas_Activa] DEFAULT (1),
    CONSTRAINT [PK_Marcas] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_Marcas_Nombre] UNIQUE ([Nombre])
);
END
GO
IF OBJECT_ID('dbo.Categorias','U') IS NULL
BEGIN
CREATE TABLE [dbo].[Categorias] (
    [Id]        UNIQUEIDENTIFIER NOT NULL,
    [Nombre]    VARCHAR(100)     NOT NULL,
    [Activa]    BIT              NOT NULL CONSTRAINT [DF_Categorias_Activa] DEFAULT (1),
    CONSTRAINT [PK_Categorias] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_Categorias_Nombre] UNIQUE ([Nombre])
);
END
GO
IF OBJECT_ID('dbo.Productos','U') IS NULL
BEGIN
CREATE TABLE [dbo].[Productos] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [CodigoProducto]     VARCHAR(30)      NOT NULL,
    [Nombre]             VARCHAR(150)     NOT NULL,
    [Descripcion]        VARCHAR(500)     NULL,
    [IdMarca]            UNIQUEIDENTIFIER NOT NULL,
    [IdCategoria]        UNIQUEIDENTIFIER NOT NULL,
    [ImagenUrl]          VARCHAR(300)     NULL,
    [Precio]             DECIMAL(10,2)    NOT NULL,
    [Stock]              INT              NOT NULL CONSTRAINT [DF_Productos_Stock] DEFAULT (0),
    [Descontinuado]      BIT              NOT NULL CONSTRAINT [DF_Productos_Descontinuado] DEFAULT (0),
    [FechaDescontinuado] DATETIME         NULL,
    [FechaCreacion]      DATETIME         NOT NULL CONSTRAINT [DF_Productos_FechaCreacion] DEFAULT (GETDATE()),
    [FechaModificacion]  DATETIME         NULL,
    [UsuarioCrea]        UNIQUEIDENTIFIER NULL,
    [UsuarioModifica]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Productos] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_Productos_Codigo] UNIQUE ([CodigoProducto]),
    CONSTRAINT [FK_Productos_Marcas] FOREIGN KEY ([IdMarca]) REFERENCES [dbo].[Marcas] ([Id]),
    CONSTRAINT [FK_Productos_Categorias] FOREIGN KEY ([IdCategoria]) REFERENCES [dbo].[Categorias] ([Id]),
    CONSTRAINT [CK_Productos_Precio] CHECK ([Precio] >= 0),
    CONSTRAINT [CK_Productos_Stock] CHECK ([Stock] >= 0)
);
END
GO
IF OBJECT_ID('dbo.ProductosHistorial','U') IS NULL
BEGIN

CREATE TABLE [dbo].[ProductosHistorial] (
    [Id]            BIGINT IDENTITY(1,1) NOT NULL,
    [IdProducto]    UNIQUEIDENTIFIER     NOT NULL,
    [Campo]         VARCHAR(50)          NOT NULL,
    [ValorAnterior] VARCHAR(500)         NULL,
    [ValorNuevo]    VARCHAR(500)         NULL,
    [Fecha]         DATETIME             NOT NULL CONSTRAINT [DF_ProductosHistorial_Fecha] DEFAULT (GETDATE()),
    [IdUsuario]     UNIQUEIDENTIFIER     NULL,
    CONSTRAINT [PK_ProductosHistorial] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ProductosHistorial_Productos] FOREIGN KEY ([IdProducto]) REFERENCES [dbo].[Productos] ([Id])
);
END
GO

IF COL_LENGTH('dbo.Productos', 'ImagenUrl') IS NULL
    ALTER TABLE [dbo].[Productos] ADD [ImagenUrl] VARCHAR(300) NULL;
GO
IF OBJECT_ID('dbo.ActualizarCategoria') IS NOT NULL DROP PROCEDURE [dbo].[ActualizarCategoria];
GO
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
GO
IF OBJECT_ID('dbo.ActualizarMarca') IS NOT NULL DROP PROCEDURE [dbo].[ActualizarMarca];
GO

CREATE PROCEDURE [dbo].[ActualizarMarca]
@Id     UNIQUEIDENTIFIER,
@Nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Marcas] WHERE Id = @Id)
        THROW 50072, N'La marca no existe', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Marcas] WHERE Nombre = @Nombre AND Id <> @Id)
        THROW 50071, N'Esa marca ya existe', 1;

    UPDATE [dbo].[Marcas] SET Nombre = @Nombre WHERE Id = @Id;
END
GO
IF OBJECT_ID('dbo.ActualizarProducto') IS NOT NULL DROP PROCEDURE [dbo].[ActualizarProducto];
GO

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
GO
IF OBJECT_ID('dbo.BuscarProductos') IS NOT NULL DROP PROCEDURE [dbo].[BuscarProductos];
GO

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
GO
IF OBJECT_ID('dbo.CrearCategoria') IS NOT NULL DROP PROCEDURE [dbo].[CrearCategoria];
GO
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
GO
IF OBJECT_ID('dbo.CrearMarca') IS NOT NULL DROP PROCEDURE [dbo].[CrearMarca];
GO
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
GO
IF OBJECT_ID('dbo.CrearProducto') IS NOT NULL DROP PROCEDURE [dbo].[CrearProducto];
GO

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

    IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE CodigoProducto = @CodigoProducto)
        THROW 50082, N'El código de producto ya existe', 1;

    DECLARE @Id UNIQUEIDENTIFIER = NEWID();
    INSERT INTO [dbo].[Productos] (Id, CodigoProducto, Nombre, Descripcion, ImagenUrl, IdMarca, IdCategoria, Precio, Stock, UsuarioCrea)
    VALUES (@Id, @CodigoProducto, @Nombre, @Descripcion, @ImagenUrl, @IdMarca, @IdCategoria, @Precio, @Stock, @IdUsuario);

    SELECT @Id AS Id;
END
GO
IF OBJECT_ID('dbo.DescontinuarProducto') IS NOT NULL DROP PROCEDURE [dbo].[DescontinuarProducto];
GO

CREATE PROCEDURE [dbo].[DescontinuarProducto]
@Id       UNIQUEIDENTIFIER,
@IdUsuario UNIQUEIDENTIFIER,
@Forzar   BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Stock INT = (SELECT Stock FROM [dbo].[Productos] WHERE Id = @Id);
    IF @Stock IS NULL
        THROW 50083, N'El producto no existe', 1;

    IF @Stock > 0 AND @Forzar = 0
    BEGIN
        SELECT CAST(1 AS BIT) AS RequiereConfirmacion, @Stock AS StockActual;
        RETURN;
    END

    UPDATE [dbo].[Productos]
    SET Descontinuado = 1, FechaDescontinuado = GETDATE(), FechaModificacion = GETDATE(), UsuarioModifica = @IdUsuario
    WHERE Id = @Id;

    SELECT CAST(0 AS BIT) AS RequiereConfirmacion, @Stock AS StockActual;
END
GO
IF OBJECT_ID('dbo.EliminarCategoria') IS NOT NULL DROP PROCEDURE [dbo].[EliminarCategoria];
GO

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
GO
IF OBJECT_ID('dbo.EliminarMarca') IS NOT NULL DROP PROCEDURE [dbo].[EliminarMarca];
GO
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
GO
IF OBJECT_ID('dbo.ListarCategorias') IS NOT NULL DROP PROCEDURE [dbo].[ListarCategorias];
GO
CREATE PROCEDURE [dbo].[ListarCategorias]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Nombre, Activa FROM [dbo].[Categorias] ORDER BY Nombre;
END
GO
IF OBJECT_ID('dbo.ListarMarcas') IS NOT NULL DROP PROCEDURE [dbo].[ListarMarcas];
GO
CREATE PROCEDURE [dbo].[ListarMarcas]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Nombre, Activa FROM [dbo].[Marcas] ORDER BY Nombre;
END
GO
IF OBJECT_ID('dbo.ListarProductos') IS NOT NULL DROP PROCEDURE [dbo].[ListarProductos];
GO
-- Listado administrativo: incluye descontinuados
CREATE PROCEDURE [dbo].[ListarProductos]
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [dbo].[BuscarProductos] @SoloActivos = 0;
END
GO
IF OBJECT_ID('dbo.ObtenerHistorialProducto') IS NOT NULL DROP PROCEDURE [dbo].[ObtenerHistorialProducto];
GO
CREATE PROCEDURE [dbo].[ObtenerHistorialProducto]
@IdProducto UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT h.Campo, h.ValorAnterior, h.ValorNuevo, h.Fecha, u.Nombre AS Usuario
    FROM [dbo].[ProductosHistorial] h
    LEFT JOIN [dbo].[Usuarios] u ON u.Id = h.IdUsuario
    WHERE h.IdProducto = @IdProducto
    ORDER BY h.Fecha DESC;
END
GO
IF OBJECT_ID('dbo.ObtenerProductoPorId') IS NOT NULL DROP PROCEDURE [dbo].[ObtenerProductoPorId];
GO
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
GO
IF OBJECT_ID('dbo.ReactivarProducto') IS NOT NULL DROP PROCEDURE [dbo].[ReactivarProducto];
GO

CREATE PROCEDURE [dbo].[ReactivarProducto]
@Id        UNIQUEIDENTIFIER,
@IdUsuario UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE Id = @Id)
        THROW 50083, N'El producto no existe', 1;

    UPDATE [dbo].[Productos]
    SET Descontinuado = 0, FechaDescontinuado = NULL, FechaModificacion = GETDATE(), UsuarioModifica = @IdUsuario
    WHERE Id = @Id;
END
GO
IF OBJECT_ID('dbo.EliminarProducto') IS NOT NULL DROP PROCEDURE [dbo].[EliminarProducto];
GO

CREATE PROCEDURE [dbo].[EliminarProducto]
@Id        UNIQUEIDENTIFIER,
@IdUsuario UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Codigo VARCHAR(30), @Nombre VARCHAR(150);
    SELECT @Codigo = CodigoProducto, @Nombre = Nombre FROM [dbo].[Productos] WHERE Id = @Id;

    IF @Codigo IS NULL
        THROW 50083, N'El producto no existe', 1;

    BEGIN TRAN
        DELETE FROM [dbo].[ProductosHistorial] WHERE IdProducto = @Id;
        DELETE FROM [dbo].[Productos] WHERE Id = @Id;

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdUsuario, 'ELIMINAR_PRODUCTO', LEFT(CONCAT(@Codigo, ' - ', @Nombre), 300));
    COMMIT TRAN
END
GO