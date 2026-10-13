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
