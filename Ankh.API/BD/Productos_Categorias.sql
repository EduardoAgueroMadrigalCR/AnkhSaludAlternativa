/* ============================================================================
   Ankh - Modulo de Productos y Categorias
   Script INCREMENTAL e idempotente: se puede ejecutar varias veces sobre la
   base existente sin perder datos. Ejecutelo DESPUES de Ankh_BD_Completo.sql.
   ============================================================================ */
USE MacrobioticaDB;
GO

/* ---------- Tablas ---------- */
IF OBJECT_ID('dbo.Categorias', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Categorias] (
        [Id]                INT IDENTITY(1,1) NOT NULL,
        [Nombre]            NVARCHAR(80)      NOT NULL,
        [Descripcion]       NVARCHAR(250)     NULL,
        [Activa]            BIT               NOT NULL CONSTRAINT [DF_Categorias_Activa] DEFAULT (1),
        [FechaCreacion]     DATETIME          NOT NULL CONSTRAINT [DF_Categorias_FechaCreacion] DEFAULT (GETDATE()),
        [FechaModificacion] DATETIME          NULL,
        [UsuarioCrea]       UNIQUEIDENTIFIER  NULL,
        [UsuarioModifica]   UNIQUEIDENTIFIER  NULL,
        CONSTRAINT [PK_Categorias] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Categorias_Nombre] UNIQUE ([Nombre])
    );
END
GO

IF OBJECT_ID('dbo.Productos', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Productos] (
        [Id]                INT IDENTITY(1,1) NOT NULL,
        [Nombre]            NVARCHAR(120)     NOT NULL,
        [Descripcion]       NVARCHAR(250)     NULL,
        [Detalles]          NVARCHAR(1000)    NULL,
        [IdCategoria]       INT               NOT NULL,
        [Precio]            DECIMAL(12,2)     NOT NULL,
        [Imagen]            NVARCHAR(300)     NULL,
        [Activo]            BIT               NOT NULL CONSTRAINT [DF_Productos_Activo] DEFAULT (1),
        [FechaCreacion]     DATETIME          NOT NULL CONSTRAINT [DF_Productos_FechaCreacion] DEFAULT (GETDATE()),
        [FechaModificacion] DATETIME          NULL,
        [UsuarioCrea]       UNIQUEIDENTIFIER  NULL,
        [UsuarioModifica]   UNIQUEIDENTIFIER  NULL,
        CONSTRAINT [PK_Productos] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Productos_Nombre] UNIQUE ([Nombre]),
        CONSTRAINT [CK_Productos_Precio] CHECK ([Precio] > 0),
        CONSTRAINT [FK_Productos_Categorias] FOREIGN KEY ([IdCategoria]) REFERENCES [dbo].[Categorias] ([Id])
    );
    CREATE INDEX [IX_Productos_Categoria] ON [dbo].[Productos] ([IdCategoria]);
END
GO

/* ---------- Procedimientos almacenados: categorias ---------- */
CREATE OR ALTER PROCEDURE [dbo].[CrearCategoria]
@Nombre      NVARCHAR(80),
@Descripcion NVARCHAR(250) = NULL,
@IdUsuario   UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Nombre = LTRIM(RTRIM(ISNULL(@Nombre, N'')));
    SET @Descripcion = NULLIF(LTRIM(RTRIM(ISNULL(@Descripcion, N''))), N'');

    IF @Nombre = N''
        THROW 50070, N'El nombre de la categoría es obligatorio', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Categorias] WHERE Nombre = @Nombre)
        THROW 50071, N'Ya existe una categoría con ese nombre', 1;

    DECLARE @Id INT;
    BEGIN TRAN
        INSERT INTO [dbo].[Categorias] (Nombre, Descripcion, UsuarioCrea)
        VALUES (@Nombre, @Descripcion, @IdUsuario);
        SET @Id = SCOPE_IDENTITY();

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdUsuario, 'CREAR_CATEGORIA', LEFT(@Nombre, 300));
    COMMIT TRAN

    SELECT @Id;
END

GO

CREATE OR ALTER PROCEDURE [dbo].[ActualizarCategoria]
@Id          INT,
@Nombre      NVARCHAR(80),
@Descripcion NVARCHAR(250) = NULL,
@Activa      BIT,
@IdUsuario   UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Nombre = LTRIM(RTRIM(ISNULL(@Nombre, N'')));
    SET @Descripcion = NULLIF(LTRIM(RTRIM(ISNULL(@Descripcion, N''))), N'');

    DECLARE @ActivaActual BIT = (SELECT Activa FROM [dbo].[Categorias] WHERE Id = @Id);

    IF @ActivaActual IS NULL
        THROW 50072, N'La categoría no existe', 1;
    IF @Nombre = N''
        THROW 50070, N'El nombre de la categoría es obligatorio', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Categorias] WHERE Nombre = @Nombre AND Id <> @Id)
        THROW 50071, N'Ya existe una categoría con ese nombre', 1;
    IF @ActivaActual = 1 AND @Activa = 0
       AND EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE IdCategoria = @Id AND Activo = 1)
        THROW 50073, N'No se puede desactivar una categoría que tiene productos activos', 1;

    BEGIN TRAN
        UPDATE [dbo].[Categorias]
        SET Nombre = @Nombre, Descripcion = @Descripcion, Activa = @Activa,
            FechaModificacion = GETDATE(), UsuarioModifica = @IdUsuario
        WHERE Id = @Id;

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdUsuario, 'ACTUALIZAR_CATEGORIA', LEFT(CONCAT(@Id, ' - ', @Nombre), 300));
    COMMIT TRAN
END

GO

CREATE OR ALTER PROCEDURE [dbo].[ListarCategorias]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.Id, c.Nombre, c.Descripcion, c.Activa,
           (SELECT COUNT(*) FROM [dbo].[Productos] p WHERE p.IdCategoria = c.Id AND p.Activo = 1) AS ProductosActivos
    FROM [dbo].[Categorias] c
    ORDER BY c.Nombre;
END

GO

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

GO

/* ---------- Procedimientos almacenados: productos ---------- */
CREATE OR ALTER PROCEDURE [dbo].[CrearProducto]
@Nombre      NVARCHAR(120),
@Descripcion NVARCHAR(250)  = NULL,
@Detalles    NVARCHAR(1000) = NULL,
@IdCategoria INT,
@Precio      DECIMAL(12,2),
@Imagen      NVARCHAR(300)  = NULL,
@IdUsuario   UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Nombre = LTRIM(RTRIM(ISNULL(@Nombre, N'')));
    SET @Descripcion = NULLIF(LTRIM(RTRIM(ISNULL(@Descripcion, N''))), N'');
    SET @Detalles = NULLIF(LTRIM(RTRIM(ISNULL(@Detalles, N''))), N'');
    SET @Imagen = NULLIF(LTRIM(RTRIM(ISNULL(@Imagen, N''))), N'');

    IF @Nombre = N''
        THROW 50080, N'El nombre del producto es obligatorio', 1;
    IF @Precio IS NULL OR @Precio <= 0
        THROW 50084, N'El precio debe ser mayor que cero', 1;

    DECLARE @CategoriaActiva BIT = (SELECT Activa FROM [dbo].[Categorias] WHERE Id = @IdCategoria);
    IF @CategoriaActiva IS NULL
        THROW 50083, N'La categoría seleccionada no existe', 1;
    IF @CategoriaActiva = 0
        THROW 50085, N'La categoría seleccionada está inactiva', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE Nombre = @Nombre)
        THROW 50081, N'Ya existe un producto con ese nombre', 1;

    DECLARE @Id INT;
    BEGIN TRAN
        INSERT INTO [dbo].[Productos] (Nombre, Descripcion, Detalles, IdCategoria, Precio, Imagen, UsuarioCrea)
        VALUES (@Nombre, @Descripcion, @Detalles, @IdCategoria, @Precio, @Imagen, @IdUsuario);
        SET @Id = SCOPE_IDENTITY();

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdUsuario, 'CREAR_PRODUCTO', LEFT(@Nombre, 300));
    COMMIT TRAN

    SELECT @Id;
END

GO

CREATE OR ALTER PROCEDURE [dbo].[ActualizarProducto]
@Id          INT,
@Nombre      NVARCHAR(120),
@Descripcion NVARCHAR(250)  = NULL,
@Detalles    NVARCHAR(1000) = NULL,
@IdCategoria INT,
@Precio      DECIMAL(12,2),
@Imagen      NVARCHAR(300)  = NULL,
@Activo      BIT,
@IdUsuario   UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Nombre = LTRIM(RTRIM(ISNULL(@Nombre, N'')));
    SET @Descripcion = NULLIF(LTRIM(RTRIM(ISNULL(@Descripcion, N''))), N'');
    SET @Detalles = NULLIF(LTRIM(RTRIM(ISNULL(@Detalles, N''))), N'');
    SET @Imagen = NULLIF(LTRIM(RTRIM(ISNULL(@Imagen, N''))), N'');

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE Id = @Id)
        THROW 50082, N'El producto no existe', 1;
    IF @Nombre = N''
        THROW 50080, N'El nombre del producto es obligatorio', 1;
    IF @Precio IS NULL OR @Precio <= 0
        THROW 50084, N'El precio debe ser mayor que cero', 1;

    DECLARE @CategoriaActiva BIT = (SELECT Activa FROM [dbo].[Categorias] WHERE Id = @IdCategoria);
    IF @CategoriaActiva IS NULL
        THROW 50083, N'La categoría seleccionada no existe', 1;
    IF @Activo = 1 AND @CategoriaActiva = 0
        THROW 50085, N'La categoría seleccionada está inactiva', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE Nombre = @Nombre AND Id <> @Id)
        THROW 50081, N'Ya existe un producto con ese nombre', 1;

    BEGIN TRAN
        UPDATE [dbo].[Productos]
        SET Nombre = @Nombre, Descripcion = @Descripcion, Detalles = @Detalles,
            IdCategoria = @IdCategoria, Precio = @Precio, Imagen = @Imagen, Activo = @Activo,
            FechaModificacion = GETDATE(), UsuarioModifica = @IdUsuario
        WHERE Id = @Id;

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdUsuario, 'ACTUALIZAR_PRODUCTO', LEFT(CONCAT(@Id, ' - ', @Nombre), 300));
    COMMIT TRAN
END

GO

CREATE OR ALTER PROCEDURE [dbo].[ListarProductos]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Id, p.Nombre, p.Descripcion, p.Detalles, p.IdCategoria, c.Nombre AS Categoria,
           p.Precio, p.Imagen, p.Activo
    FROM [dbo].[Productos] p
    INNER JOIN [dbo].[Categorias] c ON c.Id = p.IdCategoria
    ORDER BY p.Nombre;
END

GO

CREATE OR ALTER PROCEDURE [dbo].[ObtenerProductoPorId]
@Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Id, p.Nombre, p.Descripcion, p.Detalles, p.IdCategoria, c.Nombre AS Categoria,
           p.Precio, p.Imagen, p.Activo
    FROM [dbo].[Productos] p
    INNER JOIN [dbo].[Categorias] c ON c.Id = p.IdCategoria
    WHERE p.Id = @Id;
END

GO

/* ---------- Permisos: el Encargado de Inventario debe tener Productos e Inventario ----------
   (Ankh_BD_Completo.sql no lo asignaba; DatosIniciales.sql si). Es idempotente. */
INSERT INTO [dbo].[RolesxModulo] (IdRol, IdModulo)
SELECT 3, m.Id
FROM [dbo].[Modulos] m
WHERE m.Nombre IN ('Productos', 'Inventario')
  AND NOT EXISTS (SELECT 1 FROM [dbo].[RolesxModulo] rm WHERE rm.IdRol = 3 AND rm.IdModulo = m.Id);
GO

/* ---------- Datos iniciales: catalogo que hoy esta fijo en index.js / producto.html ----------
   Solo se insertan si las tablas estan vacias. */
IF NOT EXISTS (SELECT 1 FROM [dbo].[Categorias])
BEGIN
    INSERT INTO [dbo].[Categorias] (Nombre, Descripcion) VALUES
     (N'Bienestar', N'Suplementos y hierbas para el equilibrio diario'),
     (N'Salud',     N'Vitaminas y minerales de soporte general'),
     (N'Belleza',   N'Cuidado de piel, cabello y articulaciones'),
     (N'Vitalidad', N'Apoyo hormonal y de energía natural'),
     (N'Cuidado',   N'Higiene y cuidado personal diario');
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Productos])
BEGIN
    INSERT INTO [dbo].[Productos] (Nombre, Descripcion, Detalles, IdCategoria, Precio, Imagen)
    SELECT v.Nombre, v.Descripcion, v.Detalles, c.Id, v.Precio, v.Imagen
    FROM (VALUES
     (N'Ashwagandha Premium', N'Suplemento herbal para equilibrio y energía diaria.',
      N'60 cápsulas de extracto estandarizado para una sensación de calma y resistencia natural.',
      N'Bienestar', 82000.00, N'images/ASHWAGANDHA.jpg'),
     (N'Vitamina D3 + B12', N'Fórmula para energía, inmunidad y soporte óseo.',
      N'30 tabletas para mantener tu sistema inmune y niveles de energía saludables.',
      N'Salud', 49500.00, N'images/D3+B12.jpg'),
     (N'Colágeno Marino', N'Refuerza piel, cabello y articulaciones con colágeno puro.',
      N'Fórmula con colágeno tipo I y III para mayor firmeza y elasticidad.',
      N'Belleza', 142000.00, N'images/COLAGENOMARINO.png'),
     (N'DHEA 10mg', N'Apoya bienestar hormonal y energía natural.',
      N'30 cápsulas de DHEA para un apoyo metabólico balanceado.',
      N'Vitalidad', 78000.00, N'images/DHEA10MG.jpg'),
     (N'Pasta dental fresca', N'Protección dental diaria con sensación fresca.',
      N'Fórmula suave que blanquea y protege el esmalte con frescura duradera.',
      N'Cuidado', 18900.00, N'images/TOOTHPASTE.jpg')
    ) AS v(Nombre, Descripcion, Detalles, Categoria, Precio, Imagen)
    INNER JOIN [dbo].[Categorias] c ON c.Nombre = v.Categoria;
END
GO

PRINT 'Productos y Categorias listos.';
