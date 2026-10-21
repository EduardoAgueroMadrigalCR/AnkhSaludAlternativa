CREATE FUNCTION [dbo].[fn_Config] (@Clave VARCHAR(50))
RETURNS INT
AS
BEGIN
    RETURN (SELECT [Valor] FROM [dbo].[Configuracion] WHERE [Clave] = @Clave);
END
