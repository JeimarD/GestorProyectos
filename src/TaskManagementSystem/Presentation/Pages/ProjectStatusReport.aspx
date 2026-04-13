<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProjectStatusReport.aspx.cs" Inherits="Presentation.Pages.ProjectStatusReport" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Reporte de proyectos y estatus</title>
    <link rel="stylesheet" href="../Content/site.css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-shell">
            <div class="topbar">
                <div>
                    <h1>Reporte de proyectos</h1>
                    <span>Estado general y condición de fechas</span>
                </div>
                <div class="topbar-links">
                    <a href="Reports.aspx">Volver a reportes</a>
                </div>
            </div>
            <div class="panel">
                <asp:ScriptManager ID="scriptManagerProject" runat="server" />
                <rsweb:ReportViewer ID="reportViewerProjectStatus" runat="server" Width="100%" Height="900px" ProcessingMode="Local" AsyncRendering="false" SizeToReportContent="true" ZoomMode="PageWidth" />
            </div>
        </div>
    </form>
</body>
</html>
