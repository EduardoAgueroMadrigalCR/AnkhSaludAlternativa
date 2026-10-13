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
