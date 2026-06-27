package controller;

import dal.DBContext;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ManageRequestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Chuyển hướng sang trang giao diện quản lý yêu cầu
        request.getRequestDispatcher("manage-requests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy dữ liệu từ Form phê duyệt / điều phối của Ban Quản Lý
        String requestIdStr = request.getParameter("requestId");
        String status = request.getParameter("status"); // 'Da duyet', 'Tu choi', ...
        String employeeIdStr = request.getParameter("employeeId"); // ID nhân viên được gán việc

        if (requestIdStr != null && status != null) {
            int requestId = Integer.parseInt(requestIdStr);
            DBContext db = new DBContext();
            Connection conn = null;
            PreparedStatement psUpdateReq = null;
            PreparedStatement psCheckAssign = null;
            PreparedStatement psInsertAssign = null;

            try {
                conn = db.getConnection();
                // Bật giao dịch (Transaction) để đảm bảo an toàn dữ liệu khi cập nhật nhiều bảng
                conn.setAutoCommit(false);

                // 1. Cập nhật trạng thái của yêu cầu trong bảng ServiceRequest
                String sqlUpdateReq = "UPDATE ServiceRequest SET status = ? WHERE request_id = ?";
                psUpdateReq = conn.prepareStatement(sqlUpdateReq);
                psUpdateReq.setString(1, status);
                psUpdateReq.setInt(2, requestId);
                psUpdateReq.executeUpdate();

                // 2. Nếu trạng thái là 'Đã duyệt' và có chọn nhân viên, tiến hành gán việc vào bảng RequestAssignment
                if ("Da duyet".equals(status) && employeeIdStr != null && !employeeIdStr.isEmpty()) {
                    int employeeId = Integer.parseInt(employeeIdStr);

                    // Kiểm tra xem yêu cầu này đã từng được gán cho ai chưa
                    String sqlCheck = "SELECT * FROM RequestAssignment WHERE request_id = ?";
                    psCheckAssign = conn.prepareStatement(sqlCheck);
                    psCheckAssign.setInt(1, requestId);
                    ResultSet rs = psCheckAssign.executeQuery();

                    if (rs.next()) {
                        // Nếu đã có bản ghi gán việc trước đó, tiến hành cập nhật lại nhân viên mới
                        String sqlUpdateAssign = "UPDATE RequestAssignment SET account_id = ?, assigned_at = GETDATE() WHERE request_id = ?";
                        psInsertAssign = conn.prepareStatement(sqlUpdateAssign);
                        psInsertAssign.setInt(1, employeeId);
                        psInsertAssign.setInt(2, requestId);
                    } else {
                        // Nếu chưa có, tiến hành thêm mới một bản ghi gán việc
                        String sqlInsert = "INSERT INTO RequestAssignment (request_id, account_id) VALUES (?, ?)";
                        psInsertAssign = conn.prepareStatement(sqlInsert);
                        psInsertAssign.setInt(1, requestId);
                        psInsertAssign.setInt(2, employeeId);
                    }
                    psInsertAssign.executeUpdate();
                }

                // Hoàn tất thực thi và commit giao dịch
                conn.commit();
                
            } catch (Exception e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
                }
                e.printStackTrace();
            } finally {
                try {
                    if (psUpdateReq != null) psUpdateReq.close();
                    if (psCheckAssign != null) psCheckAssign.close();
                    if (psInsertAssign != null) psInsertAssign.close();
                    if (conn != null) conn.close();
                } catch (Exception e) {}
            }
        }
        // Sau khi xử lý xong, tải lại trang quản lý yêu cầu
        response.sendRedirect("ManageRequestServlet");
    }
}