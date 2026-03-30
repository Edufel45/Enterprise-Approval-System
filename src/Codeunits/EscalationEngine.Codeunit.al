codeunit 50102 "Escalation Engine"
{
    /// <summary>
    /// Check all pending requests and escalate if needed
    /// </summary>
    procedure CheckAndEscalate()
    {
        var
            ApprovalRequest: Record "Approval Request";
            HoursPending: Decimal;
            EscalationThreshold: Integer;
        begin
            // Find all submitted requests
            ApprovalRequest.SetRange(Status, "Approval Status"::Submitted);
            ApprovalRequest.SetRange("Is Escalated", false);
            
            if ApprovalRequest.FindSet() then
                repeat
                    HoursPending := (CurrentDateTime() - ApprovalRequest."Submitted Date") / (1000 * 3600);
                    EscalationThreshold := GetEscalationThreshold(ApprovalRequest);
                    
                    if HoursPending >= EscalationThreshold then
                        EscalateRequest(ApprovalRequest);
                        
                until ApprovalRequest.Next() = 0;
        end;
    end;
    
    local procedure EscalateRequest(var ApprovalRequest: Record "Approval Request")
    {
        var
            NextLevelApprover: Code[50];
            ApprovalEngine: Codeunit "Approval Engine";
        begin
            // Get next level approver
            NextLevelApprover := GetNextLevelApprover(ApprovalRequest);
            
            if NextLevelApprover <> '' then
            begin
                // Escalate to next level
                ApprovalRequest."Is Escalated" := true;
                ApprovalRequest."Escalation Count" += 1;
                ApprovalRequest."Last Escalation Date" := CurrentDateTime();
                ApprovalRequest."Escalated To" := NextLevelApprover;
                
                // Update current approver
                ApprovalRequest."Current Approver ID" := NextLevelApprover;
                ApprovalRequest.Modify(true);
                
                // Log escalation
                ApprovalEngine.LogHistory(
                    ApprovalRequest."Entry No.",
                    'Escalated',
                    ApprovalRequest.Status,
                    ApprovalRequest.Status,
                    'Escalated due to timeout',
                    ApprovalRequest."Current Level",
                    ApprovalRequest."Current Level"
                );
                
                // Send notification
                SendEscalationNotification(ApprovalRequest, NextLevelApprover);
            end;
        end;
    end;
    
    local procedure GetEscalationThreshold(Request: Record "Approval Request"): Integer
    {
        // Different thresholds based on request type
        case Request."Request Type" of
            Request."Request Type"::"Sales Order": exit(48);  // 48 hours
            Request."Request Type"::"Time Off": exit(24);     // 24 hours
            Request."Request Type"::"Credit Limit": exit(72); // 72 hours
            else exit(48);
        end;
    end;
    
    local procedure GetNextLevelApprover(Request: Record "Approval Request"): Code[50]
    {
        // Find next approver beyond current level
        if Request."Current Level" < Request."Total Levels" then
        begin
            case Request."Current Level" + 1 of
                1: exit(Request."Approver 1 ID");
                2: exit(Request."Approver 2 ID");
                3: exit(Request."Approver 3 ID");
                4: exit(Request."Approver 4 ID");
                5: exit(Request."Approver 5 ID");
            end;
        end;
        
        // If no next level, escalate to department head
        exit(GetDepartmentHead(Request.Department));
    end;
    
    local procedure GetDepartmentHead(Department: Enum Department): Code[50]
    {
        // In real system, look up from User table with role
        case Department of
            Department::Sales: exit('SALES_DIRECTOR');
            Department::Finance: exit('CFO');
            Department::IT: exit('IT_DIRECTOR');
            Department::HR: exit('HR_DIRECTOR');
            else exit('CEO');
        end;
    end;
    
    local procedure SendEscalationNotification(Request: Record "Approval Request"; ToUser: Code[50])
    {
        var
            EmailNotification: Codeunit "Email Notification";
        begin
            EmailNotification.SendApprovalEmail(
                Request."Entry No.",
                ToUser,
                'ESCALATE'
            );
        end;
    }
}