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
