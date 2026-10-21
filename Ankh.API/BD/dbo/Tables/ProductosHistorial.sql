-- RF-09: historial de modificaciones de cada producto
CREATE TABLE [dbo].[ProductosHistorial] (
    [Id]            BIGINT IDENTITY(1,1) NOT NULL,
    [IdProducto]    UNIQUEIDENTIFIER     NOT NULL,
    [Campo]         VARCHAR(50)          NOT NULL,
    [ValorAnterior] VARCHAR(500)         NULL,
    [ValorNuevo]    VARCHAR(500)         NULL,
    [Fecha]         DATETIME             NOT NULL CONSTRAINT [DF_ProductosHistorial_Fecha] DEFAULT (GETDATE()),
    [IdUsuario]     UNIQUEIDENTIFIER     NULL,
    CONSTRAINT [PK_ProductosHistorial] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ProductosHistorial_Productos] FOREIGN KEY ([IdProducto]) REFERENCES [dbo].[Productos] ([Id])
);
