package controller;

import dal.RequestDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Request;
import model.User;

public class RequestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("submit".equals(action)) {
            // Hiển thị form gửi yêu cầu
            request.getRequestDispatcher("submit-request.jsp").forward(request, response);
            return;
        }
        
        // Mặc định: lấy danh sách yêu cầu của cư dân
        HttpSession session = request.getSession();
        User resident = (User) session.getAttribute("resident");
        int accountId;
        String residentName;
        
        String ridParam = request.getParameter("rid");
        if (ridParam != null && !ridParam.isEmpty()) {
            accountId = Integer.parseInt(ridParam);
            residentName = (accountId == 5) ? "Phạm Văn An" :
                           (accountId == 6) ? "Nguyễn Thị Bình" :
                           (accountId == 7) ? "Hoàng Văn Cường" : "Cư dân #" + accountId;
            resident = new User();
            resident.setAccountId(accountId);
            resident.setFullName(residentName);
            session.setAttribute("resident", resident);
        } else if (resident != null) {
            accountId = resident.getAccountId();
            residentName = resident.getFullName();
        } else {
            // Mặc định: Phạm Văn An (account_id=5, chủ căn hộ A101)
            accountId = 5;
            residentName = "Phạm Văn An";
            resident = new User();
            resident.setAccountId(5);
            resident.setFullName("Phạm Văn An");
            session.setAttribute("resident", resident);
        }
        
        // Lấy danh sách yêu cầu của cư dân
        RequestDAO dao = new RequestDAO();
        List<Request> requestList = dao.getRequestsByAccount(accountId);
        request.setAttribute("residentRequests", requestList);
        
        request.getRequestDispatcher("resident-requests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("createRequest".equals(action)) {
            String requestType = request.getParameter("requestType");
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            
            HttpSession session = request.getSession();
            User resident = (User) session.getAttribute("resident");
            int accountId = (resident != null) ? resident.getAccountId() : 5;
            int apartmentId = -1;
            
            RequestDAO dao = new RequestDAO();
            
            // Lấy apartment_id từ account_id
            apartmentId = dao.getApartmentIdByAccount(accountId);
            
            if (apartmentId == -1) {
                request.setAttribute("error", "Không tìm thấy căn hộ của bạn!");
                request.getRequestDispatcher("submit-request.jsp").forward(request, response);
                return;
            }
            
            if (title == null || title.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập tiêu đề yêu cầu!");
                request.getRequestDispatcher("submit-request.jsp").forward(request, response);
                return;
            }
            
            boolean success = dao.createRequest(apartmentId, accountId, requestType, title, description);
            
            if (success) {
                request.setAttribute("message", "Yêu cầu đã được gửi thành công! Trạng thái: Chờ duyệt");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi gửi yêu cầu!");
            }
            
            // Tải lại danh sách yêu cầu
            List<Request> requestList = dao.getRequestsByAccount(accountId);
            request.setAttribute("residentRequests", requestList);
            request.getRequestDispatcher("resident-requests.jsp").forward(request, response);
        }
    }
}
