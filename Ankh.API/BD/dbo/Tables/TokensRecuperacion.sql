CREATE TABLE [dbo].[TokensRecuperacion] (
    [Id]              UNIQUEIDENTIFIER NOT NULL,
    [IdUsuario]       UNIQUEIDENTIFIER NOT NULL,
    [TokenHash]       CHAR(64)         NOT NULL,
    [FechaCreacion]   DATETIME         NOT NULL CONSTRAINT [DF_TokensRec_Creacion] DEFAULT (GETDATE()),
    [FechaExpiracion] DATETIME         NOT NULL,
    [Usado]           BIT              NOT NULL CONSTRAINT [DF_TokensRec_Usado] DEFAULT (0),
    CONSTRAINT [PK_TokensRecuperacion] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TokensRecuperacion_Usuarios] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[Usuarios] ([Id])
);
GO
CREATE INDEX [IX_TokensRecuperacion_Hash] ON [dbo].[TokensRecuperacion] ([TokenHash]);
