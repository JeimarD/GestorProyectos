<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Users.aspx.cs" Inherits="Presentation.Pages.Users" %>
<asp:Content ID="UsersTitle" ContentPlaceHolderID="HeadTitle" runat="server">Gestión de usuarios</asp:Content>
<asp:Content ID="UsersHead" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
</asp:Content>
<asp:Content ID="UsersTopbarLeft" ContentPlaceHolderID="TopbarLeftContent" runat="server">
    <div class="dashboard-search-box">
        <span class="material-symbols-outlined">search</span>
        <input type="text" id="filterQuickSearch" placeholder="Buscar por nombre o cédula..." title="Búsqueda rápida por nombre, apellido o cédula." />
    </div>
</asp:Content>
<asp:Content ID="UsersMain" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="userId" value="0" />
    <div class="dashboard-content users-content">
        <section class="users-page-header">
            <div>
                <h2>Directorio de usuarios</h2>
                <p>Administra miembros de la organización, roles y datos de identidad.</p>
            </div>
            <button type="button" class="users-primary-button" id="btnHeaderCreateUser"><span class="material-symbols-outlined">person_add</span><span>Agregar usuario</span></button>
        </section>

        <section class="users-metrics-row"><article class="users-metric-card"><p>Total usuarios</p><h3 id="usersCountValue">0</h3><div class="users-metric-foot">Directorio cargado desde base de datos</div></article></section>

        <section class="users-table-panel">
            <div class="users-table-panel-head"><div><span class="users-panel-dot"></span><h3>Inscripciones recientes</h3></div><div class="users-role-filter-bar"><button type="button" class="users-role-chip is-active" data-role-filter="">Todos los roles</button><button type="button" class="users-role-chip" data-role-name="Administrador">Administrador</button><button type="button" class="users-role-chip" data-role-name="Colaborador">Colaborador</button></div></div>
            <div class="users-advanced-filters">
                <div class="users-filter-field"><label for="filterFirstName">Nombre</label><input type="text" id="filterFirstName" title="Filtra por nombre del usuario." /></div>
                <div class="users-filter-field"><label for="filterLastName">Apellido</label><input type="text" id="filterLastName" title="Filtra por apellido del usuario." /></div>
                <div class="users-filter-field"><label for="filterIdentification">Cédula</label><input type="text" id="filterIdentification" title="Filtra por número de cédula." /></div>
                <div class="users-filter-field"><label for="filterRole">Rol</label><select id="filterRole" title="Filtra por rol asignado."></select></div>
            </div>
            <div class="users-filter-actions"><button type="button" id="btnSearchUsers" class="users-secondary-button is-solid">Buscar</button><button type="button" id="btnResetUsers" class="users-secondary-button">Limpiar</button></div>
            <div class="users-table-wrapper"><table class="users-data-table"><thead><tr><th>Nombre</th><th>Cédula</th><th>Género</th><th>Fecha nac.</th><th>Estado civil</th><th>Rol</th><th></th></tr></thead><tbody id="usersTableBody"></tbody></table></div>
            <div class="users-table-footer"><p id="usersSummaryText">Mostrando 0 usuarios</p><div class="users-pagination-mock" id="usersPagination"></div></div>
        </section>
    </div>

    <div class="users-modal-overlay is-hidden" id="userModal">
        <div class="users-modal-backdrop" id="userModalBackdrop"></div>
        <div class="users-modal-card">
            <div class="users-modal-header"><div><h3 id="userModalTitle">Nueva inscripción de usuario</h3><p>Complete la identidad básica y los permisos del rol.</p></div><button type="button" class="users-close-button" id="btnCloseUserModal"><span class="material-symbols-outlined">close</span></button></div>
            <div class="users-modal-body">
                <div class="users-modal-grid"><div class="users-modal-field"><label class="users-label-row" for="firstName"><span>Nombre</span><span class="material-symbols-outlined users-help-icon" title="Nombre legal según documento.">info</span></label><input type="text" id="firstName" title="Ingrese el nombre del usuario." placeholder="Ej. Adrián" /></div><div class="users-modal-field"><label class="users-label-row" for="lastName"><span>Apellidos</span><span class="material-symbols-outlined users-help-icon" title="Se recomienda registrar ambos apellidos.">info</span></label><input type="text" id="lastName" title="Ingrese el apellido del usuario." placeholder="Ej. Álvarez" /></div></div>
                <div class="users-modal-grid"><div class="users-modal-field"><label class="users-label-row" for="identification"><span>ID (Cédula)</span><span class="material-symbols-outlined users-help-icon" title="Ingrese el número usado por la organización.">info</span></label><input type="text" id="identification" title="Ingrese la cédula del usuario." placeholder="Número de identificación" /></div><div class="users-modal-field"><label for="genderId">Género</label><select id="genderId" title="Seleccione el género del usuario."></select></div></div>
                <div class="users-modal-grid"><div class="users-modal-field"><label for="birthDate">Fecha de nacimiento</label><input type="text" id="birthDate" title="Seleccione la fecha de nacimiento." placeholder="Seleccione una fecha" /></div><div class="users-modal-field"><label for="maritalStatusId">Estado civil</label><select id="maritalStatusId" title="Seleccione el estado civil del usuario."></select></div></div>
                <div class="users-modal-grid"><div class="users-modal-field"><label class="users-label-row" for="roleId"><span>Rol funcional</span><span class="material-symbols-outlined users-help-icon" title="Determina los permisos dentro del sistema.">info</span></label><select id="roleId" title="Seleccione el rol del usuario."></select></div><div class="users-modal-field"><label for="userName">Usuario</label><input type="text" id="userName" title="Ingrese el usuario para iniciar sesión." placeholder="Usuario de acceso" /></div></div>
                <div class="users-modal-grid"><div class="users-modal-field"><label for="password">Contraseña</label><input type="password" id="password" title="Ingrese la contraseña. En edición es opcional." placeholder="Contraseña de acceso" /></div><div class="users-modal-field users-toggle-field"><label for="isActive">Estado del perfil</label><label class="users-switch-line"><input type="checkbox" id="isActive" checked="checked" title="Indica si el usuario puede acceder al sistema." /><span>Usuario activo</span></label></div></div>
                <div id="userMessage" class="message users-message"></div>
            </div>
            <div class="users-modal-footer"><button type="button" class="users-secondary-button" id="btnNewUser">Cancelar</button><button type="button" class="users-primary-button" id="btnSaveUser">Guardar perfil</button></div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="../Scripts/app-common.js"></script>
    <script type="text/javascript">
        var usersCache = [];
        var filteredUsersCache = [];
        var rolesCache = [];
        var usersCurrentPage = 1;
        var usersPageSize = 10;
        $(function () {
            initializeTooltips();
            initializeDatePicker("#birthDate");
            loadInitialUsersData();
            $("#btnSearchUsers").on("click", searchUsers);
            $("#btnResetUsers").on("click", resetUserFilters);
            $("#btnSaveUser").on("click", saveUser);
            $("#btnNewUser").on("click", resetAndCloseModal);
            $("#btnHeaderCreateUser").on("click", openCreateUserModal);
            $("#btnCloseUserModal, #userModalBackdrop").on("click", closeUserModal);
            $("#filterQuickSearch").on("keyup", handleQuickSearch);
            $(".users-role-chip").on("click", function () {
                var roleName = $(this).data("roleName") || "";
                $(".users-role-chip").removeClass("is-active");
                $(this).addClass("is-active");
                if (roleName === "") { $("#filterRole").val(""); } else {
                    var matchingRole = $.grep(rolesCache, function (role) { return role.Name === roleName; })[0];
                    $("#filterRole").val(matchingRole ? matchingRole.Id : "");
                }
                searchUsers();
            });
        });

        function loadInitialUsersData() { callPageMethod("Users.aspx/GetInitialData", {}, function (response) { rolesCache = response.Data.Roles || []; populateSelect("#filterRole", response.Data.Roles, true); populateSelect("#roleId", response.Data.Roles, false); populateSelect("#genderId", response.Data.Genders, false); populateSelect("#maritalStatusId", response.Data.MaritalStatuses, false); usersCache = sortUsersByName(response.Data.Users || []); filteredUsersCache = usersCache.slice(0); usersCurrentPage = 1; renderUsersTable(filteredUsersCache); }); }
        function searchUsers() { var filter = { FirstName: emptyStringToNull($.trim($("#filterFirstName").val())), LastName: emptyStringToNull($.trim($("#filterLastName").val())), Identification: emptyStringToNull($.trim($("#filterIdentification").val())), RoleId: emptyToNullableInt($("#filterRole").val()) }; callPageMethod("Users.aspx/SearchUsers", { filter: filter }, function (response) { usersCache = sortUsersByName(response.Data || []); filteredUsersCache = usersCache.slice(0); usersCurrentPage = 1; renderUsersTable(filteredUsersCache); }); }
        function saveUser() { var user = { UserId: parseInt($("#userId").val(), 10) || 0, FirstName: $("#firstName").val(), LastName: $("#lastName").val(), Identification: $("#identification").val(), BirthDate: toIsoDate($("#birthDate").val()), RoleId: parseInt($("#roleId").val(), 10) || 0, GenderId: parseInt($("#genderId").val(), 10) || 0, MaritalStatusId: parseInt($("#maritalStatusId").val(), 10) || 0, UserName: $("#userName").val(), Password: $("#password").val(), IsActive: $("#isActive").is(":checked") }; callPageMethod("Users.aspx/SaveUser", { user: user }, function (response) { showMessage("#userMessage", response.Message, !response.Success); if (response.Success) { clearUserForm(); closeUserModal(); searchUsers(); } }); }
        function editUser(userId) { var user = findById(usersCache, "UserId", userId); if (!user) { return; } $("#userId").val(user.UserId); $("#firstName").val(user.FirstName); $("#lastName").val(user.LastName); $("#identification").val(user.Identification); $("#birthDate").val(formatJsonDate(user.BirthDate)); $("#roleId").val(user.RoleId); $("#genderId").val(user.GenderId); $("#maritalStatusId").val(user.MaritalStatusId); $("#userName").val(user.UserName); $("#password").val(""); $("#isActive").prop("checked", user.IsActive); $("#userModalTitle").text("Editar perfil de usuario"); setUserModalState(true); }
        function deleteUser(userId) { if (!confirm("¿Desea desactivar este usuario?")) { return; } callPageMethod("Users.aspx/DeleteUser", { userId: userId }, function (response) { alert(response.Message); searchUsers(); }); }
        function clearUserForm() { $("#userId").val("0"); $("#firstName, #lastName, #identification, #birthDate, #userName, #password").val(""); $("#roleId, #genderId, #maritalStatusId").prop("selectedIndex", 0); $("#isActive").prop("checked", true); showMessage("#userMessage", "", false); $("#userModalTitle").text("Nueva inscripción de usuario"); }
        function resetUserFilters() { $("#filterFirstName, #filterLastName, #filterIdentification, #filterQuickSearch").val(""); $("#filterRole").val(""); $(".users-role-chip").removeClass("is-active"); $(".users-role-chip[data-role-filter='']").addClass("is-active"); searchUsers(); }
        function renderUsersTable(users) {
            var list = $.makeArray(users || []);
            var total = list.length;
            var totalPages = Math.max(1, Math.ceil(total / usersPageSize));
            if (usersCurrentPage > totalPages) { usersCurrentPage = totalPages; }
            if (usersCurrentPage < 1) { usersCurrentPage = 1; }
            var startIndex = (usersCurrentPage - 1) * usersPageSize;
            var endIndex = startIndex + usersPageSize;
            var pageUsers = list.slice(startIndex, endIndex);
            var rows = $.map(pageUsers, function (user) { var initials = getInitials(user.FirstName, user.LastName); var roleClass = user.RoleName === "Administrador" ? "is-primary" : "is-muted"; var maritalClass = user.MaritalStatusName === "Casado" ? "is-teal" : "is-secondary"; return "<tr class='users-row'><td><div class='users-name-cell'><div class='users-avatar-badge'>" + htmlEncode(initials) + "</div><span>" + htmlEncode(user.FirstName + " " + user.LastName) + "</span></div></td><td>" + htmlEncode(user.Identification) + "</td><td>" + htmlEncode(user.GenderName) + "</td><td>" + htmlEncode(formatDisplayDate(user.BirthDate)) + "</td><td><span class='users-pill " + maritalClass + "'>" + htmlEncode(user.MaritalStatusName) + "</span></td><td><span class='users-pill " + roleClass + "'>" + htmlEncode(user.RoleName) + "</span></td><td class='users-actions-cell'><button type='button' class='users-row-action' onclick='editUser(" + user.UserId + ")'><span class='material-symbols-outlined'>edit</span></button><button type='button' class='users-row-action users-row-action-danger' onclick='deleteUser(" + user.UserId + ")'><span class='material-symbols-outlined'>person_off</span></button></td></tr>"; }); $("#usersTableBody").html(rows.join("") || "<tr><td colspan='7' class='users-empty-row'>No hay registros.</td></tr>"); updateUsersSummary(total, startIndex, Math.min(endIndex, total)); renderUsersPagination(totalPages); }
        function updateUsersSummary(total, start, end) { $("#usersCountValue").text(total); if (total === 0) { $("#usersSummaryText").text("Mostrando 0 usuarios"); return; } $("#usersSummaryText").text("Mostrando " + (start + 1) + " - " + end + " de " + total + " usuarios"); }
        function renderUsersPagination(totalPages) { if (totalPages <= 1) { $("#usersPagination").html(""); return; } var html = []; html.push("<button type='button' class='users-page-button' " + (usersCurrentPage === 1 ? "disabled='disabled'" : "") + " onclick='changeUsersPage(" + (usersCurrentPage - 1) + ")'><span class='material-symbols-outlined'>chevron_left</span></button>"); for (var page = 1; page <= totalPages; page++) { html.push("<button type='button' class='users-page-button " + (page === usersCurrentPage ? "is-current" : "") + "' onclick='changeUsersPage(" + page + ")'>" + page + "</button>"); } html.push("<button type='button' class='users-page-button' " + (usersCurrentPage === totalPages ? "disabled='disabled'" : "") + " onclick='changeUsersPage(" + (usersCurrentPage + 1) + ")'><span class='material-symbols-outlined'>chevron_right</span></button>"); $("#usersPagination").html(html.join("")); }
        function changeUsersPage(page) { usersCurrentPage = page; renderUsersTable(filteredUsersCache); }
        function openCreateUserModal() { clearUserForm(); setUserModalState(true); }
        function closeUserModal() { setUserModalState(false); }
        function resetAndCloseModal() { clearUserForm(); closeUserModal(); }
        function setUserModalState(isOpen) { $("#userModal").toggleClass("is-hidden", !isOpen); $("body").toggleClass("users-modal-open", isOpen); }
        function handleQuickSearch() { var searchValue = $.trim($("#filterQuickSearch").val()).toLowerCase(); if (searchValue === "") { filteredUsersCache = usersCache.slice(0); usersCurrentPage = 1; renderUsersTable(filteredUsersCache); return; } filteredUsersCache = $.grep(usersCache, function (user) { var fullName = ((user.FirstName || "") + " " + (user.LastName || "")).toLowerCase(); return fullName.indexOf(searchValue) >= 0 || ((user.Identification || "").toLowerCase().indexOf(searchValue) >= 0); }); usersCurrentPage = 1; renderUsersTable(filteredUsersCache); }
        function sortUsersByName(users) { var sorted = $.makeArray(users || []).slice(0); sorted.sort(function (left, right) { var leftName = $.trim((left.FirstName || "") + " " + (left.LastName || "")); var rightName = $.trim((right.FirstName || "") + " " + (right.LastName || "")); return leftName.localeCompare(rightName); }); return sorted; }
        function getInitials(firstName, lastName) { var first = firstName ? firstName.substring(0, 1) : ""; var last = lastName ? lastName.substring(0, 1) : ""; return (first + last).toUpperCase(); }
        function formatDisplayDate(value) { var normalized = formatJsonDate(value); if (!normalized) { return ""; } var parts = normalized.split("-"); return parts.length === 3 ? parts[2] + "/" + parts[1] + "/" + parts[0] : normalized; }
    </script>
</asp:Content>
