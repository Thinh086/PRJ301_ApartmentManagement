package model;

public class Request {
    private int requestId;
    private int apartmentId;
    private int accountId;
    private String requestType;
    private String title;
    private String description;
    private String status;
    private String createdAt;
    
    // Additional fields for display
    private String apartmentCode;
    private String requesterName;
    private String assignedEmployeeName;
    private Integer assignedTo;
    private String latestProgress;
    private String latestProgressTime;

    public Request() {
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getApartmentId() {
        return apartmentId;
    }

    public void setApartmentId(int apartmentId) {
        this.apartmentId = apartmentId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getRequestType() {
        return requestType;
    }

    public void setRequestType(String requestType) {
        this.requestType = requestType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getApartmentCode() {
        return apartmentCode;
    }

    public void setApartmentCode(String apartmentCode) {
        this.apartmentCode = apartmentCode;
    }

    public String getRequesterName() {
        return requesterName;
    }

    public void setRequesterName(String requesterName) {
        this.requesterName = requesterName;
    }

    public String getAssignedEmployeeName() {
        return assignedEmployeeName;
    }

    public void setAssignedEmployeeName(String assignedEmployeeName) {
        this.assignedEmployeeName = assignedEmployeeName;
    }

    public Integer getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Integer assignedTo) {
        this.assignedTo = assignedTo;
    }

    public String getLatestProgress() {
        return latestProgress;
    }

    public void setLatestProgress(String latestProgress) {
        this.latestProgress = latestProgress;
    }

    public String getLatestProgressTime() {
        return latestProgressTime;
    }

    public void setLatestProgressTime(String latestProgressTime) {
        this.latestProgressTime = latestProgressTime;
    }

    @Override
    public String toString() {
        return "Request{" + "requestId=" + requestId + ", title='" + title + '\'' + ", status='" + status + '\'' + '}';
    }
}
