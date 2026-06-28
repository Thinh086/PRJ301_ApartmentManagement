package controller;

import dal.EmployeeDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Request;
import model.User;

public class EmployeeTaskServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy thông tin nhân viên từ session hoặc query param (?eid=4)
        HttpSession session = request.getSession();
        User employee = (User) session.getAttribute("employee");
        int employeeId;
        
        // Cho phép truyền employeeId qua query param để dễ test
        String eidParam = request.getParameter("eid");
        if (eidParam != null && !eidParam.isEmpty()) {
            employeeId = Integer.parseInt(eidParam);
            employee = new User();
            employee.setAccountId(employeeId);
            String name = (employeeId == 4) ? "Lê Văn Kỹ Thuật" : 
                          (employeeId == 3) ? "Trần Thị Nhân Viên" : "Nhân Viên #" + employeeId;
            employee.setFullName(name);
            session.setAttribute("employee", employee);
        } else if (employee != null) {
            employeeId = employee.getAccountId();
        } else {
            // Mặc định lấy nhanvien02 (account_id=4 - Lê Văn Kỹ Thuật) vì có task mẫu
            employeeId = 4;
            employee = new User();
            employee.setAccountId(4);
            employee.setFullName("Lê Văn Kỹ Thuật");
            session.setAttribute("employee", employee);
        }
        
        // Lấy danh sách công việc được gán cho nhân viên
        EmployeeDAO dao = new EmployeeDAO();
        List<Request> taskList = dao.getTasksByEmployee(employeeId);
        request.setAttribute("taskList", taskList);
        
        request.getRequestDispatcher("manage-employee-tasks.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("updateProgress".equals(action)) {
            String requestIdStr = request.getParameter("requestId");
            String newStatus = request.getParameter("newStatus");
            String description = request.getParameter("description");
            
            if (requestIdStr != null && newStatus != null) {
                int requestId = Integer.parseInt(requestIdStr);
                
                HttpSession session = request.getSession();
                User employee = (User) session.getAttribute("employee");
                int employeeId = (employee != null) ? employee.getAccountId() : 3;
                
                if (description == null || description.trim().isEmpty()) {
                    description = "Cập nhật tiến độ: " + newStatus;
                }
                
                EmployeeDAO dao = new EmployeeDAO();
                boolean success = dao.updateTaskProgress(requestId, employeeId, newStatus, description);
                
                if (success) {
                    request.setAttribute("message", "Cập nhật tiến độ thành công! Trạng thái: " + newStatus);
                } else {
                    request.setAttribute("error", "Có lỗi xảy ra khi cập nhật tiến độ!");
                }
            }
        }
        
        // Tải lại danh sách công việc
        EmployeeDAO dao = new EmployeeDAO();
        HttpSession session = request.getSession();
        User employee = (User) session.getAttribute("employee");
        int employeeId = (employee != null) ? employee.getAccountId() : 3;
        List<Request> taskList = dao.getTasksByEmployee(employeeId);
        request.setAttribute("taskList", taskList);
        
        request.getRequestDispatcher("manage-employee-tasks.jsp").forward(request, response);
    }
}
