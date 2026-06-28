package controller;

import dal.DBContext;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Request;

public class ManageRequestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Request> requestList = new ArrayList<>();
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            // Lấy danh sách yêu cầu kèm thông tin căn hộ, người gửi, nhân viên được gán
            String sql = "SELECT r.request_id, r.apartment_id, r.account_id, r.request_type, "
                       + "       r.title, r.description, r.status, r.created_at, "
                       + "       a.apartment_code, ac.full_name AS requester_name, "
                       + "       emp.full_name AS employee_name, ra.assigned_to "
                       + "FROM ServiceRequest r "
                       + "JOIN Apartment a ON a.apartment_id = r.apartment_id "
                       + "JOIN Account ac ON ac.account_id = r.account_id "
                       + "LEFT JOIN RequestAssignment ra ON ra.request_id = r.request_id "
                       + "LEFT JOIN Account emp ON emp.account_id = ra.assigned_to "
                       + "ORDER BY r.created_at DESC";
            
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Request req = new Request();
                req.setRequestId(rs.getInt("request_id"));
                req.setApartmentId(rs.getInt("apartment_id"));
                req.setAccountId(rs.getInt("account_id"));
                req.setRequestType(rs.getString("request_type"));
                req.setTitle(rs.getString("title"));
                req.setDescription(rs.getString("description"));
                req.setStatus(rs.getString("status"));
                req.setCreatedAt(rs.getString("created_at"));
                req.setApartmentCode(rs.getString("apartment_code"));
                req.setRequesterName(rs.getString("requester_name"));
                
                String empName = rs.getString("employee_name");
                req.setAssignedEmployeeName(empName != null ? empName : "Chưa gán");
                
                int assignedTo = rs.getInt("assigned_to");
                req.setAssignedTo(rs.wasNull() ? null : assignedTo);
                
                requestList.add(req);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
        
        request.setAttribute("requestList", requestList);
        request.getRequestDispatcher("manage-requests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy dữ liệu từ Form phê duyệt / điều phối của Ban Quản Lý
        String requestIdStr = request.getParameter("requestId");
        String status = request.getParameter("status");
        String employeeIdStr = request.getParameter("employeeId");

        if (requestIdStr != null && status != null) {
            int requestId = Integer.parseInt(requestIdStr);
            DBContext db = new DBContext();
            Connection conn = null;
            PreparedStatement psUpdateReq = null;
            PreparedStatement psCheckAssign = null;
            PreparedStatement psUpdateAssign = null;
            PreparedStatement psInsertAssign = null;

            try {
                conn = db.getConnection();
                conn.setAutoCommit(false);

                // 1. Cập nhật trạng thái của yêu cầu trong bảng ServiceRequest
                String sqlUpdateReq = "UPDATE ServiceRequest SET status = ? WHERE request_id = ?";
                psUpdateReq = conn.prepareStatement(sqlUpdateReq);
                psUpdateReq.setString(1, status);
                psUpdateReq.setInt(2, requestId);
                psUpdateReq.executeUpdate();

                // 2. Nếu có chọn nhân viên, tiến hành gán việc vào bảng RequestAssignment
                if (employeeIdStr != null && !employeeIdStr.isEmpty()) {
                    int employeeId = Integer.parseInt(employeeIdStr);

                    // Kiểm tra xem yêu cầu này đã từng được gán cho ai chưa
                    String sqlCheck = "SELECT * FROM RequestAssignment WHERE request_id = ?";
                    psCheckAssign = conn.prepareStatement(sqlCheck);
                    psCheckAssign.setInt(1, requestId);
                    ResultSet rsCheck = psCheckAssign.executeQuery();

                    if (rsCheck.next()) {
                        // Nếu đã có bản ghi gán việc trước đó, cập nhật nhân viên mới
                        String sqlUpdate = "UPDATE RequestAssignment SET assigned_to = ?, assigned_at = GETDATE() WHERE request_id = ?";
                        psUpdateAssign = conn.prepareStatement(sqlUpdate);
                        psUpdateAssign.setInt(1, employeeId);
                        psUpdateAssign.setInt(2, requestId);
                        psUpdateAssign.executeUpdate();
                        
                        // Cũng thêm bản ghi vào RequestProgress
                        String sqlProgress = "INSERT INTO RequestProgress (request_id, account_id, status, description) VALUES (?, ?, ?, ?)";
                        PreparedStatement psProgress = conn.prepareStatement(sqlProgress);
                        psProgress.setInt(1, requestId);
                        psProgress.setInt(2, employeeId);
                        psProgress.setString(3, status);
                        psProgress.setString(4, "Đã được phân công xử lý");
                        psProgress.executeUpdate();
                        psProgress.close();
                    } else {
                        // Nếu chưa có, thêm mới bản ghi gán việc
                        String sqlInsert = "INSERT INTO RequestAssignment (request_id, assigned_by, assigned_to, note) VALUES (?, ?, ?, ?)";
                        psInsertAssign = conn.prepareStatement(sqlInsert);
                        psInsertAssign.setInt(1, requestId);
                        psInsertAssign.setInt(2, 2); // Mặc định admin/quản lý ID=2
                        psInsertAssign.setInt(3, employeeId);
                        psInsertAssign.setString(4, "Được giao xử lý");
                        psInsertAssign.executeUpdate();
                        
                        // Thêm bản ghi vào RequestProgress
                        String sqlProgress = "INSERT INTO RequestProgress (request_id, account_id, status, description) VALUES (?, ?, ?, ?)";
                        PreparedStatement psProgress = conn.prepareStatement(sqlProgress);
                        psProgress.setInt(1, requestId);
                        psProgress.setInt(2, employeeId);
                        psProgress.setString(3, status);
                        psProgress.setString(4, "Đã được phân công xử lý");
                        psProgress.executeUpdate();
                        psProgress.close();
                    }
                    if (rsCheck != null) rsCheck.close();
                }

                conn.commit();
                request.setAttribute("message", "Cập nhật yêu cầu thành công!");

            } catch (Exception e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
                }
                e.printStackTrace();
                request.setAttribute("error", "Có lỗi xảy ra!");
            } finally {
                try {
                    if (psUpdateReq != null) psUpdateReq.close();
                    if (psCheckAssign != null) psCheckAssign.close();
                    if (psUpdateAssign != null) psUpdateAssign.close();
                    if (psInsertAssign != null) psInsertAssign.close();
                    if (conn != null) conn.close();
                } catch (Exception e) {}
            }
        }
        response.sendRedirect("ManageRequestServlet");
    }
}
