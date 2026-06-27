/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class Apartment {
    private int id;
    private String roomNumber;
    private String ownerName;
    private String tenantName;
    private String membersList;

    // Hàm khởi tạo không tham số (No-arg Constructor)
    public Apartment() {
    }

    // Hàm khởi tạo đầy đủ tham số (All-args Constructor)
    public Apartment(int id, String roomNumber, String ownerName, String tenantName, String membersList) {
        this.id = id;
        this.roomNumber = roomNumber;
        this.ownerName = ownerName;
        this.tenantName = tenantName;
        this.membersList = membersList;
    }

    // --- CÁC HÀM GETTER VÀ SETTER ---

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }

    public String getTenantName() {
        return tenantName;
    }

    public void setTenantName(String tenantName) {
        this.tenantName = tenantName;
    }

    public String getMembersList() {
        return membersList;
    }

    public void setMembersList(String membersList) {
        this.membersList = membersList;
    }

    // Hàm toString() hỗ trợ in ra dữ liệu khi cần kiểm tra nhanh (Dùng cho việc debug)
    @Override
    public String toString() {
        return "Apartment{" +
                "id=" + id +
                ", roomNumber='" + roomNumber + '\'' +
                ", ownerName='" + ownerName + '\'' +
                ", tenantName='" + tenantName + '\'' +
                ", membersList='" + membersList + '\'' +
                '}';
    }
}