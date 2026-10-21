-- RF-12 escenario 3: conserva los atributos originales (nunca se borraron)
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
