<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Presentation.Login" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Ingreso al sistema</title>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Manrope:wght@700;800&display=swap" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:FILL@0;1" />
    <link rel="stylesheet" href="Content/site.css" />
</head>
<body class="login-body">
    <form id="form1" runat="server">
        <div class="login-shell">
            <div class="login-brand">
                <div class="login-brand-mark">
                    <span class="material-symbols-outlined">account_tree</span>
                </div>
                <h1>Gestor de Proyectos</h1>
                <p>Espacio de trabajo y seguimiento operativo</p>
            </div>

            <main class="login-main-card">
                <div class="login-card-decoration"></div>
                <div class="login-card">
                    <div class="login-card-header">
                        <span class="login-eyebrow">Acceso seguro</span>
                        <h2>Iniciar sesión</h2>
                        <p>Ingrese sus credenciales para continuar en la plataforma.</p>
                    </div>

                    <div class="login-form-layout">
                        <div class="login-field-block">
                            <label for="txtUserName">Usuario</label>
                            <div class="login-input-wrap">
                                <span class="material-symbols-outlined login-input-icon">person</span>
                                <input type="text" id="txtUserName" placeholder="admin" title="Escriba su nombre de usuario registrado." />
                            </div>
                        </div>

                        <div class="login-field-block">
                            <div class="login-label-row">
                                <label for="txtPassword">Contraseña</label>
                                <span class="login-link-text">Cookies activas</span>
                            </div>
                            <div class="login-input-wrap">
                                <span class="material-symbols-outlined login-input-icon">lock</span>
                                <input type="password" id="txtPassword" placeholder="••••••••" title="Escriba la contraseña asociada a su cuenta." />
                            </div>
                        </div>

                        <div class="login-options-row">
                            <label class="login-check-label" for="rememberLogin">
                                <input type="checkbox" id="rememberLogin" checked="checked" disabled="disabled" title="La sesión se mantiene activa mediante cookies." />
                                <span>Sesión persistente con cookies</span>
                            </label>
                        </div>

                        <div class="actions login-actions">
                            <button type="button" id="btnLogin" class="login-submit-button">
                                <span class="material-symbols-outlined">login</span>
                                <span>Ingresar</span>
                            </button>
                        </div>

                        <div id="loginMessage" class="message login-message"></div>
                    </div>

                    <div class="login-card-footer">
                        <div class="login-credentials-box">
                            <span class="login-credentials-title">Credenciales iniciales</span>
                            <p><strong>Usuario:</strong> admin</p>
                            <p><strong>Contraseña:</strong> Admin123*</p>
                        </div>

                        <div class="login-footer-links">
                            <span>Ambiente local de prueba</span>
                            <span>Visual Studio 2015 compatible</span>
                        </div>
                    </div>
                </div>
            </main>

            <div class="login-side-glow">
                <span class="material-symbols-outlined">blur_on</span>
            </div>
        </div>
    </form>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="Scripts/app-common.js"></script>
    <script type="text/javascript">
        $(function () {
            initializeTooltips();

            $("#btnLogin").on("click", function () {
                authenticate();
            });

            $("#txtUserName").on("keypress", function (event) {
                if (event.which === 13) {
                    authenticate();
                }
            });

            $("#txtPassword").on("keypress", function (event) {
                if (event.which === 13) {
                    authenticate();
                }
            });
        });

        function authenticate() {
            var request = {
                UserName: $("#txtUserName").val(),
                Password: $("#txtPassword").val()
            };

            callPageMethod("Login.aspx/Authenticate", { request: request }, function (response) {
                if (!response.Success) {
                    showMessage("#loginMessage", response.Message, true);
                    return;
                }

                window.location.href = response.RedirectUrl;
            });
        }
    </script>
</body>
</html>
