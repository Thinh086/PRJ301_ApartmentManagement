package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Request;
import model.User;

public class EmployeeDAO {

    // Lấy danh sách công việc được gán cho một nhân viên
    public List<Request> getTasksByEmployee(int employeeId) {
        List<Request> list = new ArrayList<>();
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            String sql = "SELECT r.request_id, r.apartment_id, r.account_id, r.request_type, "
                       + "       r.title, r.description, r.status, r.created_at, "
                       + "       a.apartment_code, ac.full_name AS requester_name, "
                       + "       (SELECT TOP 1 p.description + ' (' + CONVERT(VARCHAR, p.updated_at, 103) + ')' "
                       + "        FROM RequestProgress p WHERE p.request_id = r.request_id ORDER BY p.updated_at DESC) AS latest_progress, "
                       + "       (SELECT TOP 1 CONVERT(VARCHAR, p.updated_at, 120) "
                       + "        FROM RequestProgress p WHERE p.request_id = r.request_id ORDER BY p.updated_at DESC) AS latest_progress_time "
                       + "FROM ServiceRequest r "
                       + "JOIN Apartment a ON a.apartment_id = r.apartment_id "
                       + "JOIN Account ac ON ac.account_id = r.account_id "
                       + "JOIN RequestAssignment ra ON ra.request_id = r.request_id AND ra.assigned_to = ? "
                       + "ORDER BY "
                       + "  CASE r.status "
                       + "    WHEN N'Đang xử lý' THEN 1 "
                       + "    WHEN N'Đã duyệt' THEN 2 "
                       + "    WHEN N'Chờ duyệt' THEN 3 "
                       + "    ELSE 4 "
                       + "  END, "
                       + "  r.created_at DESC";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, employeeId);
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
                req.setLatestProgress(rs.getString("latest_progress"));
                req.setLatestProgressTime(rs.getString("latest_progress_time"));
                list.add(req);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return list;
    }

    // Lấy danh sách tất cả nhân viên (role_id = 3)
    public List<User> getAllEmployees() {
        List<User> list = new ArrayList<>();
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            String sql = "SELECT account_id, full_name FROM Account WHERE role_id = 3 AND is_active = 1";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                User emp = new User();
                emp.setAccountId(rs.getInt("account_id"));
                emp.setFullName(rs.getString("full_name"));
                list.add(emp);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return list;
    }

    // Cập nhật trạng thái yêu cầu và thêm bản ghi tiến độ
    public boolean updateTaskProgress(int requestId, int employeeId, String newStatus, String description) {
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement psUpdateReq = null;
        PreparedStatement psInsertProgress = null;
        
        try {
            conn = db.getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật trạng thái trong bảng ServiceRequest
            String sqlUpdateReq = "UPDATE ServiceRequest SET status = ? WHERE request_id = ?";
            psUpdateReq = conn.prepareStatement(sqlUpdateReq);
            psUpdateReq.setString(1, newStatus);
            psUpdateReq.setInt(2, requestId);
            psUpdateReq.executeUpdate();

            // 2. Thêm bản ghi vào bảng RequestProgress
            String sqlInsertProgress = "INSERT INTO RequestProgress (request_id, account_id, status, description) VALUES (?, ?, ?, ?)";
            psInsertProgress = conn.prepareStatement(sqlInsertProgress);
            psInsertProgress.setInt(1, requestId);
            psInsertProgress.setInt(2, employeeId);
            psInsertProgress.setString(3, newStatus);
            psInsertProgress.setString(4, description);
            psInsertProgress.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (psUpdateReq != null) psUpdateReq.close();
                if (psInsertProgress != null) psInsertProgress.close();
                if (conn != null) conn.close();
            } catch (Exception e) {}
        }
    }
}
