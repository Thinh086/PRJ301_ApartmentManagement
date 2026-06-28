<%-- 
    Document   : track-progress
    Created on : Jun 28, 2026, 1:02:33 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Request"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Theo Dõi Tiến Độ</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">
    <link rel="stylesheet" href="shared.css">
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
    <a href="ManageRequestServlet" class="sb-item"><i class="ti ti-clipboard-list"></i> Điều phối yêu cầu</a>
    <a href="TrackProgressServlet" class="sb-item active"><i class="ti ti-chart-line"></i> Theo dõi tiến độ</a>
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
        <div class="topbar-title"><i class="ti ti-chart-line"></i> Theo dõi tiến độ</div>
        <div class="topbar-right">
            <a href="ManageRequestServlet" class="btn-topbar"><i class="ti ti-clipboard-list"></i> Điều phối yêu cầu</a>
        </div>
    </div>

    <div class="content">
        <%
            List<Request> progressList = (List<Request>) request.getAttribute("progressList");
            int processingCount = 0, approvedCount = 0;
            if (progressList != null) for (Request r : progressList) {
                if ("Đang xử lý".equals(r.getStatus())) processingCount++;
                else approvedCount++;
            }
            int totalCount = progressList != null ? progressList.size() : 0;
        %>
        <div class="stats">
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Đang theo dõi</span><div class="stat-icon icon-navy"><i class="ti ti-eye"></i></div></div>
                <div class="stat-num"><%= totalCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Đang xử lý</span><div class="stat-icon icon-blue"><i class="ti ti-refresh"></i></div></div>
                <div class="stat-num"><%= processingCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Đã duyệt</span><div class="stat-icon icon-teal"><i class="ti ti-circle-check"></i></div></div>
                <div class="stat-num"><%= approvedCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Có cập nhật</span><div class="stat-icon icon-green"><i class="ti ti-message"></i></div></div>
                <div class="stat-num">
                    <% int withProgress = 0; if(progressList!=null) for(Request r:progressList) if(r.getLatestProgress()!=null) withProgress++; %><%= withProgress %>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <div class="card-header-title"><i class="ti ti-chart-line"></i> Yêu cầu đang được xử lý</div>
            </div>
            <table>
                <thead>
                    <tr>
                        <th style="width:40px">ID</th>
                        <th style="width:80px">Căn hộ</th>
                        <th style="width:80px">Loại</th>
                        <th>Tiêu đề</th>
                        <th style="width:115px">Trạng thái</th>
                        <th style="width:140px">Nhân viên xử lý</th>
                        <th>Tiến độ mới nhất</th>
                        <th style="width:130px">Ngày gửi</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (progressList != null && !progressList.isEmpty()) {
                            for (Request req : progressList) {
                                String bc = "Đang xử lý".equals(req.getStatus()) ? "badge-processing" : "badge-approved";
                    %>
                    <tr>
                        <td class="td-id"><%= req.getRequestId() %></td>
                        <td><span class="apt-code"><%= req.getApartmentCode() %></span></td>
                        <td><span class="type-tag"><%= req.getRequestType() %></span></td>
                        <td class="td-bold"><%= req.getTitle() %></td>
                        <td><span class="badge <%= bc %>"><%= req.getStatus() %></span></td>
                        <td><span class="emp-name"><%= req.getAssignedEmployeeName() %></span></td>
                        <td>
                            <% if (req.getLatestProgress() != null) { %>
                                <div class="progress-note"><i class="ti ti-message" style="font-size:11px;margin-right:4px"></i><%= req.getLatestProgress() %></div>
                            <% } else { %>
                                <span style="color:#94a3b8;font-size:12px;font-style:italic">Chưa có cập nhật</span>
                            <% } %>
                        </td>
                        <td style="color:#94a3b8;font-size:12px"><%= req.getCreatedAt() %></td>
                    </tr>
                    <% } } else { %>
                    <tr><td colspan="8"><div class="empty-state"><i class="ti ti-chart-line"></i><p>Không có yêu cầu nào đang được xử lý.</p></div></td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <div class="footer">PRJ301 — Nhóm: Thịnh | Cường | Việt | Bách</div>
</div>
</body>
</html>
