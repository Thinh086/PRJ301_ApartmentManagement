<%-- 
    Document   : manage-requests
    Created on : Jun 24, 2026, 3:14:44 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Request"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Điều Phối Yêu Cầu</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">
    <link rel="stylesheet" href="shared.css">
    <style>
        .assign-wrap { display: flex; flex-direction: column; gap: 6px; }
        .assign-row { display: flex; gap: 6px; align-items: center; }
        .assign-row select { flex: 1; padding: 7px 8px; border: 1px solid #e2e8f0; border-radius: 6px; font-size: 12px; color: #475569; }
        .assign-row select:focus { border-color: #2563eb; outline: none; }
        .assign-row input { width: 70px; padding: 7px 8px; border: 1px solid #e2e8f0; border-radius: 6px; font-size: 12px; }
        .assign-row input:focus { border-color: #2563eb; outline: none; }
        .hint { font-size: 11px; color: #94a3b8; }
        .desc-text { font-size: 12px; color: #64748b; max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
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
    <a href="ManageApartmentServlet" class="sb-item"><i class="ti ti-home"></i> Quản lý căn hộ</a>
    <a href="ManageRequestServlet" class="sb-item active"><i class="ti ti-clipboard-list"></i> Điều phối yêu cầu</a>
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
        <div class="topbar-title"><i class="ti ti-clipboard-list"></i> Điều phối yêu cầu</div>
        <div class="topbar-right">
            <a href="TrackProgressServlet" class="btn-topbar"><i class="ti ti-chart-line"></i> Theo dõi tiến độ</a>
        </div>
    </div>

    <div class="content">
        <% if(request.getAttribute("message") != null) { %>
        <div class="alert alert-success"><i class="ti ti-circle-check"></i> <%= request.getAttribute("message") %></div>
        <% } %>

        <%
            List<Request> requestList = (List<Request>) request.getAttribute("requestList");
            int pending = 0, processing = 0, done = 0, total = 0;
            if (requestList != null) { total = requestList.size();
                for (Request r : requestList) {
                    if ("Chờ duyệt".equals(r.getStatus())) pending++;
                    else if ("Đang xử lý".equals(r.getStatus()) || "Đã duyệt".equals(r.getStatus())) processing++;
                    else if ("Hoàn thành".equals(r.getStatus()) || "Đã hoàn thành".equals(r.getStatus())) done++;
                }
            }
        %>
        <div class="stats">
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Tổng yêu cầu</span><div class="stat-icon icon-navy"><i class="ti ti-list"></i></div></div>
                <div class="stat-num"><%= total %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Chờ duyệt</span><div class="stat-icon icon-amber"><i class="ti ti-clock"></i></div></div>
                <div class="stat-num"><%= pending %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Đang xử lý</span><div class="stat-icon icon-blue"><i class="ti ti-refresh"></i></div></div>
                <div class="stat-num"><%= processing %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Hoàn thành</span><div class="stat-icon icon-green"><i class="ti ti-circle-check"></i></div></div>
                <div class="stat-num"><%= done %></div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <div class="card-header-title"><i class="ti ti-clipboard-list"></i> Danh sách yêu cầu</div>
            </div>
            <table>
                <thead>
                    <tr>
                        <th style="width:40px">ID</th>
                        <th style="width:70px">Căn hộ</th>
                        <th style="width:80px">Loại</th>
                        <th>Tiêu đề</th>
                        <th style="width:160px">Mô tả</th>
                        <th style="width:110px">Trạng thái</th>
                        <th style="width:120px">Nhân viên</th>
                        <th style="width:220px">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (requestList != null && !requestList.isEmpty()) {
                            for (Request req : requestList) {
                                String s = req.getStatus();
                                String bc = "Chờ duyệt".equals(s) ? "badge-pending"
                                    : ("Đang xử lý".equals(s)||"Đã duyệt".equals(s)) ? "badge-processing"
                                    : ("Hoàn thành".equals(s)||"Đã hoàn thành".equals(s)) ? "badge-done"
                                    : "Từ chối".equals(s) ? "badge-reject" : "badge-empty";
                    %>
                    <tr>
                        <td class="td-id"><%= req.getRequestId() %></td>
                        <td><span class="apt-code"><%= req.getApartmentCode() %></span></td>
                        <td><span class="type-tag"><%= req.getRequestType() %></span></td>
                        <td class="td-bold"><%= req.getTitle() %></td>
                        <td><span class="desc-text" title="<%= req.getDescription() != null ? req.getDescription() : "" %>"><%= req.getDescription() != null ? req.getDescription() : "—" %></span></td>
                        <td><span class="badge <%= bc %>"><%= s %></span></td>
                        <td><span class="emp-name"><%= req.getAssignedEmployeeName() %></span></td>
                        <td>
                            <form action="ManageRequestServlet" method="POST" class="assign-wrap">
                                <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                                <div class="assign-row">
                                    <select name="status">
                                        <option value="Đang xử lý">✔ Duyệt & gán</option>
                                        <option value="Từ chối">✗ Từ chối</option>
                                        <option value="Đã hoàn thành">✓ Hoàn thành</option>
                                    </select>
                                    <input type="number" name="employeeId" placeholder="ID NV">
                                    <button type="submit" class="btn btn-primary" style="white-space:nowrap;padding:7px 10px"><i class="ti ti-send"></i></button>
                                </div>
                                <span class="hint">Nhập ID nhân viên để gán việc</span>
                            </form>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr><td colspan="8"><div class="empty-state"><i class="ti ti-clipboard-x"></i><p>Chưa có yêu cầu nào.</p></div></td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <div class="footer">PRJ301 — Nhóm: Thịnh | Cường | Việt | Bách</div>
</div>
</body>
</html>
