using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using DataAccess.Infrastructure;
using Objects.Entities;

namespace DataAccess.Repositories
{
    public class CatalogRepository
    {
        public IList<CatalogItem> GetRoles()
        {
            return ExecuteCatalogProcedure("dbo.usp_Role_List");
        }

        public IList<CatalogItem> GetGenders()
        {
            return ExecuteCatalogProcedure("dbo.usp_Gender_List");
        }

        public IList<CatalogItem> GetMaritalStatuses()
        {
            return ExecuteCatalogProcedure("dbo.usp_MaritalStatus_List");
        }

        private IList<CatalogItem> ExecuteCatalogProcedure(string procedureName)
        {
            IList<CatalogItem> items = new List<CatalogItem>();

            try
            {
                using (SqlConnection connection = DatabaseSession.CreateConnection())
                using (SqlCommand command = new SqlCommand(procedureName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            items.Add(new CatalogItem
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                                Name = reader.GetSafeString("Name")
                            });
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new ApplicationException("Error loading catalog data.", exception);
            }

            return items;
        }
    }
}
