CREATE TABLE [dbo].[Modulos] (
    [Id]     INT IDENTITY(1,1) NOT NULL,
    [Nombre] VARCHAR(50)       NOT NULL,
    CONSTRAINT [PK_Modulos] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_Modulos_Nombre] UNIQUE ([Nombre])
);
