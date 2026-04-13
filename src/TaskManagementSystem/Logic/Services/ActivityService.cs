using System;
using System.Collections.Generic;
using DataAccess.Repositories;
using Objects.Entities;

namespace Logic.Services
{
    public class ActivityService
    {
        private readonly ActivityRepository _activityRepository;

        public ActivityService()
        {
            _activityRepository = new ActivityRepository();
        }

        public void SaveActivity(ActivityLogEntity activity)
        {
            if (activity == null)
            {
                throw new ApplicationException("La actividad es obligatoria.");
            }

            if (string.IsNullOrWhiteSpace(activity.EntityType) || string.IsNullOrWhiteSpace(activity.ActivityType) || string.IsNullOrWhiteSpace(activity.Description))
            {
                throw new ApplicationException("La actividad no tiene información suficiente.");
            }

            _activityRepository.SaveActivity(activity);
        }

        public IList<ActivityLogEntity> GetRecentActivities(int maxRows)
        {
            if (maxRows <= 0)
            {
                maxRows = 20;
            }

            return _activityRepository.GetRecentActivities(maxRows);
        }
    }
}
