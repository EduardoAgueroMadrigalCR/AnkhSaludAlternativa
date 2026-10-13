IF OBJECT_ID('dbo.Productos', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Productos] (
        [Id]                INT IDENTITY(1,1) NOT NULL,
        [Nombre]            NVARCHAR(120)     NOT NULL,
        [Descripcion]       NVARCHAR(250)     NULL,
        [Detalles]          NVARCHAR(1000)    NULL,
        [IdCategoria]       INT               NOT NULL,
        [Precio]            DECIMAL(12,2)     NOT NULL,
        [Imagen]            NVARCHAR(300)     NULL,
        [Activo]            BIT               NOT NULL CONSTRAINT [DF_Productos_Activo] DEFAULT (1),
        [FechaCreacion]     DATETIME          NOT NULL CONSTRAINT [DF_Productos_FechaCreacion] DEFAULT (GETDATE()),
        [FechaModificacion] DATETIME          NULL,
        [UsuarioCrea]       UNIQUEIDENTIFIER  NULL,
        [UsuarioModifica]   UNIQUEIDENTIFIER  NULL,
        CONSTRAINT [PK_Productos] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Productos_Nombre] UNIQUE ([Nombre]),
        CONSTRAINT [CK_Productos_Precio] CHECK ([Precio] > 0),
        CONSTRAINT [FK_Productos_Categorias] FOREIGN KEY ([IdCategoria]) REFERENCES [dbo].[Categorias] ([Id])
    );
    CREATE INDEX [IX_Productos_Categoria] ON [dbo].[Productos] ([IdCategoria]);
END
