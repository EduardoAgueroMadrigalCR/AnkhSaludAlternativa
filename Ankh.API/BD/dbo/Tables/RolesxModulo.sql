CREATE TABLE [dbo].[RolesxModulo] (
    [IdRol]    INT NOT NULL,
    [IdModulo] INT NOT NULL,
    CONSTRAINT [PK_RolesxModulo] PRIMARY KEY CLUSTERED ([IdRol] ASC, [IdModulo] ASC),
    CONSTRAINT [FK_RolesxModulo_Roles]   FOREIGN KEY ([IdRol])    REFERENCES [dbo].[Roles] ([Id]),
    CONSTRAINT [FK_RolesxModulo_Modulos] FOREIGN KEY ([IdModulo]) REFERENCES [dbo].[Modulos] ([Id])
);
