💻 THÀNH VIÊN 1 :CÔNG XUÂN THỊNH - NHÓM TRƯỞNG & KIẾN TRÚC HỆ THỐNG
Vai trò: Quản trị dự án, thiết lập nền tảng core và quản lý module cốt lõi (Ban quản lý).
Nhiệm vụ chi tiết:
Hạ tầng & Setup (Tuần đầu):
Tạo Repository Public trên GitHub, mời 3 thành viên vào làm Collaborators.
Khởi tạo cấu trúc dự án mẫu theo đúng chuẩn mô hình MVC (tạo sẵn các package: controller, model, dao, filter, context) để các thành viên khác clone về làm theo đúng chuẩn, tránh việc mỗi người chia thư mục một kiểu.
Viết file kết nối Database chung cho cả nhóm (DBContext.java dùng JDBC kết nối SQL Server).
Code Module Ban Quản Lý (Tính năng trung tâm):
Xây dựng màn hình Tiếp nhận & Điều phối: Nhận yêu cầu từ cư dân, bấm Duyệt/Từ chối và gán việc cho một Nhân viên cụ thể.
Xây dựng màn hình Theo dõi tiến độ: Theo dõi danh sách các yêu cầu đang xử lý.
Xây dựng tính năng Quản lý thông tin căn hộ: Xem/Cập nhật thông tin chủ hộ, thành viên sinh sống, hoặc lưu thông tin người thuê lại (nếu có).
Quản lý chất lượng: Review (kiểm tra) code của các thành viên trước khi cho phép gộp (Merge) vào nhánh chính trên GitHub để tránh lỗi xung đột code (Conflict).

💻 THÀNH VIÊN 2: VŨ MẠNH CƯỜNG  - PHỤ TRÁCH QUẢN TRỊ USER & PHÂN QUYỀN
Vai trò: Xử lý luồng bảo mật hệ thống và Module của Admin.
Nhiệm vụ chi tiết:
Thiết kế Database: Chủ trì cùng cả nhóm ngồi thiết kế các bảng trong SQL Server (đặc biệt là bảng Users/Accounts có phân chia Role).
Code Module Đăng nhập & Bảo mật:
Viết tính năng Đăng nhập / Đăng xuất, xử lý lưu thông tin tài khoản vào Session sau khi đăng nhập thành công.
Viết các bộ lọc Filter để phân quyền. (Ví dụ: Chặn không cho tài khoản Cư dân truy cập trái phép vào các Servlet/JSP của Ban quản lý hoặc Admin).
Code Module Admin:
Xây dựng trang quản trị dành riêng cho Admin: Thêm, sửa, xóa, cấp tài khoản cho Ban quản lý, Cư dân và Nhân viên hệ thống.

💻 THÀNH VIÊN 3: NGUYỄN QUỐC VIỆT - PHỤ TRÁCH MODULE CƯ DÂN (KHÁCH HÀNG)
Vai trò: Xây dựng luồng tính năng tương tác dành cho đối tượng Cư dân/Người thuê căn hộ.
Nhiệm vụ chi tiết:
Thiết kế giao diện cư dân: Làm giao diện Dashboard trực quan sau khi cư dân đăng nhập thành công (sử dụng JSP, HTML, CSS).
Code Module Tra cứu:
Xây dựng tính năng Xem chi tiết phí dịch vụ hàng tháng: Lấy dữ liệu tiền điện, nước, dịch vụ, gửi xe từ database ra và hiển thị lên màn hình cho cư dân xem.
Code Module Gửi yêu cầu:
Xây dựng các form Đăng ký/Gửi yêu cầu trực tuyến: Form đăng ký sửa chữa, đăng ký gửi xe, đăng ký chuyển đồ vào/ra (đảm bảo kiểm tra ràng buộc giờ giấc quy định cụ thể khi chuyển đồ).
Viết các hàm DAO tương ứng để chèn các yêu cầu này vào database dưới trạng thái "Chờ duyệt".

💻 THÀNH VIÊN 4: PHẠM HUY BÁCH - PHỤ TRÁCH MODULE NHÂN VIÊN & TỔNG HỢP SẢN PHẨM
Vai trò: Hoàn thiện luồng cuối của quy trình xử lý yêu cầu và chịu trách nhiệm đầu ra của tài liệu nộp bài.
Nhiệm vụ chi tiết:
Code Module Nhân viên (Lễ tân, Kỹ thuật...):
Xây dựng màn hình hiển thị danh sách công việc mà Ban quản lý (do bạn Thịnh điều phối) gán cho nhân viên đó.
Xây dựng tính năng cho phép Nhân viên bấm Cập nhật tiến độ xử lý (Ví dụ: Đang sửa chữa -> Đã hoàn thành). Trạng thái này sẽ đồng bộ trực tiếp để Cư dân (do Việt code) có thể nhìn thấy ngay.
Tổng hợp & Đóng gói sản phẩm:
Kiểm thử lại toàn bộ luồng chạy của hệ thống để phát hiện lỗi (Bug).
Phụ trách chính việc viết File Báo cáo (.docx/.pdf) chi tiết: Mô tả hệ thống, chèn ảnh minh họa giao diện và bắt buộc phải dán Link GitHub Public của nhóm vào báo cáo.
Thiết kế Slide trình bày slide thuyết trình để nhóm báo cáo trước cô.
Xuất file script .sql của database, nén chung với folder code thành 1 file .zip duy nhất giao cho bạn (Leader) nộp lên Edunext.
