codeunit 50101 "Email Notification"
{
    /// <summary>
    /// Send email notification for approval requests
    /// </summary>
    procedure SendApprovalEmail(RequestNo: Integer; ToUser: Code[50]; Action: Text)
    {
        var
            ApprovalRequest: Record "Approval Request";
            User: Record User;
            EmailTemplate: Record "Email Template";
            Subject: Text;
            Body: Text;
            EmailAddress: Text;
        begin
            // Get the request details
            if not ApprovalRequest.Get(RequestNo) then
                Error('Request not found');
            
            // Get user's email
            if not User.Get(ToUser) then
                Error('User not found');
            
            EmailAddress := User."E-Mail";
            
            // Get email template based on action
            EmailTemplate.Get(GetTemplateCode(Action));
            
            // Replace placeholders in email
            Subject := ReplacePlaceholders(EmailTemplate.Subject, ApprovalRequest);
            Body := ReplacePlaceholders(EmailTemplate.Body, ApprovalRequest);
            
            // Send email
            SendEmail(EmailAddress, Subject, Body);
        end;
    }
    
    /// <summary>
    /// Send batch reminder emails for pending approvals
    /// </summary>
    procedure SendReminderEmails()
    {
        var
            ApprovalRequest: Record "Approval Request";
            CurrentApprover: Code[50];
            LastReminder: DateTime;
        begin
            // Find all pending requests
            ApprovalRequest.SetRange(Status, "Approval Status"::Submitted);
            
            if ApprovalRequest.FindSet() then
                repeat
                    // Check if reminder needed
                    if NeedReminder(ApprovalRequest) then
                    begin
                        SendApprovalEmail(
                            ApprovalRequest."Entry No.",
                            ApprovalRequest."Current Approver ID",
                            'REMINDER'
                        );
                        
                        // Update last reminder time (would need a field in table)
                        // ApprovalRequest."Last Reminder" := CurrentDateTime();
                        // ApprovalRequest.Modify();
                    end;
                until ApprovalRequest.Next() = 0;
        end;
    }
    
    local procedure GetTemplateCode(Action: Text): Code[20]
    {
        case Action of
            'SUBMIT': exit('APPROVAL_SUBMIT');
            'APPROVE': exit('APPROVAL_APPROVED');
            'REJECT': exit('APPROVAL_REJECTED');
            'REMINDER': exit('APPROVAL_REMINDER');
            'ESCALATE': exit('APPROVAL_ESCALATED');
        end;
        exit('DEFAULT');
    end;
    
    local procedure ReplacePlaceholders(Template: Text; Request: Record "Approval Request"): Text
    {
        var
            Result: Text;
        begin
            Result := Template;
            
            // Replace placeholders with actual values
            Result := StrSubstNo(Result, 
                Request."Entry No.",
                Request."Request Type",
                Request."Request Amount",
                Request."Requested By User ID",
                Request."Current Approver ID",
                Request."Request Reason"
            );
            
            exit(Result);
        end;
    }
    
    local procedure SendEmail(To: Text; Subject: Text; Body: Text)
    {
        // AL doesn't have built-in email. In real implementation:
        // 1. Use SMTP setup in Business Central
        // 2. Call Azure Logic Apps
        // 3. Use Microsoft Graph API
        
        // For now, log to message
        Message('EMAIL TO: %1\nSUBJECT: %2\nBODY: %3', To, Subject, Body);
        
        // In production, you'd use:
        // SMTP.Send(To, Subject, Body);
    }
    
    local procedure NeedReminder(Request: Record "Approval Request"): Boolean
    {
        var
            HoursPending: Decimal;
        begin
            // Calculate hours since submitted
            HoursPending := (CurrentDateTime() - Request."Submitted Date") / (1000 * 3600);
            
            // Send reminder after 24 hours
            exit(HoursPending >= 24);
        end;
    }
}