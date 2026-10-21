-- RF-05
CREATE PROCEDURE [dbo].[CrearUsuario]
@Nombre            VARCHAR(100),
@CorreoElectronico VARCHAR(150),
@PasswordHash      VARCHAR(255),
@IdRol             INT,
@IdAdmin           UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NULLIF(LTRIM(RTRIM(@Nombre)), '') IS NULL OR NULLIF(LTRIM(RTRIM(@CorreoElectronico)), '') IS NULL
        THROW 50050, N'Faltan campos obligatorios', 1;
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Roles] WHERE Id = @IdRol)
        THROW 50052, N'El rol seleccionado no existe', 1;
    IF EXISTS (SELECT 1 FROM [dbo].[Usuarios] WHERE CorreoElectronico = @CorreoElectronico)
        THROW 50053, N'El correo ya está en uso', 1;

    DECLARE @Id UNIQUEIDENTIFIER = NEWID();
    BEGIN TRAN
        INSERT INTO [dbo].[Usuarios] (Id, Nombre, CorreoElectronico, PasswordHash, IdRol, DebeCambiarPassword, UsuarioCrea)
        VALUES (@Id, @Nombre, @CorreoElectronico, @PasswordHash, @IdRol, 1, @IdAdmin);

        INSERT INTO [dbo].[Bitacora] (IdUsuario, Accion, Detalle)
        VALUES (@IdAdmin, 'CREAR_USUARIO', @CorreoElectronico);
    COMMIT TRAN

    SELECT @Id;
END
