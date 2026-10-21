-- Listado administrativo: incluye descontinuados
CREATE PROCEDURE [dbo].[ListarProductos]
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [dbo].[BuscarProductos] @SoloActivos = 0;
END
