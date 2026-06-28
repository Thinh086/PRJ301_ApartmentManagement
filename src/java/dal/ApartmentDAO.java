package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Apartment;

public class ApartmentDAO {

    // 1. Lấy danh sách căn hộ kèm tên chủ hộ và người thuê
    public List<Apartment> getAllApartments() {
        List<Apartment> list = new ArrayList<>();
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = db.getConnection();
            String sql = "SELECT a.apartment_id AS id, a.apartment_code AS room_number, "
                       + "       o_acc.full_name AS owner_name, "
                       + "       r_acc.full_name AS tenant_name, "
                       + "       (SELECT STRING_AGG(res.full_name, ', ') "
                       + "        FROM Resident res WHERE res.apartment_id = a.apartment_id) AS members_list "
                       + "FROM Apartment a "
                       + "LEFT JOIN ApartmentOwner ao ON a.apartment_id = ao.apartment_id "
                       + "LEFT JOIN Account o_acc ON ao.account_id = o_acc.account_id "
                       + "LEFT JOIN ApartmentRental ar ON a.apartment_id = ar.apartment_id "
                       + "LEFT JOIN Account r_acc ON ar.tenant_account_id = r_acc.account_id";
            
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Apartment apt = new Apartment();
                apt.setId(rs.getInt("id"));
                apt.setRoomNumber(rs.getString("room_number"));
                apt.setOwnerName(rs.getString("owner_name") != null ? rs.getString("owner_name") : "Chưa có");
                apt.setTenantName(rs.getString("tenant_name") != null ? rs.getString("tenant_name") : "Trống");
                apt.setMembersList(rs.getString("members_list") != null ? rs.getString("members_list") : "Không có");
                list.add(apt);
            }
        } catch (Exception e) {         
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return list;
    }

    // 2. Cập nhật thông tin cơ bản của căn hộ
    public boolean updateApartment(int id, String roomNumber) {
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = db.getConnection();
            String sql = "UPDATE Apartment SET apartment_code = ? WHERE apartment_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, roomNumber);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
