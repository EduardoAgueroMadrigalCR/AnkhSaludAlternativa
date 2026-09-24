CREATE TABLE [dbo].[Sesiones] (
    [Id]              UNIQUEIDENTIFIER NOT NULL,
    [IdUsuario]       UNIQUEIDENTIFIER NOT NULL,
    [FechaInicio]     DATETIME         NOT NULL CONSTRAINT [DF_Sesiones_Inicio] DEFAULT (GETDATE()),
    [UltimaActividad] DATETIME         NOT NULL CONSTRAINT [DF_Sesiones_Actividad] DEFAULT (GETDATE()),
    [Activa]          BIT              NOT NULL CONSTRAINT [DF_Sesiones_Activa] DEFAULT (1),
    [MotivoCierre]    VARCHAR(30)      NULL,
    CONSTRAINT [PK_Sesiones] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Sesiones_Usuarios] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[Usuarios] ([Id])
);
