package controller;

import dal.ApartmentDAO;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Apartment;

public class ManageApartmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            ApartmentDAO dao = new ApartmentDAO();
            List<Apartment> list = dao.getAllApartments();
            request.setAttribute("apartments", list);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
        }
        request.getRequestDispatcher("manage-apartments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Lấy dữ liệu từ Form chỉnh sửa căn hộ gửi lên
        String apartmentIdStr = request.getParameter("apartmentId");
        String roomNumber = request.getParameter("roomNumber");
        String ownerName = request.getParameter("ownerName");
        String tenantName = request.getParameter("tenantName");
        String membersList = request.getParameter("membersList");

        if (apartmentIdStr != null && roomNumber != null) {
            int apartmentId = Integer.parseInt(apartmentIdStr);
            dal.DBContext db = new dal.DBContext();
            Connection conn = null;
            PreparedStatement psUpdateApt = null;
            PreparedStatement psUpdateOwner = null;
            PreparedStatement psUpdateRental = null;
            PreparedStatement psDeleteResidents = null;
            PreparedStatement psInsertResident = null;

            try {
                conn = db.getConnection();
                conn.setAutoCommit(false);

                // Cập nhật số phòng trong bảng Apartment
                String sqlUpdateApt = "UPDATE Apartment SET apartment_code = ? WHERE apartment_id = ?";
                psUpdateApt = conn.prepareStatement(sqlUpdateApt);
                psUpdateApt.setString(1, roomNumber);
                psUpdateApt.setInt(2, apartmentId);
                psUpdateApt.executeUpdate();

                // Cập nhật tên Chủ căn hộ
                if (ownerName != null && !ownerName.trim().isEmpty()) {
                    String sqlUpdateOwner = "UPDATE Account SET full_name = ? WHERE account_id = ("
                            + "SELECT TOP 1 account_id FROM ApartmentOwner WHERE apartment_id = ?)";
                    psUpdateOwner = conn.prepareStatement(sqlUpdateOwner);
                    psUpdateOwner.setString(1, ownerName.trim());
                    psUpdateOwner.setInt(2, apartmentId);
                    psUpdateOwner.executeUpdate();
                }

                // Cập nhật tên Người thuê (Nếu có)
                if (tenantName != null && !tenantName.trim().isEmpty()) {
                    String sqlUpdateRental = "UPDATE Account SET full_name = ? WHERE account_id = ("
                            + "SELECT TOP 1 tenant_account_id FROM ApartmentRental WHERE apartment_id = ?)";
                    psUpdateRental = conn.prepareStatement(sqlUpdateRental);
                    psUpdateRental.setString(1, tenantName.trim());
                    psUpdateRental.setInt(2, apartmentId);
                    psUpdateRental.executeUpdate();
                }

                // Cập nhật danh sách thành viên sinh sống (Resident)
                String sqlDeleteResidents = "DELETE FROM Resident WHERE apartment_id = ?";
                psDeleteResidents = conn.prepareStatement(sqlDeleteResidents);
                psDeleteResidents.setInt(1, apartmentId);
                psDeleteResidents.executeUpdate();

                if (membersList != null && !membersList.trim().isEmpty()) {
                    String[] residents = membersList.split(",");
                    String sqlInsertResident = "INSERT INTO Resident (apartment_id, full_name) VALUES (?, ?)";
                    psInsertResident = conn.prepareStatement(sqlInsertResident);

                    for (String resName : residents) {
                        if (!resName.trim().isEmpty()) {
                            psInsertResident.setInt(1, apartmentId);
                            psInsertResident.setString(2, resName.trim());
                            psInsertResident.addBatch();
                        }
                    }
                    psInsertResident.executeBatch();
                }

                conn.commit();
                request.setAttribute("message", "Cập nhật thông tin căn hộ thành công!");

            } catch (Exception e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
                e.printStackTrace();
                request.setAttribute("error", "Có lỗi xảy ra trong quá trình cập nhật.");
            } finally {
                try {
                    if (psUpdateApt != null) {
                        psUpdateApt.close();
                    }
                    if (psUpdateOwner != null) {
                        psUpdateOwner.close();
                    }
                    if (psUpdateRental != null) {
                        psUpdateRental.close();
                    }
                    if (psDeleteResidents != null) {
                        psDeleteResidents.close();
                    }
                    if (psInsertResident != null) {
                        psInsertResident.close();
                    }
                    if (conn != null) {
                        conn.close();
                    }
                } catch (Exception e) {
                }
            }
        }

        response.sendRedirect("ManageApartmentServlet");
    }
}
