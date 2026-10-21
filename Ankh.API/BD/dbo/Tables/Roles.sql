CREATE TABLE [dbo].[Roles] (
    [Id]          INT          NOT NULL,
    [Nombre]      VARCHAR(50)  NOT NULL,
    [Descripcion] VARCHAR(200) NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_Roles_Nombre] UNIQUE ([Nombre])
);
