-- Datos iniciales (ejecutar una sola vez)
INSERT INTO [dbo].[Configuracion] (Clave, Valor, Descripcion) VALUES
 ('MaxIntentosFallidos',      3,  'Intentos fallidos antes de bloquear la cuenta (RF-01)'),
 ('MinutosBloqueo',           15, 'Minutos de bloqueo de la cuenta (RF-01)'),
 ('MinutosInactividad',       10, 'Minutos de inactividad para cerrar la sesion (RF-02)'),
 ('SegundosAvisoSesion',      30, 'Segundos de aviso antes de cerrar la sesion (RF-02)'),
 ('MinutosTokenRecuperacion', 30, 'Vigencia del enlace de recuperacion (RF-04)');

INSERT INTO [dbo].[Roles] (Id, Nombre, Descripcion) VALUES
 (1, 'Administrador',           'Duena del negocio, acceso total'),
 (2, 'Vendedor',                'Consulta productos y registra ventas'),
 (3, 'Encargado de Inventario', 'Gestiona productos e inventario');

INSERT INTO [dbo].[Modulos] (Nombre) VALUES ('Usuarios'), ('Productos'), ('Inventario'), ('Ventas'), ('Reportes');

INSERT INTO [dbo].[RolesxModulo] (IdRol, IdModulo) SELECT 1, Id FROM [dbo].[Modulos];
INSERT INTO [dbo].[RolesxModulo] (IdRol, IdModulo) SELECT 2, Id FROM [dbo].[Modulos] WHERE Nombre IN ('Productos', 'Ventas');
INSERT INTO [dbo].[RolesxModulo] (IdRol, IdModulo) SELECT 3, Id FROM [dbo].[Modulos] WHERE Nombre IN ('Productos', 'Inventario');

-- Administradora inicial. Contrasena temporal: Ankh2026!  (el sistema le pedira cambiarla)
INSERT INTO [dbo].[Usuarios] (Id, Nombre, CorreoElectronico, PasswordHash, IdRol, DebeCambiarPassword)
VALUES (NEWID(), 'Marina Madrigal Diaz', 'marina0759@hotmail.com',
        '$2b$11$AsIrYzl1I4ldFEASFLqL1Ou4qTAW5T2tONq6C.wSa7naHnolFz0Li', 1, 1);
