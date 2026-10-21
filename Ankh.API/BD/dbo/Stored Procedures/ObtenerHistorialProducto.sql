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
