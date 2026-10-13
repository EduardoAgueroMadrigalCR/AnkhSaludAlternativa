namespace API.Extensiones
{
    /// <summary>Grupos de roles para [Authorize(Roles = ...)]. Los nombres deben coincidir con la tabla Roles.</summary>
    public static class RolesAcceso
    {
        // Quien puede crear y editar el catalogo (el Vendedor solo lo consulta)
        public const string GestionCatalogo = "Administrador,Encargado de Inventario";
    }
}
