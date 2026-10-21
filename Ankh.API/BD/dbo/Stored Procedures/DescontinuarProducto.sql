-- RF-12: si tiene stock y no se forzo, @RequiereConfirmacion=1 y no cambia nada (la API pregunta al usuario)
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
