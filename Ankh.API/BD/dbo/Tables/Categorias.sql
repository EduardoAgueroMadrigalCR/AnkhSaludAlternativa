IF OBJECT_ID('dbo.Categorias', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Categorias] (
        [Id]                INT IDENTITY(1,1) NOT NULL,
        [Nombre]            NVARCHAR(80)      NOT NULL,
        [Descripcion]       NVARCHAR(250)     NULL,
        [Activa]            BIT               NOT NULL CONSTRAINT [DF_Categorias_Activa] DEFAULT (1),
        [FechaCreacion]     DATETIME          NOT NULL CONSTRAINT [DF_Categorias_FechaCreacion] DEFAULT (GETDATE()),
        [FechaModificacion] DATETIME          NULL,
        [UsuarioCrea]       UNIQUEIDENTIFIER  NULL,
        [UsuarioModifica]   UNIQUEIDENTIFIER  NULL,
        CONSTRAINT [PK_Categorias] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [UQ_Categorias_Nombre] UNIQUE ([Nombre])
    );
END
