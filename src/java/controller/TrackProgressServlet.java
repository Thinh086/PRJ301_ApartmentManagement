/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

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

public class TrackProgressServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Request> progressList = new ArrayList<>();
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = db.getConnection();

            // Lấy các yêu cầu đang được xử lý kèm tiến độ mới nhất
            String sql = "SELECT r.request_id, r.request_type, r.title, r.description, "
                       + "       r.status, r.created_at, "
                       + "       a.apartment_code, "
                       + "       ac.full_name AS requester_name, "
                       + "       emp.full_name AS employee_name, "
                       + "       (SELECT TOP 1 p.description "
                       + "        FROM RequestProgress p "
                       + "        WHERE p.request_id = r.request_id "
                       + "        ORDER BY p.updated_at DESC) AS latest_progress "
                       + "FROM ServiceRequest r "
                       + "JOIN Apartment a  ON a.apartment_id  = r.apartment_id "
                       + "JOIN Account ac   ON ac.account_id   = r.account_id "
                       + "LEFT JOIN RequestAssignment ra ON ra.request_id = r.request_id "
                       + "LEFT JOIN Account emp ON emp.account_id = ra.assigned_to "
                       + "WHERE r.status IN (N'Đang xử lý', N'Đã duyệt') "
                       + "ORDER BY r.created_at DESC";

            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Request req = new Request();
                req.setRequestId(rs.getInt("request_id"));
                req.setRequestType(rs.getString("request_type"));
                req.setTitle(rs.getString("title"));
                req.setDescription(rs.getString("description"));
                req.setStatus(rs.getString("status"));
                req.setCreatedAt(rs.getString("created_at"));
                req.setApartmentCode(rs.getString("apartment_code"));
                req.setRequesterName(rs.getString("requester_name"));

                String empName = rs.getString("employee_name");
                req.setAssignedEmployeeName(empName != null ? empName : "Chưa gán");

                req.setLatestProgress(rs.getString("latest_progress"));
                progressList.add(req);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (Exception e) {}
        }

        request.setAttribute("progressList", progressList);
        request.getRequestDispatcher("track-progress.jsp").forward(request, response);
    }
}
