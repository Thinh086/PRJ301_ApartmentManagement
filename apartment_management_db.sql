-- ============================================================
--  DATABASE: QuanLyChungCu (PRJ301 - FPT University)
--  SQL Server
--  v2: Đổi Role → Roles, amount → Computed Column
-- ============================================================

CREATE DATABASE QuanLyChungCu;
GO
USE QuanLyChungCu;
GO

-- ============================================================
-- 1. BẢNG VAI TRÒ (Roles)
--    Đổi từ "Role" → "Roles" để tránh conflict với reserved keyword SQL Server
-- ============================================================
CREATE TABLE Roles (
    role_id   INT PRIMARY KEY IDENTITY(1,1),
    role_name NVARCHAR(50) NOT NULL  -- 'Admin', 'QuanLy', 'NhanVien', 'ChuCanHo', 'DaiDienThue'
);

-- ============================================================
-- 2. BẢNG NGƯỜI DÙNG (Account)
-- ============================================================
CREATE TABLE Account (
    account_id  INT PRIMARY KEY IDENTITY(1,1),
    username    VARCHAR(50)   NOT NULL UNIQUE,
    password    VARCHAR(255)  NOT NULL,          -- nên hash (MD5/BCrypt)
    full_name   NVARCHAR(100) NOT NULL,
    email       VARCHAR(100),
    phone       VARCHAR(20),
    role_id     INT NOT NULL,
    is_active   BIT NOT NULL DEFAULT 1,
    created_at  DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Account_Roles FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

-- ============================================================
-- 3. BẢNG CĂN HỘ (Apartment)
-- ============================================================
CREATE TABLE Apartment (
    apartment_id   INT PRIMARY KEY IDENTITY(1,1),
    apartment_code NVARCHAR(20)  NOT NULL UNIQUE,   -- VD: A101, B205
    floor          INT,
    area           FLOAT,                            -- diện tích (m2)
    status         NVARCHAR(20) NOT NULL DEFAULT N'Trống'
                   -- 'Trống', 'Đang ở', 'Đang thuê'
);

-- ============================================================
-- 4. BẢNG CHỦ CĂN HỘ (ApartmentOwner)
--    Mỗi căn hộ có 1 chủ (account có role ChuCanHo)
-- ============================================================
CREATE TABLE ApartmentOwner (
    owner_id     INT PRIMARY KEY IDENTITY(1,1),
    apartment_id INT NOT NULL,
    account_id   INT NOT NULL,           -- chủ căn hộ
    start_date   DATE NOT NULL,
    end_date     DATE,                   -- NULL = đang sở hữu
    CONSTRAINT FK_AptOwner_Apartment FOREIGN KEY (apartment_id) REFERENCES Apartment(apartment_id),
    CONSTRAINT FK_AptOwner_Account   FOREIGN KEY (account_id)   REFERENCES Account(account_id)
);

-- ============================================================
-- 5. BẢNG THUÊ CĂN HỘ (ApartmentRental)
--    Khi căn hộ được thuê: lưu thêm đại diện thuê
-- ============================================================
CREATE TABLE ApartmentRental (
    rental_id         INT PRIMARY KEY IDENTITY(1,1),
    apartment_id      INT NOT NULL,
    owner_account_id  INT NOT NULL,   -- chủ căn hộ
    tenant_account_id INT NOT NULL,   -- đại diện thuê (role DaiDienThue)
    start_date        DATE NOT NULL,
    end_date          DATE,           -- NULL = đang thuê
    CONSTRAINT FK_Rental_Apartment FOREIGN KEY (apartment_id)      REFERENCES Apartment(apartment_id),
    CONSTRAINT FK_Rental_Owner     FOREIGN KEY (owner_account_id)  REFERENCES Account(account_id),
    CONSTRAINT FK_Rental_Tenant    FOREIGN KEY (tenant_account_id) REFERENCES Account(account_id)
);

-- ============================================================
-- 6. BẢNG THÀNH VIÊN SINH SỐNG (Resident)
--    Những người sống trong căn hộ (không nhất thiết có tài khoản)
-- ============================================================
CREATE TABLE Resident (
    resident_id  INT PRIMARY KEY IDENTITY(1,1),
    apartment_id INT NOT NULL,
    full_name    NVARCHAR(100) NOT NULL,
    birth_date   DATE,
    gender       NVARCHAR(10),
    id_card      VARCHAR(20),
    relationship NVARCHAR(50),   -- quan hệ với chủ/đại diện thuê
    CONSTRAINT FK_Resident_Apartment FOREIGN KEY (apartment_id) REFERENCES Apartment(apartment_id)
);

-- ============================================================
-- 7. BẢNG LOẠI DỊCH VỤ (ServiceType)
-- ============================================================
CREATE TABLE ServiceType (
    service_type_id INT PRIMARY KEY IDENTITY(1,1),
    service_name    NVARCHAR(100) NOT NULL,   -- 'Phí quản lý', 'Nước', 'Trông xe', ...
    unit            NVARCHAR(30),             -- 'm3', 'xe/tháng', 'tháng'
    unit_price      DECIMAL(18,2) NOT NULL
);

-- ============================================================
-- 8. BẢNG HÓA ĐƠN DỊCH VỤ HÀNG THÁNG (MonthlyBill)
--    Gửi cho từng căn hộ mỗi tháng
-- ============================================================
CREATE TABLE MonthlyBill (
    bill_id      INT PRIMARY KEY IDENTITY(1,1),
    apartment_id INT NOT NULL,
    bill_month   INT  NOT NULL,   -- 1-12
    bill_year    INT  NOT NULL,
    total_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    is_paid      BIT NOT NULL DEFAULT 0,
    created_at   DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Bill_Apartment FOREIGN KEY (apartment_id) REFERENCES Apartment(apartment_id)
);

-- ============================================================
-- 9. BẢNG CHI TIẾT HÓA ĐƠN (BillDetail)
--    amount là Computed Column: tự động = quantity * unit_price
--    → Không thể nhập sai, không cần tính thủ công trong Java
-- ============================================================
CREATE TABLE BillDetail (
    detail_id       INT PRIMARY KEY IDENTITY(1,1),
    bill_id         INT NOT NULL,
    service_type_id INT NOT NULL,
    quantity        DECIMAL(10,2) NOT NULL DEFAULT 1,
    unit_price      DECIMAL(18,2) NOT NULL,
    amount          AS (CAST(quantity * unit_price AS DECIMAL(18,2))),  -- Computed Column
    note            NVARCHAR(200),
    CONSTRAINT FK_BillDetail_Bill        FOREIGN KEY (bill_id)         REFERENCES MonthlyBill(bill_id),
    CONSTRAINT FK_BillDetail_ServiceType FOREIGN KEY (service_type_id) REFERENCES ServiceType(service_type_id)
);

-- ============================================================
-- 10. BẢNG ĐĂNG KÝ TRÔNG XE (VehicleRegistration)
-- ============================================================
CREATE TABLE VehicleRegistration (
    reg_id        INT PRIMARY KEY IDENTITY(1,1),
    apartment_id  INT NOT NULL,
    account_id    INT NOT NULL,           -- người đăng ký
    vehicle_type  NVARCHAR(50) NOT NULL,  -- 'Xe máy', 'Ô tô', 'Xe đạp'
    license_plate NVARCHAR(20),
    start_date    DATE NOT NULL,
    end_date      DATE,
    status        NVARCHAR(30) NOT NULL DEFAULT N'Chờ duyệt',
                  -- 'Chờ duyệt', 'Đã duyệt', 'Từ chối'
    approved_by   INT,                   -- account_id của quản lý duyệt
    approved_at   DATETIME,
    CONSTRAINT FK_VehicleReg_Apartment FOREIGN KEY (apartment_id) REFERENCES Apartment(apartment_id),
    CONSTRAINT FK_VehicleReg_Account   FOREIGN KEY (account_id)   REFERENCES Account(account_id),
    CONSTRAINT FK_VehicleReg_Approver  FOREIGN KEY (approved_by)  REFERENCES Account(account_id)
);

-- ============================================================
-- 11. BẢNG YÊU CẦU SỬA CHỮA / DỊCH VỤ (ServiceRequest)
-- ============================================================
CREATE TABLE ServiceRequest (
    request_id   INT PRIMARY KEY IDENTITY(1,1),
    apartment_id INT NOT NULL,
    account_id   INT NOT NULL,            -- người gửi yêu cầu
    request_type NVARCHAR(100) NOT NULL,  -- 'Sửa chữa', 'Vệ sinh', 'Khác'
    title        NVARCHAR(200) NOT NULL,
    description  NVARCHAR(MAX),
    status       NVARCHAR(30) NOT NULL DEFAULT N'Chờ duyệt',
                 -- 'Chờ duyệt', 'Đã duyệt', 'Đang xử lý', 'Hoàn thành', 'Từ chối'
    created_at   DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Request_Apartment FOREIGN KEY (apartment_id) REFERENCES Apartment(apartment_id),
    CONSTRAINT FK_Request_Account   FOREIGN KEY (account_id)   REFERENCES Account(account_id)
);

-- ============================================================
-- 12. BẢNG PHÂN CÔNG XỬ LÝ YÊU CẦU (RequestAssignment)
--    Quản lý duyệt và giao cho nhân viên
-- ============================================================
CREATE TABLE RequestAssignment (
    assignment_id INT PRIMARY KEY IDENTITY(1,1),
    request_id    INT NOT NULL,
    assigned_by   INT NOT NULL,   -- account_id của quản lý
    assigned_to   INT NOT NULL,   -- account_id của nhân viên
    assigned_at   DATETIME DEFAULT GETDATE(),
    note          NVARCHAR(500),
    CONSTRAINT FK_Assignment_Request    FOREIGN KEY (request_id)  REFERENCES ServiceRequest(request_id),
    CONSTRAINT FK_Assignment_AssignedBy FOREIGN KEY (assigned_by) REFERENCES Account(account_id),
    CONSTRAINT FK_Assignment_AssignedTo FOREIGN KEY (assigned_to) REFERENCES Account(account_id)
);

-- ============================================================
-- 13. BẢNG CẬP NHẬT TIẾN ĐỘ (RequestProgress)
--    Nhân viên cập nhật tiến độ xử lý
-- ============================================================
CREATE TABLE RequestProgress (
    progress_id INT PRIMARY KEY IDENTITY(1,1),
    request_id  INT NOT NULL,
    account_id  INT NOT NULL,         -- nhân viên hoặc quản lý cập nhật
    status      NVARCHAR(30) NOT NULL,-- trạng thái tại thời điểm cập nhật
    description NVARCHAR(MAX),
    updated_at  DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Progress_Request FOREIGN KEY (request_id) REFERENCES ServiceRequest(request_id),
    CONSTRAINT FK_Progress_Account FOREIGN KEY (account_id) REFERENCES Account(account_id)
);

-- ============================================================
-- 14. BẢNG ĐĂNG KÝ CHUYỂN ĐỒ VÀO/RA (MoveRegistration)
-- ============================================================
CREATE TABLE MoveRegistration (
    move_id      INT PRIMARY KEY IDENTITY(1,1),
    apartment_id INT NOT NULL,
    account_id   INT NOT NULL,          -- người đăng ký
    move_type    NVARCHAR(10) NOT NULL, -- 'Vào', 'Ra'
    move_date    DATE NOT NULL,
    time_slot    NVARCHAR(50),          -- giờ theo quy định
    description  NVARCHAR(500),
    status       NVARCHAR(30) NOT NULL DEFAULT N'Chờ duyệt',
                 -- 'Chờ duyệt', 'Đã duyệt', 'Từ chối'
    approved_by  INT,
    approved_at  DATETIME,
    created_at   DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Move_Apartment FOREIGN KEY (apartment_id) REFERENCES Apartment(apartment_id),
    CONSTRAINT FK_Move_Account   FOREIGN KEY (account_id)   REFERENCES Account(account_id),
    CONSTRAINT FK_Move_Approver  FOREIGN KEY (approved_by)  REFERENCES Account(account_id)
);

GO

-- ============================================================
-- DỮ LIỆU MẪU (Sample Data)
-- ============================================================

-- Roles
INSERT INTO Roles (role_name) VALUES
(N'Admin'),
(N'QuanLy'),
(N'NhanVien'),
(N'ChuCanHo'),
(N'DaiDienThue');

-- Accounts (password = '123456' - nên hash trong thực tế)
INSERT INTO Account (username, password, full_name, email, phone, role_id) VALUES
('admin',      '123456', N'Quản Trị Viên',       'admin@chungcu.vn',  '0900000001', 1),
('quanly01',   '123456', N'Nguyễn Văn Quản Lý',  'ql01@chungcu.vn',   '0900000002', 2),
('nhanvien01', '123456', N'Trần Thị Nhân Viên',   'nv01@chungcu.vn',   '0900000003', 3),
('nhanvien02', '123456', N'Lê Văn Kỹ Thuật',      'nv02@chungcu.vn',   '0900000004', 3),
('chu001',     '123456', N'Phạm Văn An',           'pva@gmail.com',     '0912345001', 4),
('chu002',     '123456', N'Nguyễn Thị Bình',       'ntb@gmail.com',     '0912345002', 4),
('thue001',    '123456', N'Hoàng Văn Cường',       'hvc@gmail.com',     '0912345003', 5);

-- Apartments
INSERT INTO Apartment (apartment_code, floor, area, status) VALUES
(N'A101', 1, 65.0, N'Đang ở'),
(N'A102', 1, 70.0, N'Đang thuê'),
(N'B201', 2, 80.0, N'Đang ở'),
(N'B202', 2, 55.0, N'Trống'),
(N'C301', 3, 90.0, N'Trống');

-- ApartmentOwner
INSERT INTO ApartmentOwner (apartment_id, account_id, start_date) VALUES
(1, 5, '2023-01-01'),  -- A101 - Phạm Văn An
(2, 6, '2022-06-01'),  -- A102 - Nguyễn Thị Bình (chủ nhưng đang cho thuê)
(3, 5, '2021-03-15');  -- B201 - Phạm Văn An

-- ApartmentRental (A102 đang được thuê)
INSERT INTO ApartmentRental (apartment_id, owner_account_id, tenant_account_id, start_date) VALUES
(2, 6, 7, '2024-01-01');  -- A102: chủ Nguyễn Thị Bình, thuê Hoàng Văn Cường

-- Residents
INSERT INTO Resident (apartment_id, full_name, birth_date, gender, id_card, relationship) VALUES
(1, N'Phạm Văn An',     '1985-04-10', N'Nam', '012345001', N'Chủ hộ'),
(1, N'Phạm Thị Lan',    '1988-07-22', N'Nữ',  '012345002', N'Vợ'),
(1, N'Phạm Bảo Nam',    '2015-03-05', N'Nam', NULL,        N'Con'),
(2, N'Hoàng Văn Cường', '1990-11-30', N'Nam', '012345010', N'Đại diện thuê'),
(3, N'Nguyễn Thị Bình', '1982-09-15', N'Nữ',  '012345020', N'Chủ hộ');

-- ServiceTypes
INSERT INTO ServiceType (service_name, unit, unit_price) VALUES
(N'Phí quản lý',    N'tháng',    500000),
(N'Nước',           N'm3',         8000),
(N'Trông xe máy',   N'xe/tháng', 100000),
(N'Trông ô tô',     N'xe/tháng', 300000),
(N'Điện sinh hoạt', N'kWh',        3000);

-- MonthlyBill tháng 6/2026
INSERT INTO MonthlyBill (apartment_id, bill_month, bill_year, total_amount, is_paid) VALUES
(1, 6, 2026, 1066000, 0),
(2, 6, 2026,  908000, 0);

-- BillDetail cho bill_id=1 (A101)
-- Lưu ý: KHÔNG INSERT cột amount vì là Computed Column, SQL Server tự tính
INSERT INTO BillDetail (bill_id, service_type_id, quantity, unit_price, note) VALUES
(1, 1,   1, 500000, N'Phí quản lý tháng 6'),
(1, 2,  20,   8000, N'20 m3 nước'),
(1, 3,   1, 100000, N'1 xe máy'),
(1, 5, 102,   3000, N'102 kWh điện');

-- BillDetail cho bill_id=2 (A102)
INSERT INTO BillDetail (bill_id, service_type_id, quantity, unit_price, note) VALUES
(2, 1,  1, 500000, N'Phí quản lý tháng 6'),
(2, 2, 18,   8000, N'18 m3 nước'),
(2, 5, 88,   3000, N'88 kWh điện');

-- VehicleRegistration
INSERT INTO VehicleRegistration (apartment_id, account_id, vehicle_type, license_plate, start_date, status, approved_by, approved_at) VALUES
(1, 5, N'Xe máy', N'29X1-12345', '2024-01-01', N'Đã duyệt', 2, '2024-01-02'),
(2, 7, N'Xe máy', N'30A2-67890', '2024-02-01', N'Đã duyệt', 2, '2024-02-02');

-- ServiceRequest
INSERT INTO ServiceRequest (apartment_id, account_id, request_type, title, description, status) VALUES
(1, 5, N'Sửa chữa', N'Vòi nước bị rò rỉ',          N'Vòi nước phòng bếp bị rò rỉ, cần sửa gấp',  N'Đang xử lý'),
(2, 7, N'Vệ sinh',  N'Yêu cầu vệ sinh hành lang',   N'Hành lang tầng 1 khu A cần vệ sinh',         N'Chờ duyệt');

-- RequestAssignment
INSERT INTO RequestAssignment (request_id, assigned_by, assigned_to, note) VALUES
(1, 2, 4, N'Giao cho kỹ thuật xử lý trong ngày');

-- RequestProgress
INSERT INTO RequestProgress (request_id, account_id, status, description) VALUES
(1, 4, N'Đang xử lý', N'Đã kiểm tra, đang chuẩn bị dụng cụ sửa chữa');

-- MoveRegistration
INSERT INTO MoveRegistration (apartment_id, account_id, move_type, move_date, time_slot, description, status) VALUES
(1, 5, N'Ra', '2026-06-25', N'8:00 - 10:00', N'Chuyển đồ cũ đi', N'Chờ duyệt');

GO

-- ============================================================
-- CÁC QUERY HỮU ÍCH (dùng trong DAO)
-- ============================================================

-- Xem hóa đơn chi tiết theo căn hộ và tháng
-- SELECT b.bill_id, a.apartment_code, b.bill_month, b.bill_year,
--        st.service_name, bd.quantity, bd.unit_price, bd.amount, b.is_paid
-- FROM MonthlyBill b
-- JOIN Apartment a  ON a.apartment_id      = b.apartment_id
-- JOIN BillDetail bd ON bd.bill_id         = b.bill_id
-- JOIN ServiceType st ON st.service_type_id = bd.service_type_id
-- WHERE a.apartment_id = 1 AND b.bill_month = 6 AND b.bill_year = 2026;

-- Xem danh sách yêu cầu + tiến độ mới nhất
-- SELECT r.request_id, a.apartment_code, ac.full_name AS nguoi_gui,
--        r.title, r.status, p.description AS tien_do, p.updated_at
-- FROM ServiceRequest r
-- JOIN Apartment a  ON a.apartment_id  = r.apartment_id
-- JOIN Account ac   ON ac.account_id   = r.account_id
-- LEFT JOIN RequestProgress p ON p.request_id = r.request_id
-- ORDER BY r.created_at DESC;

-- Xem vai trò người dùng (dùng cho Session/Filter)
-- SELECT a.account_id, a.username, a.full_name, r.role_name
-- FROM Account a
-- JOIN Roles r ON r.role_id = a.role_id
-- WHERE a.username = ? AND a.password = ? AND a.is_active = 1;
