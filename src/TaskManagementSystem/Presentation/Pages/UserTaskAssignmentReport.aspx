<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserTaskAssignmentReport.aspx.cs" Inherits="Presentation.Pages.UserTaskAssignmentReport" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Reporte de usuarios y tareas</title>
    <link rel="stylesheet" href="../Content/site.css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-shell">
            <div class="topbar">
                <div>
                    <h1>Reporte de usuarios</h1>
                    <span>Tareas asignadas y su estado actual</span>
                </div>
                <div class="topbar-links">
                    <a href="Reports.aspx">Volver a reportes</a>
                </div>
            </div>
            <div class="panel">
                <asp:ScriptManager ID="scriptManagerUserTask" runat="server" />
                <rsweb:ReportViewer ID="reportViewerUserTask" runat="server" Width="100%" Height="900px" ProcessingMode="Local" AsyncRendering="false" SizeToReportContent="true" ZoomMode="PageWidth" />
            </div>
        </div>
    </form>
</body>
</html>
