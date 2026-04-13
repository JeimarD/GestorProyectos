using System;
using DataAccess.Repositories;
using Logic.Helpers;
using Objects.Entities;

namespace Logic.Services
{
    public class AuthService
    {
        private readonly AuthRepository _authRepository;

        public AuthService()
        {
            _authRepository = new AuthRepository();
        }

        public AuthenticatedUser Authenticate(LoginRequest request)
        {
            if (request == null)
            {
                throw new ApplicationException("La solicitud de autenticación es inválida.");
            }

            if (string.IsNullOrWhiteSpace(request.UserName) || string.IsNullOrWhiteSpace(request.Password))
            {
                throw new ApplicationException("Debe indicar usuario y contraseña.");
            }

            string passwordHash = PasswordHasher.ComputeSha256(request.Password.Trim());
            return _authRepository.Login(request.UserName.Trim(), passwordHash);
        }
    }
}
