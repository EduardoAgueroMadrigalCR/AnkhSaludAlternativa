CREATE TABLE [dbo].[Bitacora] (
    [Id]        BIGINT IDENTITY(1,1) NOT NULL,
    [IdUsuario] UNIQUEIDENTIFIER     NULL,
    [Accion]    VARCHAR(50)          NOT NULL,
    [Detalle]   VARCHAR(300)         NULL,
    [Fecha]     DATETIME             NOT NULL CONSTRAINT [DF_Bitacora_Fecha] DEFAULT (GETDATE()),
    CONSTRAINT [PK_Bitacora] PRIMARY KEY CLUSTERED ([Id] ASC)
);
