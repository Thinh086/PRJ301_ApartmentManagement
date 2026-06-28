<%-- 
    Document   : manage-apartments
    Created on : Jun 24, 2026, 3:17:08 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Apartment"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Quản Lý Căn Hộ</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">
    <link rel="stylesheet" href="shared.css">
    <style>
        .layout { display: grid; grid-template-columns: 1fr 340px; gap: 20px; align-items: start; }
        .form-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf0; padding: 22px; position: sticky; top: 90px; }
        .form-card h3 { font-size: 14px; font-weight: 600; color: #1e3a5f; margin-bottom: 18px; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 8px; }
        .btn-submit { width: 100%; padding: 11px; background: #2563eb; color: white; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background 0.15s; display: flex; align-items: center; justify-content: center; gap: 8px; }
        .btn-submit:hover { background: #1d4ed8; }
        .member-text { font-size: 12px; color: #64748b; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    </style>
</head>
<body>
<div class="sidebar">
    <div class="sb-logo">
        <div class="sb-logo-icon"><i class="ti ti-building"></i></div>
        <div class="sb-logo-title">Quản Lý Chung Cư</div>
        <div class="sb-logo-sub">PRJ301 — FPT University</div>
    </div>
    <div class="sb-section">Điều hướng</div>
    <a href="index.html" class="sb-item"><i class="ti ti-layout-dashboard"></i> Tổng quan</a>
    <a href="ManageApartmentServlet" class="sb-item active"><i class="ti ti-home"></i> Quản lý căn hộ</a>
    <a href="ManageRequestServlet" class="sb-item"><i class="ti ti-clipboard-list"></i> Điều phối yêu cầu</a>
    <a href="TrackProgressServlet" class="sb-item"><i class="ti ti-chart-line"></i> Theo dõi tiến độ</a>
    <a href="EmployeeTaskServlet" class="sb-item"><i class="ti ti-users"></i> Nhân viên</a>
    <div class="sb-bottom">
        <div class="sb-user">
            <div class="sb-avatar">TX</div>
            <div><div class="sb-uname">Ban Quản Lý</div><div class="sb-urole">PRJ301 — Nhóm 1</div></div>
        </div>
    </div>
</div>

<div class="main">
    <div class="topbar">
        <div class="topbar-title"><i class="ti ti-home"></i> Quản lý căn hộ</div>
        <div class="topbar-right">
            <a href="index.html" class="btn-topbar"><i class="ti ti-layout-dashboard"></i> Tổng quan</a>
        </div>
    </div>

    <div class="content">
        <% if(request.getAttribute("message") != null) { %>
        <div class="alert alert-success"><i class="ti ti-circle-check"></i> <%= request.getAttribute("message") %></div>
        <% } %>

        <div class="stats">
            <%
                List<Apartment> listStat = (List<Apartment>) request.getAttribute("apartments");
                int total = listStat != null ? listStat.size() : 0;
                int occupied = 0; int tenanted = 0; int empty = 0;
                if (listStat != null) for (Apartment a : listStat) {
                    if (!"Trống".equals(a.getTenantName()) && !"null".equals(a.getTenantName())) tenanted++;
                    if (!"Chưa có".equals(a.getOwnerName())) occupied++;
                    else empty++;
                }
            %>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Tổng căn hộ</span><div class="stat-icon icon-navy"><i class="ti ti-building"></i></div></div>
                <div class="stat-num"><%= total %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Có chủ hộ</span><div class="stat-icon icon-green"><i class="ti ti-home-check"></i></div></div>
                <div class="stat-num"><%= occupied %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Đang cho thuê</span><div class="stat-icon icon-blue"><i class="ti ti-key"></i></div></div>
                <div class="stat-num"><%= tenanted %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Căn hộ trống</span><div class="stat-icon icon-amber"><i class="ti ti-home-off"></i></div></div>
                <div class="stat-num"><%= empty %></div>
            </div>
        </div>

        <div class="layout">
            <div class="card">
                <div class="card-header">
                    <div class="card-header-title"><i class="ti ti-list"></i> Danh sách căn hộ</div>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th><th>Mã phòng</th><th>Chủ hộ</th><th>Thành viên</th><th>Người thuê</th><th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Apartment> list = (List<Apartment>) request.getAttribute("apartments");
                            if (list != null && !list.isEmpty()) {
                                for (Apartment a : list) {
                                    boolean hasTenant = a.getTenantName() != null && !"Trống".equals(a.getTenantName()) && !"null".equals(a.getTenantName());
                                    String members = a.getMembersList() != null && !"null".equals(a.getMembersList()) && !"Không có".equals(a.getMembersList()) ? a.getMembersList() : "—";
                        %>
                        <tr>
                            <td class="td-id"><%= a.getId() %></td>
                            <td><span class="apt-code"><%= a.getRoomNumber() %></span></td>
                            <td class="td-bold"><%= a.getOwnerName() %></td>
                            <td><span class="member-text" title="<%= members %>"><%= members %></span></td>
                            <td>
                                <% if (hasTenant) { %>
                                    <span class="badge badge-processing"><%= a.getTenantName() %></span>
                                <% } else { %>
                                    <span class="badge badge-empty">Trống</span>
                                <% } %>
                            </td>
                            <td>
                                <button class="btn-icon" onclick="fillForm('<%= a.getId() %>','<%= a.getRoomNumber() %>','<%= a.getOwnerName().equals("Chưa có") ? "" : a.getOwnerName() %>','<%= members.equals("—") ? "" : members %>','<%= hasTenant ? a.getTenantName() : "" %>')" title="Chỉnh sửa">
                                    <i class="ti ti-edit"></i>
                                </button>
                            </td>
                        </tr>
                        <% } } else { %>
                        <tr><td colspan="6"><div class="empty-state"><i class="ti ti-home-off"></i><p>Không có dữ liệu căn hộ.</p></div></td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="form-card">
                <h3><i class="ti ti-edit" style="color:#2563eb"></i> Cập nhật thông tin</h3>
                <form action="ManageApartmentServlet" method="POST">
                    <div class="form-group" style="margin-bottom:12px">
                        <label>ID căn hộ cần sửa</label>
                        <input type="number" id="f-id" name="apartmentId" placeholder="Bấm nút Sửa bên trái" readonly>
                    </div>
                    <div class="form-group" style="margin-bottom:12px">
                        <label>Mã căn hộ</label>
                        <input type="text" id="f-room" name="roomNumber" placeholder="VD: A101" required>
                    </div>
                    <div class="form-group" style="margin-bottom:12px">
                        <label>Họ tên chủ hộ</label>
                        <input type="text" id="f-owner" name="ownerName" placeholder="Tên chủ sở hữu" required>
                    </div>
                    <div class="form-group" style="margin-bottom:12px">
                        <label>Thành viên sinh sống</label>
                        <textarea id="f-members" name="membersList" rows="3" placeholder="Phân cách bằng dấu phẩy"></textarea>
                    </div>
                    <div class="form-group" style="margin-bottom:16px">
                        <label>Người thuê lại (nếu có)</label>
                        <input type="text" id="f-tenant" name="tenantName" placeholder="Bỏ trống nếu chủ tự ở">
                    </div>
                    <button type="submit" class="btn-submit"><i class="ti ti-device-floppy"></i> Lưu thay đổi</button>
                </form>
            </div>
        </div>
    </div>
    <div class="footer">PRJ301 — Nhóm: Thịnh | Cường | Việt | Bách</div>
</div>

<script>
function fillForm(id, room, owner, members, tenant) {
    document.getElementById('f-id').value = id;
    document.getElementById('f-room').value = room;
    document.getElementById('f-owner').value = owner;
    document.getElementById('f-members').value = members;
    document.getElementById('f-tenant').value = tenant;
    document.getElementById('f-id').scrollIntoView({ behavior: 'smooth', block: 'center' });
}
</script>
</body>
</html>
