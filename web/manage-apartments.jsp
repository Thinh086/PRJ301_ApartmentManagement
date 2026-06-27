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
        <title>Quản Lý Thông Tin Căn Hộ</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 30px;
                background-color: #f8f9fa;
            }
            h2 {
                color: #343a40;
                margin-bottom: 20px;
            }
            .container {
                display: flex;
                gap: 30px;
            }
            .table-box {
                flex: 2;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                background: white;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                border-radius: 8px;
                overflow: hidden;
            }
            th, td {
                padding: 12px 15px;
                text-align: left;
                border-bottom: 1px solid #dee2e6;
            }
            th {
                background-color: #007bff;
                color: white;
                font-weight: bold;
            }
            tr:hover {
                background-color: #f1f3f5;
            }
            .form-box {
                flex: 1;
                background: white;
                padding: 25px;
                border-radius: 8px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                height: fit-content;
            }
            .form-box h3 {
                margin-top: 0;
                color: #007bff;
                border-bottom: 2px solid #007bff;
                padding-bottom: 8px;
            }
            .form-group {
                margin-bottom: 15px;
            }
            .form-group label {
                display: block;
                margin-bottom: 6px;
                font-weight: bold;
                color: #495057;
            }
            .form-group input, .form-group textarea {
                width: 100%;
                padding: 10px;
                box-sizing: border-box;
                border: 1px solid #ced4da;
                border-radius: 4px;
                font-size: 14px;
            }
            .form-group input:focus, .form-group textarea:focus {
                border-color: #80bdff;
                outline: none;
            }
            button.btn-submit {
                background-color: #28a745;
                color: white;
                border: none;
                padding: 12px;
                border-radius: 4px;
                cursor: pointer;
                width: 100%;
                font-size: 16px;
                font-weight: bold;
            }
            button.btn-submit:hover {
                background-color: #218838;
            }
            .btn-action {
                background-color: #ffc107;
                color: #212529;
                border: none;
                padding: 6px 12px;
                border-radius: 4px;
                cursor: pointer;
                font-weight: bold;
            }
            .btn-action:hover {
                background-color: #e0a800;
            }
            .badge {
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 12px;
                font-weight: bold;
                color: white;
            }
            .bg-primary { background-color: #007bff; }
            .bg-success { background-color: #28a745; }
            .bg-secondary { background-color: #6c757d; }
            .msg {
                background-color: #d4edda;
                color: #155724;
                padding: 12px;
                border-radius: 4px;
                margin-bottom: 20px;
                border-left: 5px solid #28a745;
                font-weight: bold;
            }
        </style>
    </head>
    <body>

        <h2>Hệ Thống Quản Lý Thông Tin Căn Hộ (Dành cho Ban Quản Lý)</h2>

        <% if(request.getAttribute("message") != null) { %>
        <div class="msg"><%= request.getAttribute("message") %></div>
        <% } %>

        <div class="container">
            <div class="table-box">
                <table>
                    <thead>
                        <tr>
                            <th>ID Căn Hộ</th>
                            <th>Số Phòng</th>
                            <th>Chủ Hộ (Chính chủ)</th>
                            <th>Thành Viên Sinh Sống</th>
                            <th>Người Thuê Lại</th>
                            <th>Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            List<Apartment> list = (List<Apartment>) request.getAttribute("apartments");
                            if(list != null && !list.isEmpty()) {
                                for(Apartment a : list) {
                        %>
                        <tr>
                            <td><strong><%= a.getId() %></strong></td>
                            <td><span class="badge bg-primary"><%= a.getRoomNumber() %></span></td>
                            <td><%= a.getOwnerName() %></td>
                            <td><%= (a.getMembersList() != null && !a.getMembersList().equals("null")) ? a.getMembersList() : "Trống" %></td>
                            <td>
                                <span class="badge <%= a.getTenantName().equals("Trống") ? "bg-secondary" : "bg-success" %>">
                                    <%= a.getTenantName() %>
                                </span>
                            </td>
                            <td>
                                <button type="button" class="btn-action" onclick="fillForm('<%= a.getId() %>', '<%= a.getRoomNumber() %>', '<%= a.getOwnerName() %>', '<%= a.getMembersList() %>', '<%= a.getTenantName() %>')">
                                    Chọn Sửa
                                </button>
                            </td>
                        </tr>
                        <% 
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="6" class="text-center text-muted" style="text-align: center; padding: 20px;">Không có dữ liệu căn hộ nào được tìm thấy.</td>
                        </tr>
                        <% 
                            } 
                        %>
                    </tbody>
                </table>
            </div>

            <div class="form-box">
                <h3>Cập Nhật Thông Tin</h3>
                <form action="ManageApartmentServlet" method="POST">
                    <div class="form-group">
                        <label>ID Căn Hộ Cần Sửa:</label>
                        <input type="number" id="form-id" name="apartmentId" placeholder="Chọn căn hộ trên bảng để sửa" readonly style="background-color: #e9ecef; cursor: not-allowed;">
                    </div>
                    <div class="form-group">
                        <label>Số Phòng / Mã Căn Hộ:</label>
                        <input type="text" id="form-room" name="roomNumber" placeholder="Ví dụ: P101, P102" required>
                    </div>
                    <div class="form-group">
                        <label>Họ Tên Chủ Hộ:</label>
                        <input type="text" id="form-owner" name="ownerName" placeholder="Tên chủ sở hữu căn hộ" required>
                    </div>
                    <div class="form-group">
                        <label>Các Thành Viên Sinh Sống:</label>
                        <textarea id="form-members" name="membersList" rows="3" placeholder="Các thành viên (phân cách bằng dấu phẩy)"></textarea>
                    </div>
                    <div class="form-group">
                        <label>Họ Tên Người Thuê Lại (Nếu có):</label>
                        <input type="text" id="form-tenant" name="tenantName" placeholder="Bỏ trống hoặc ghi 'Trống' nếu chủ tự ở">
                    </div>
                    <button type="submit" class="btn-submit">Lưu Thay Đổi</button>
                </form>
            </div>
        </div>

        <script>
            function fillForm(id, room, owner, members, tenant) {
                document.getElementById('form-id').value = id;
                document.getElementById('form-room').value = room;
                document.getElementById('form-owner').value = owner;
                document.getElementById('form-members').value = (members === 'null' || members === 'Thực tế không có') ? '' : members;
                document.getElementById('form-tenant').value = (tenant === 'Trống') ? '' : tenant;
            }
        </script>
    </body>
</html>