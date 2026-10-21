-- RF-10 escenario 3: el nombre se refleja en todos los productos asociados (son la misma fila por FK)
CREATE PROCEDURE [dbo].[ActualizarMarca]
@Id     UNIQUEIDENTIFIER,
@Nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Marcas] WHERE Id = @Id)
        THROW 50072, N'La marca no existe', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Marcas] WHERE Nombre = @Nombre AND Id <> @Id)
        THROW 50071, N'Esa marca ya existe', 1;

    UPDATE [dbo].[Marcas] SET Nombre = @Nombre WHERE Id = @Id;
END
