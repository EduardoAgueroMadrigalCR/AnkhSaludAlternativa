CREATE TABLE [dbo].[Marcas] (
    [Id]        UNIQUEIDENTIFIER NOT NULL,
    [Nombre]    VARCHAR(100)     NOT NULL,
    [Activa]    BIT              NOT NULL CONSTRAINT [DF_Marcas_Activa] DEFAULT (1),
    CONSTRAINT [PK_Marcas] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_Marcas_Nombre] UNIQUE ([Nombre])
);
