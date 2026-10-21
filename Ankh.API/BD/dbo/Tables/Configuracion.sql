CREATE TABLE [dbo].[Configuracion] (
    [Clave]       VARCHAR(50)  NOT NULL,
    [Valor]       INT          NOT NULL,
    [Descripcion] VARCHAR(200) NULL,
    CONSTRAINT [PK_Configuracion] PRIMARY KEY CLUSTERED ([Clave] ASC)
);
