using System.Collections.Generic;
using DataAccess.Repositories;
using Objects.Entities;

namespace Logic.Services
{
    public class CatalogService
    {
        private readonly CatalogRepository _catalogRepository;

        public CatalogService()
        {
            _catalogRepository = new CatalogRepository();
        }

        public IList<CatalogItem> GetRoles()
        {
            return _catalogRepository.GetRoles();
        }

        public IList<CatalogItem> GetGenders()
        {
            return _catalogRepository.GetGenders();
        }

        public IList<CatalogItem> GetMaritalStatuses()
        {
            return _catalogRepository.GetMaritalStatuses();
        }
    }
}
