-- Elimina definitivamente un producto y su historial (para ocultarlo sin perder datos, use DescontinuarProducto)
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
