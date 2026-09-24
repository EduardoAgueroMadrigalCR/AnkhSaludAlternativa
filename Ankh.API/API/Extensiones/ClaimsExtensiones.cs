using System.Security.Claims;

namespace API.Extensiones
{
    public static class ClaimsExtensiones
    {
        public static Guid ObtenerIdUsuario(this ClaimsPrincipal usuario)
            => Guid.Parse(usuario.FindFirst("sub")?.Value ?? throw new UnauthorizedAccessException());

        public static Guid ObtenerIdSesion(this ClaimsPrincipal usuario)
            => Guid.Parse(usuario.FindFirst("sid")?.Value ?? throw new UnauthorizedAccessException());
    }
}
