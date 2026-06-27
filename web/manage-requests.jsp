<%-- 
    Document   : manage-requests
    Created on : Jun 24, 2026, 3:14:44 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Ban Quản Lý - Điều Phối Yêu Cầu</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 30px; background-color: #f8f9fa; }
        h2 { color: #343a40; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; background: white; box-shadow: 0 0 10px rgba(0,0,0,0.05); }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #dee2e6; }
        th { background-color: #343a40; color: white; }
        tr:hover { background-color: #f1f3f5; }
        .badge { padding: 5px 10px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .badge-pending { background-color: #ffc107; color: #212529; }
        .badge-process { background-color: #17a2b8; color: white; }
        .badge-done { background-color: #28a745; color: white; }
        .badge-reject { background-color: #dc3545; color: white; }
        .msg { color: green; font-weight: bold; margin-bottom: 15px; }
        .assign-form { display: inline-block; }
        select, input[type="number"] { padding: 5px; border: 1px solid #ccc; border-radius: 4px; }
        button { background-color: #007bff; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; }
        button:hover { background-color: #0056b3; }
    </style>
</head>
<body>

    <h2>Hệ Thống Tiếp Nhận & Điều Phối Yêu Cầu (Dành cho Ban Quản Lý)</h2>
    
    <% if(request.getAttribute("message") != null) { %>
        <div class="msg"><%= request.getAttribute("message") %></div>
    <% } %>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Căn Hộ</th>
                <th>Loại Yêu Cầu</th>
                <th>Tiêu Đề</th>
                <th>Mô Tả</th>
                <th>Trạng Thái</th>
                <th>Nhân Viên Xử Lý</th>
                <th>Thao Tác Điều Phối</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>101</td>
                <td>Phòng 14B</td> <td>Sửa chữa</td>
                <td>Hỏng bóng đèn phòng khách</td>
                <td>Bóng đèn led bị nhấp nháy liên tục không sáng rõ</td>
                <td><span class="badge badge-pending">Chờ duyệt</span></td>
                <td><em>Chưa gán</em></td>
                <td>
                    <form action="ManageRequestServlet" method="POST" class="assign-form">
                        <input type="hidden" name="requestId" value="101">
                        <select name="status">
                            <option value="Đang xử lý">Duyệt & Gán việc</option>
                            <option value="Từ chối">Từ chối</option>
                            <option value="Đã hoàn thành">Đã hoàn thành</option>
                        </select>
                        <input type="number" name="employeeId" placeholder="Nhập ID NV" style="width: 80px;" required>
                        <button type="submit">Cập nhật</button>
                    </form>
                </td>
            </tr>
        </tbody>
    </table>

</body>
</html>
