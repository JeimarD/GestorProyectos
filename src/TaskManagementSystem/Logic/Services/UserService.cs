using System;
using System.Collections.Generic;
using DataAccess.Repositories;
using Logic.Helpers;
using Objects.Entities;
using Objects.Filters;
using Objects.Responses;

namespace Logic.Services
{
    public class UserService
    {
        private readonly UserRepository _userRepository;

        public UserService()
        {
            _userRepository = new UserRepository();
        }

        public IList<UserEntity> GetUsers(UserFilter filter)
        {
            return _userRepository.GetUsers(filter ?? new UserFilter());
        }

        public OperationResult SaveUser(UserEntity user)
        {
            ValidateUser(user);

            if (!string.IsNullOrWhiteSpace(user.Password))
            {
                user.PasswordHash = PasswordHasher.ComputeSha256(user.Password.Trim());
            }

            return _userRepository.SaveUser(user);
        }

        public OperationResult DeleteUser(int userId)
        {
            if (userId <= 0)
            {
                throw new ApplicationException("El usuario seleccionado no es válido.");
            }

            return _userRepository.DeleteUser(userId);
        }

        private static void ValidateUser(UserEntity user)
        {
            if (user == null)
            {
                throw new ApplicationException("La información del usuario es obligatoria.");
            }

            if (user.RoleId <= 0 || user.GenderId <= 0 || user.MaritalStatusId <= 0)
            {
                throw new ApplicationException("Debe seleccionar rol, género y estado civil.");
            }

            if (string.IsNullOrWhiteSpace(user.FirstName) || string.IsNullOrWhiteSpace(user.LastName))
            {
                throw new ApplicationException("Debe indicar nombre y apellido.");
            }

            if (string.IsNullOrWhiteSpace(user.Identification) || string.IsNullOrWhiteSpace(user.UserName))
            {
                throw new ApplicationException("Debe indicar cédula y usuario.");
            }

            if (user.BirthDate == DateTime.MinValue)
            {
                throw new ApplicationException("Debe seleccionar la fecha de nacimiento.");
            }

            if (user.UserId == 0 && string.IsNullOrWhiteSpace(user.Password))
            {
                throw new ApplicationException("La contraseña es obligatoria para crear usuarios.");
            }
        }
    }
}
