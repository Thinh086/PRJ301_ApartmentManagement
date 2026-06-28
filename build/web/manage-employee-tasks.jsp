<%-- 
    Document   : manage-employee-tasks
    Author     : Phạm Huy Bách
    Module     : Nhân viên - Cập nhật tiến độ xử lý
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Request"%>
<%@page import="model.User"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Nhân Viên - Công Việc</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">
    <link rel="stylesheet" href="shared.css">
    <style>
        .progress-form { display: flex; flex-direction: column; gap: 6px; }
        .progress-form select, .progress-form textarea {
            padding: 7px 10px; border: 1px solid #e2e8f0; border-radius: 6px;
            font-size: 12px; font-family: inherit; width: 100%;
        }
        .progress-form select:focus, .progress-form textarea:focus { border-color: #2563eb; outline: none; }
        .progress-form textarea { resize: vertical; min-height: 52px; }
        .employee-info { background: linear-gradient(135deg,#1e3a5f,#2563eb); border-radius: 12px; padding: 18px 22px; margin-bottom: 24px; display: flex; align-items: center; gap: 16px; }
        .emp-avatar-lg { width: 46px; height: 46px; border-radius: 50%; background: rgba(255,255,255,0.15); display: flex; align-items: center; justify-content: center; color: #fff; font-size: 18px; font-weight: 600; }
        .emp-details h3 { color: #fff; font-size: 15px; font-weight: 600; }
        .emp-details p { color: rgba(255,255,255,0.6); font-size: 12px; margin-top: 3px; }
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
    <a href="ManageRequestServlet" class="sb-item"><i class="ti ti-clipboard-list"></i> Điều phối yêu cầu</a>
    <a href="TrackProgressServlet" class="sb-item"><i class="ti ti-chart-line"></i> Theo dõi tiến độ</a>
    <a href="EmployeeTaskServlet" class="sb-item active"><i class="ti ti-users"></i> Nhân viên</a>
    <div class="sb-bottom">
        <div class="sb-user">
            <div class="sb-avatar">NV</div>
            <div><div class="sb-uname">Nhân Viên</div><div class="sb-urole">PRJ301 — Nhóm 1</div></div>
        </div>
    </div>
</div>

<div class="main">
    <div class="topbar">
        <div class="topbar-title"><i class="ti ti-users"></i> Nhân viên — công việc</div>
        <div class="topbar-right">
            <a href="index.html" class="btn-topbar"><i class="ti ti-layout-dashboard"></i> Tổng quan</a>
        </div>
    </div>

    <div class="content">
        <% if(request.getAttribute("message") != null) { %>
        <div class="alert alert-success"><i class="ti ti-circle-check"></i> <%= request.getAttribute("message") %></div>
        <% } %>
        <% if(request.getAttribute("error") != null) { %>
        <div class="alert alert-error"><i class="ti ti-alert-circle"></i> <%= request.getAttribute("error") %></div>
        <% } %>

        <%
            List<Request> taskList = (List<Request>) request.getAttribute("taskList");
            User emp = (User) session.getAttribute("employee");
            String empName = emp != null ? emp.getFullName() : "Lê Văn Kỹ Thuật";
            String empInitials = empName.length() >= 2 ? empName.substring(empName.lastIndexOf(" ")+1, empName.lastIndexOf(" ")+2) + empName.substring(0,1) : "NV";
            int processingCount=0, pendingCount=0, doneCount=0, totalCount=0;
            if(taskList!=null){ totalCount=taskList.size();
                for(Request t:taskList){ String s=t.getStatus();
                    if("Đang xử lý".equals(s)) processingCount++;
                    else if("Hoàn thành".equals(s)||"Đã hoàn thành".equals(s)) doneCount++;
                    else pendingCount++;
                }
            }
        %>

        <div class="employee-info">
            <div class="emp-avatar-lg"><%= empInitials %></div>
            <div class="emp-details">
                <h3><i class="ti ti-user" style="margin-right:6px"></i><%= empName %></h3>
                <p>Nhân viên xử lý — đang có <%= processingCount %> việc đang thực hiện</p>
            </div>
        </div>

        <div class="stats">
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Đang xử lý</span><div class="stat-icon icon-blue"><i class="ti ti-refresh"></i></div></div>
                <div class="stat-num"><%= processingCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Chờ xử lý</span><div class="stat-icon icon-amber"><i class="ti ti-clock"></i></div></div>
                <div class="stat-num"><%= pendingCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Hoàn thành</span><div class="stat-icon icon-green"><i class="ti ti-circle-check"></i></div></div>
                <div class="stat-num"><%= doneCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-top"><span class="stat-lbl">Tổng số</span><div class="stat-icon icon-navy"><i class="ti ti-list"></i></div></div>
                <div class="stat-num"><%= totalCount %></div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <div class="card-header-title"><i class="ti ti-list-check"></i> Danh sách công việc được gán</div>
            </div>
            <table>
                <thead>
                    <tr>
                        <th style="width:35px">#</th>
                        <th style="width:80px">Căn hộ</th>
                        <th style="width:80px">Loại</th>
                        <th>Tiêu đề</th>
                        <th style="width:115px">Trạng thái</th>
                        <th>Mô tả / Tiến độ</th>
                        <th style="width:210px">Cập nhật tiến độ</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if(taskList!=null&&!taskList.isEmpty()){ int idx=1;
                            for(Request t:taskList){ String s=t.getStatus();
                                String bc="Chờ duyệt".equals(s)?"badge-pending":"Đã duyệt".equals(s)?"badge-approved":"Đang xử lý".equals(s)?"badge-processing":("Hoàn thành".equals(s)||"Đã hoàn thành".equals(s))?"badge-done":"Từ chối".equals(s)?"badge-reject":"badge-empty";
                                boolean isDone="Hoàn thành".equals(s)||"Đã hoàn thành".equals(s);
                    %>
                    <tr>
                        <td class="td-id"><%= idx++ %></td>
                        <td><span class="apt-code"><%= t.getApartmentCode() %></span></td>
                        <td><span class="type-tag"><%= t.getRequestType() %></span></td>
                        <td class="td-bold"><%= t.getTitle() %></td>
                        <td><span class="badge <%= bc %>"><%= s %></span></td>
                        <td>
                            <div style="font-size:12px;color:#64748b;font-style:italic"><%= t.getDescription()!=null?t.getDescription():"Không có mô tả" %></div>
                            <% if(t.getLatestProgress()!=null){ %><div class="progress-note"><i class="ti ti-message" style="font-size:11px;margin-right:4px"></i><%= t.getLatestProgress() %></div><% } %>
                        </td>
                        <td>
                            <% if(!isDone){ %>
                            <form action="EmployeeTaskServlet" method="POST" class="progress-form">
                                <input type="hidden" name="action" value="updateProgress">
                                <input type="hidden" name="requestId" value="<%= t.getRequestId() %>">
                                <select name="newStatus">
                                    <option value="">-- Chọn trạng thái --</option>
                                    <option value="Đang xử lý" <%= "Đang xử lý".equals(s)?"selected":"" %>>Đang xử lý</option>
                                    <option value="Đã hoàn thành">✓ Đã hoàn thành</option>
                                    <option value="Từ chối">✗ Từ chối</option>
                                </select>
                                <textarea name="description" placeholder="Mô tả cập nhật..."><%= "Đang xử lý".equals(s)?"Đang tiến hành xử lý...":"" %></textarea>
                                <button type="submit" class="btn btn-primary" style="width:100%"><i class="ti ti-send"></i> Cập nhật</button>
                            </form>
                            <% } else { %>
                            <div style="text-align:center;padding:10px;color:#16a34a;font-size:13px;font-weight:600">
                                <i class="ti ti-circle-check" style="font-size:18px;display:block;margin-bottom:4px"></i>Đã hoàn thành
                            </div>
                            <% } %>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr><td colspan="7"><div class="empty-state"><i class="ti ti-clipboard-x"></i><p>Bạn chưa có công việc nào được gán.</p></div></td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <div class="footer">PRJ301 — Nhóm: Thịnh | Cường | Việt | Bách</div>
</div>
</body>
</html>
