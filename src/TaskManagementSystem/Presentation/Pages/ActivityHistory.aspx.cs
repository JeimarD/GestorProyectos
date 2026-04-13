using System;
using System.Collections.Generic;
using System.Web.Script.Services;
using System.Web.Services;
using Logic.Services;
using Objects.Entities;
using Presentation.Helpers;
using Presentation.Models;

namespace Presentation.Pages
{
    public partial class ActivityHistory : BasePage
    {
        public override string ActiveNavigationKey
        {
            get { return "activity"; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthorizationHelper.CanViewReports(CurrentUser))
            {
                Response.Redirect("~/Pages/Dashboard.aspx", true);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AjaxResponse GetActivityHistory(ActivityHistoryFilter filter)
        {
            try
            {
                WebMethodSessionValidator.RequireUserCanViewReports();

                ActivityService activityService = new ActivityService();
                ActivityHistoryFilter safeFilter = filter ?? new ActivityHistoryFilter();
                int maxRows = safeFilter.MaxRows <= 0 ? 200 : safeFilter.MaxRows;
                if (maxRows < 10)
                {
                    maxRows = 10;
                }
                if (maxRows > 1000)
                {
                    maxRows = 1000;
                }
                IList<ActivityLogEntity> source = activityService.GetRecentActivities(maxRows);
                List<ActivityLogEntity> filtered = new List<ActivityLogEntity>();

                DateTime fromDate;
                DateTime toDate;
                bool hasFromDate = DateTime.TryParse(safeFilter.FromDate, out fromDate);
                bool hasToDate = DateTime.TryParse(safeFilter.ToDate, out toDate);
                int timezoneOffsetMinutes = safeFilter.TimezoneOffsetMinutes;
                if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840)
                {
                    timezoneOffsetMinutes = 0;
                }

                if (hasToDate)
                {
                    toDate = toDate.Date.AddDays(1).AddTicks(-1);
                }

                foreach (ActivityLogEntity activity in source)
                {
                    if (!MatchesFilter(activity.UserNameSafe(), safeFilter.UserName))
                    {
                        continue;
                    }

                    if (!MatchesExact(activity.EntityType, safeFilter.EntityType))
                    {
                        continue;
                    }

                    if (!MatchesExact(activity.ActivityType, safeFilter.ActivityType))
                    {
                        continue;
                    }

                    DateTime createdAtViewerTime = ConvertUtcToViewerLocalTime(activity.CreatedAt, timezoneOffsetMinutes);

                    if (hasFromDate && createdAtViewerTime < fromDate.Date)
                    {
                        continue;
                    }

                    if (hasToDate && createdAtViewerTime > toDate)
                    {
                        continue;
                    }

                    filtered.Add(activity);
                }

                filtered.Sort(delegate (ActivityLogEntity left, ActivityLogEntity right)
                {
                    return right.ActivityId.CompareTo(left.ActivityId);
                });

                return new AjaxResponse
                {
                    Success = true,
                    Message = "Registros encontrados: " + filtered.Count,
                    Data = filtered
                };
            }
            catch (Exception exception)
            {
                return new AjaxResponse
                {
                    Success = false,
                    Message = exception.Message,
                    RedirectUrl = exception.Message.Contains("sesión") ? "../Login.aspx" : null
                };
            }
        }

        private static bool MatchesFilter(string sourceValue, string filterValue)
        {
            if (string.IsNullOrWhiteSpace(filterValue))
            {
                return true;
            }

            return (sourceValue ?? string.Empty).IndexOf(filterValue.Trim(), StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private static bool MatchesExact(string sourceValue, string filterValue)
        {
            if (string.IsNullOrWhiteSpace(filterValue))
            {
                return true;
            }

            return string.Equals((sourceValue ?? string.Empty).Trim(), filterValue.Trim(), StringComparison.OrdinalIgnoreCase);
        }

        private static DateTime ConvertUtcToViewerLocalTime(DateTime sourceUtcDateTime, int timezoneOffsetMinutes)
        {
            DateTime utcDateTime = sourceUtcDateTime.Kind == DateTimeKind.Utc
                ? sourceUtcDateTime
                : DateTime.SpecifyKind(sourceUtcDateTime, DateTimeKind.Utc);

            return utcDateTime.AddMinutes(-timezoneOffsetMinutes);
        }

        [Serializable]
        public class ActivityHistoryFilter
        {
            public string UserName { get; set; }
            public string EntityType { get; set; }
            public string ActivityType { get; set; }
            public string FromDate { get; set; }
            public string ToDate { get; set; }
            public int TimezoneOffsetMinutes { get; set; }
            public int MaxRows { get; set; }
        }
    }

    internal static class ActivityLogEntityExtensions
    {
        public static string UserNameSafe(this ActivityLogEntity activity)
        {
            return activity == null || string.IsNullOrWhiteSpace(activity.PerformedByName) ? "Sistema" : activity.PerformedByName;
        }
    }
}
