CREATE TABLE [dbo].[Categorias] (
    [Id]        UNIQUEIDENTIFIER NOT NULL,
    [Nombre]    VARCHAR(100)     NOT NULL,
    [Activa]    BIT              NOT NULL CONSTRAINT [DF_Categorias_Activa] DEFAULT (1),
    CONSTRAINT [PK_Categorias] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_Categorias_Nombre] UNIQUE ([Nombre])
);
