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
