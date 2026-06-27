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

public class ManageApartmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Thực hiện logic doGet (ví dụ: lấy danh sách hiển thị) nếu cần
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
        String membersList = request.getParameter("membersList"); // Chuỗi tên thành viên, phân cách bằng dấu phẩy

        if (apartmentIdStr != null && roomNumber != null) {
            int apartmentId = Integer.parseInt(apartmentIdStr);
            DBContext db = new DBContext();
            Connection conn = null;
            PreparedStatement psUpdateApt = null;
            PreparedStatement psUpdateOwner = null;
            PreparedStatement psUpdateRental = null;
            PreparedStatement psDeleteResidents = null;
            PreparedStatement psInsertResident = null;

            try {
                conn = db.getConnection();
                // Bật Transaction để đảm bảo tính an toàn dữ liệu khi sửa nhiều bảng cùng lúc
                conn.setAutoCommit(false);

                // HÀM 1: Cập nhật số phòng trong bảng Apartment
                String sqlUpdateApt = "UPDATE Apartment SET apartment_code = ? WHERE apartment_id = ?";
                psUpdateApt = conn.prepareStatement(sqlUpdateApt);
                psUpdateApt.setString(1, roomNumber);
                psUpdateApt.setInt(2, apartmentId);
                psUpdateApt.executeUpdate();

                // HÀM 2: Cập nhật tên Chủ căn hộ (Cập nhật bảng Account thông qua bảng liên kết)
                if (ownerName != null && !ownerName.trim().isEmpty()) {
                    String sqlUpdateOwner = "UPDATE Account SET full_name = ? WHERE account_id = ("
                                          + "SELECT TOP 1 account_id FROM ApartmentOwner WHERE apartment_id = ? AND is_active = 1)";
                    psUpdateOwner = conn.prepareStatement(sqlUpdateOwner);
                    psUpdateOwner.setString(1, ownerName.trim());
                    psUpdateOwner.setInt(2, apartmentId);
                    psUpdateOwner.executeUpdate();
                }

                // HÀM 3: Cập nhật tên Người thuê (Nếu có)
                if (tenantName != null && !tenantName.trim().isEmpty()) {
                    String sqlUpdateRental = "UPDATE Account SET full_name = ? WHERE account_id = ("
                                           + "SELECT TOP 1 account_id FROM ApartmentRental WHERE apartment_id = ? AND is_active = 1)";
                    psUpdateRental = conn.prepareStatement(sqlUpdateRental);
                    psUpdateRental.setString(1, tenantName.trim());
                    psUpdateRental.setInt(2, apartmentId);
                    psUpdateRental.executeUpdate();
                }

                // HÀM 4: Cập nhật danh sách thành viên sinh sống (Resident)
                // Xóa danh sách cũ đi để chèn lại danh sách mới tránh trùng lặp hoặc sót người
                String sqlDeleteResidents = "DELETE FROM Resident WHERE apartment_id = ?";
                psDeleteResidents = conn.prepareStatement(sqlDeleteResidents);
                psDeleteResidents.setInt(1, apartmentId);
                psDeleteResidents.executeUpdate();

                // Chèn lại các thành viên mới được điền từ form vào bảng Resident
                if (membersList != null && !membersList.trim().isEmpty()) {
                    String[] residents = membersList.split(",");
                    String sqlInsertResident = "INSERT INTO Resident (apartment_id, full_name) VALUES (?, ?)";
                    psInsertResident = conn.prepareStatement(sqlInsertResident);
                    
                    for (String resName : residents) {
                        if (!resName.trim().isEmpty()) {
                            psInsertResident.setInt(1, apartmentId);
                            psInsertResident.setString(2, resName.trim());
                            psInsertResident.addBatch(); // Sử dụng Batch để tối ưu hiệu năng
                        }
                    }
                    psInsertResident.executeBatch();
                }

                // Hoàn tất thành công toàn bộ tiến trình, Commit vào Database
                conn.commit();
                request.setAttribute("message", "Cập nhật thông tin căn hộ thành công!");

            } catch (Exception e) {
                // Nếu xảy ra bất kỳ lỗi gì, hủy bỏ toàn bộ thao tác để tránh sai lệch dữ liệu
                if (conn != null) {
                    try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
                }
                e.printStackTrace();
                request.setAttribute("error", "Có lỗi xảy ra trong quá trình cập nhật.");
            } finally {
                try {
                    if (psUpdateApt != null) psUpdateApt.close();
                    if (psUpdateOwner != null) psUpdateOwner.close();
                    if (psUpdateRental != null) psUpdateRental.close();
                    if (psDeleteResidents != null) psDeleteResidents.close();
                    if (psInsertResident != null) psInsertResident.close();
                    if (conn != null) conn.close();
                } catch (Exception e) {}
            }
        }
        
        // Sau khi xử lý xong, tải lại trang quản lý căn hộ
        response.sendRedirect("ManageApartmentServlet");
    }
}