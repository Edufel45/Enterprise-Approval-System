codeunit 50100 "Approval Engine"
{
    // CODEUNIT = Container for business logic functions
    // Think of it as a "service" that other parts of the system can call
    
    /// <summary>
    /// Submit a request for approval
    /// Called when user clicks Submit button
    /// </summary>
    procedure SubmitRequest(var ApprovalRequest: Record "Approval Request")
    {
        // var = variable (temporary storage)
        // "Approval Request" is the record we're working on
        // var means we can change it and save back
        
        begin
            // Step 1: VALIDATION - Is this request ready to submit?
            if ApprovalRequest.Status <> "Approval Status"::Draft then
                Error('Only draft requests can be submitted. Current status: %1', ApprovalRequest.Status);
            
            // Step 2: DETERMINE APPROVERS - Who needs to approve?
            DetermineApprovers(ApprovalRequest);
            
            // Step 3: CHECK - Did we find any approvers?
            if ApprovalRequest."Total Levels" = 0 then
                Error('No approvers found. Please set up approval rules first.');
            
            // Step 4: UPDATE STATUS
            ApprovalRequest.Status := "Approval Status"::Submitted;
            ApprovalRequest."Submitted Date" := CurrentDateTime();
            
            // Step 5: SET CURRENT APPROVER (first approver) with delegation check
            case ApprovalRequest."Current Level" of
                1: ApprovalRequest."Current Approver ID" := GetDelegatedApprover(
                        ApprovalRequest."Approver 1 ID",
                        ApprovalRequest."Request Type",
                        ApprovalRequest."Request Amount");
                2: ApprovalRequest."Current Approver ID" := GetDelegatedApprover(
                        ApprovalRequest."Approver 2 ID",
                        ApprovalRequest."Request Type",
                        ApprovalRequest."Request Amount");
                3: ApprovalRequest."Current Approver ID" := GetDelegatedApprover(
                        ApprovalRequest."Approver 3 ID",
                        ApprovalRequest."Request Type",
                        ApprovalRequest."Request Amount");
                4: ApprovalRequest."Current Approver ID" := GetDelegatedApprover(
                        ApprovalRequest."Approver 4 ID",
                        ApprovalRequest."Request Type",
                        ApprovalRequest."Request Amount");
                5: ApprovalRequest."Current Approver ID" := GetDelegatedApprover(
                        ApprovalRequest."Approver 5 ID",
                        ApprovalRequest."Request Type",
                        ApprovalRequest."Request Amount");
            end;
            
            // Step 6: Set due date based on SLA
            SetDueDate(ApprovalRequest);
            
            // Step 7: SAVE to database
            ApprovalRequest.Modify(true);
            
            // Step 8: LOG to history
            LogHistory(
                ApprovalRequest."Entry No.",
                'Submitted',
                "Approval Status"::Draft,
                "Approval Status"::Submitted,
                '',
                0,
                ApprovalRequest."Current Level"
            );
            
            // Step 9: NOTIFY the approver
            SendEmailNotification(ApprovalRequest."Entry No.", 
                ApprovalRequest."Current Approver ID", 
                'SUBMIT');
            
            Message('Request #%1 submitted successfully. Waiting for approval from %2. Due by: %3', 
                ApprovalRequest."Entry No.", 
                ApprovalRequest."Current Approver ID",
                ApprovalRequest."Due Date");
        end;
    }
    
    /// <summary>
    /// Approve a request at current level
    /// Called when approver clicks Approve button
    /// </summary>
    procedure ApproveRequest(var ApprovalRequest: Record "Approval Request"; Comments: Text)
    {
        begin
            // Step 1: VALIDATION
            if ApprovalRequest.Status <> "Approval Status"::Submitted then
                Error('Only submitted requests can be approved. Current status: %1', ApprovalRequest.Status);
            
            if ApprovalRequest."Current Approver ID" <> UserId() then
                Error('You are not the assigned approver for this request. Current approver: %1', 
                    ApprovalRequest."Current Approver ID");
            
            // Step 2: LOG the approval action
            LogHistory(
                ApprovalRequest."Entry No.",
                'Approved',
                ApprovalRequest.Status,
                ApprovalRequest.Status,
                Comments,
                ApprovalRequest."Current Level",
                ApprovalRequest."Current Level"
            );
            
            // Step 3: CHECK if there are more approval levels
            if ApprovalRequest."Current Level" < ApprovalRequest."Total Levels" then
            begin
                // Move to next level
                ApprovalRequest."Current Level" := ApprovalRequest."Current Level" + 1;
                
                // Set the next approver with delegation check
                case ApprovalRequest."Current Level" of
                    1: ApprovalRequest."Current Approver ID" := GetDelegatedApprover(
                            ApprovalRequest."Approver 1 ID",
                            ApprovalRequest."Request Type",
                            ApprovalRequest."Request Amount");
                    2: ApprovalRequest."Current Approver ID" := GetDelegatedApprover(
                            ApprovalRequest."Approver 2 ID",
                            ApprovalRequest."Request Type",
                            ApprovalRequest."Request Amount");
                    3: ApprovalRequest."Current Approver ID" := GetDelegatedApprover(
                            ApprovalRequest."Approver 3 ID",
                            ApprovalRequest."Request Type",
                            ApprovalRequest."Request Amount");
                    4: ApprovalRequest."Current Approver ID" := GetDelegatedApprover(
                            ApprovalRequest."Approver 4 ID",
                            ApprovalRequest."Request Type",
                            ApprovalRequest."Request Amount");
                    5: ApprovalRequest."Current Approver ID" := GetDelegatedApprover(
                            ApprovalRequest."Approver 5 ID",
                            ApprovalRequest."Request Type",
                            ApprovalRequest."Request Amount");
                end;
                
                // Save changes
                ApprovalRequest.Modify(true);
                
                // Notify the next approver
                SendEmailNotification(ApprovalRequest."Entry No.",
                    ApprovalRequest."Current Approver ID",
                    'SUBMIT');
                
                Message('Request #%1 approved at level %2. Now waiting for %3.', 
                    ApprovalRequest."Entry No.", 
                    ApprovalRequest."Current Level" - 1,
                    ApprovalRequest."Current Approver ID");
            end
            else
            begin
                // FINAL LEVEL - request is fully approved
                ApprovalRequest.Status := "Approval Status"::Approved;
                ApprovalRequest."Approval Date" := CurrentDateTime();
                ApprovalRequest."Completed Date" := CurrentDateTime();
                ApprovalRequest.Modify(true);
                
                // Log final approval
                LogHistory(
                    ApprovalRequest."Entry No.",
                    'FullyApproved',
                    "Approval Status"::Submitted,
                    "Approval Status"::Approved,
                    Comments,
                    ApprovalRequest."Current Level",
                    ApprovalRequest."Current Level"
                );
                
                // Notify the requester
                SendEmailNotification(ApprovalRequest."Entry No.",
                    ApprovalRequest."Requested By User ID",
                    'APPROVE');
                
                Message('Request #%1 FULLY APPROVED!', ApprovalRequest."Entry No.");
            end;
        end;
    }
    
    /// <summary>
    /// Reject a request
    /// Called when approver clicks Reject button
    /// </summary>
    procedure RejectRequest(var ApprovalRequest: Record "Approval Request"; Comments: Text)
    {
        begin
            // Step 1: VALIDATION
            if ApprovalRequest.Status <> "Approval Status"::Submitted then
                Error('Only submitted requests can be rejected');
            
            if ApprovalRequest."Current Approver ID" <> UserId() then
                Error('You are not the assigned approver for this request');
            
            // Step 2: UPDATE STATUS
            ApprovalRequest.Status := "Approval Status"::Rejected;
            ApprovalRequest."Completed Date" := CurrentDateTime();
            ApprovalRequest."Rejection Reason" := Comments;
            ApprovalRequest.Modify(true);
            
            // Step 3: LOG the rejection
            LogHistory(
                ApprovalRequest."Entry No.",
                'Rejected',
                "Approval Status"::Submitted,
                "Approval Status"::Rejected,
                Comments,
                ApprovalRequest."Current Level",
                ApprovalRequest."Current Level"
            );
            
            // Step 4: NOTIFY the requester
            SendEmailNotification(ApprovalRequest."Entry No.",
                ApprovalRequest."Requested By User ID",
                'REJECT');
            
            Message('Request #%1 rejected', ApprovalRequest."Entry No.");
        end;
    }
    
    /// <summary>
    /// Determine who should approve based on rules
    /// Reads from ApprovalRule table to find matching rules
    /// </summary>
    local procedure DetermineApprovers(var ApprovalRequest: Record "Approval Request")
    {
        var
            ApprovalRule: Record "Approval Rule";
            Level: Integer;
            RuleFound: Boolean;
        begin
            // Reset approvers
            ApprovalRequest."Approver 1 ID" := '';
            ApprovalRequest."Approver 2 ID" := '';
            ApprovalRequest."Approver 3 ID" := '';
            ApprovalRequest."Approver 4 ID" := '';
            ApprovalRequest."Approver 5 ID" := '';
            ApprovalRequest."Total Levels" := 0;
            
            // Find all active rules
            ApprovalRule.SetRange("Is Active", true);
            
            if ApprovalRule.FindSet() then
                repeat
                    // Check if this rule applies to this request
                    if RuleApplies(ApprovalRule, ApprovalRequest) then
                    begin
                        // Add this approver at the specified level
                        case ApprovalRule."Approval Level" of
                            1: ApprovalRequest."Approver 1 ID" := ApprovalRule."Approver ID";
                            2: ApprovalRequest."Approver 2 ID" := ApprovalRule."Approver ID";
                            3: ApprovalRequest."Approver 3 ID" := ApprovalRule."Approver ID";
                            4: ApprovalRequest."Approver 4 ID" := ApprovalRule."Approver ID";
                            5: ApprovalRequest."Approver 5 ID" := ApprovalRule."Approver ID";
                        end;
                        
                        RuleFound := true;
                        
                        // Track highest level we found
                        if ApprovalRule."Approval Level" > ApprovalRequest."Total Levels" then
                            ApprovalRequest."Total Levels" := ApprovalRule."Approval Level";
                    end;
                until ApprovalRule.Next() = 0;
            
            // If no rules found, use default
            if not RuleFound then
            begin
                ApprovalRequest."Approver 1 ID" := 'DEFAULT_APPROVER';
                ApprovalRequest."Total Levels" := 1;
                Message('No matching rules found. Using default approver: DEFAULT_APPROVER');
            end;
        end;
    }
    
    /// <summary>
    /// Check if a rule applies to the request
    /// </summary>
    local procedure RuleApplies(ApprovalRule: Record "Approval Rule"; ApprovalRequest: Record "Approval Request"): Boolean
    {
        var
            Applies: Boolean;
        begin
            Applies := true;
            
            // Check Request Type
            if ApprovalRule."Request Type" <> '' then
                if ApprovalRule."Request Type" <> ApprovalRequest."Request Type" then
                    Applies := false;
            
            // Check Department
            if Applies and (ApprovalRule.Department <> '') then
                if ApprovalRule.Department <> ApprovalRequest.Department then
                    Applies := false;
            
            // Check Amount Range
            if Applies then
            begin
                if ApprovalRequest."Request Amount" < ApprovalRule."Min Amount" then
                    Applies := false;
                
                if ApprovalRequest."Request Amount" > ApprovalRule."Max Amount" then
                    Applies := false;
            end;
            
            exit(Applies);
        end;
    }
    
    /// <summary>
    /// Log an action to the history table
    /// This creates an audit trail
    /// </summary>
    local procedure LogHistory(
        RequestNo: Integer;
        Action: Text;
        OldStatus: Option;
        NewStatus: Option;
        Comments: Text;
        FromLevel: Integer;
        ToLevel: Integer)
    {
        var
            History: Record "Approval History";
        begin
            History.Init();
            History."Approval Request No." := RequestNo;
            History."Action Type" := Action;
            History."Old Status" := OldStatus;
            History."New Status" := NewStatus;
            History.Comments := Comments;
            History."From Level" := FromLevel;
            History."To Level" := ToLevel;
            History.Insert();
        end;
    }
    
    /// <summary>
    /// Send email notification
    /// </summary>
    local procedure SendEmailNotification(RequestNo: Integer; ToUser: Code[50]; Action: Text)
    {
        var
            EmailNotif: Codeunit "Email Notification";
        begin
            EmailNotif.SendApprovalEmail(RequestNo, ToUser, Action);
        end;
    }
    
    /// <summary>
    /// Check if user has delegated authority
    /// </summary>
    local procedure GetDelegatedApprover(OriginalApprover: Code[50]; RequestType: Enum "Request Type"; Amount: Decimal): Code[50]
    {
        var
            Delegation: Record "Approval Delegation";
            Today: Date;
        begin
            Today := CurrentDate();
            
            // Find active delegation
            Delegation.SetRange("Delegate From", OriginalApprover);
            Delegation.SetRange("Is Active", true);
            Delegation.SetFilter("Start Date", '<=%1', Today);
            Delegation.SetFilter("End Date", '>=%1', Today);
            
            if Delegation.FindFirst() then
            begin
                // Check if delegation applies to this request type
                if (Delegation."Request Type" = RequestType) or (Delegation."Request Type" = '') then
                begin
                    // Check amount limit
                    if (Delegation."Max Amount" = 0) or (Amount <= Delegation."Max Amount") then
                        exit(Delegation."Delegate To");
                end;
            end;
            
            exit(OriginalApprover);
        end;
    end;
    
    /// <summary>
    /// Set due date based on SLA rules
    /// </summary>
    local procedure SetDueDate(var ApprovalRequest: Record "Approval Request")
    {
        var
            SLA: Record "Service Level Agreement";
            ApprovalHours: Integer;
        begin
            // Find SLA for this request type and department
            SLA.SetRange("Request Type", ApprovalRequest."Request Type");
            SLA.SetRange(Department, ApprovalRequest.Department);
            
            if SLA.FindFirst() then
                ApprovalHours := SLA."Approval Hours"
            else
                ApprovalHours := 48;  // Default 48 hours
            
            // Calculate due date
            ApprovalRequest."Due Date" := CalcDueDate(Today(), ApprovalHours);
        end;
    end;
    
    /// <summary>
    /// Calculate due date by adding business hours
    /// </summary>
    local procedure CalcDueDate(StartDate: Date; Hours: Integer): Date
    {
        // Simplified: just add days
        // In production, you'd account for weekends and holidays
        exit(StartDate + (Hours / 24));
    end;
    
    /// <summary>
    /// Escalate a request (called by Escalation Engine)
    /// </summary>
    procedure EscalateRequest(var ApprovalRequest: Record "Approval Request")
    {
        var
            NextLevelApprover: Code[50];
        begin
            // Get next level approver
            NextLevelApprover := GetNextLevelApprover(ApprovalRequest);
            
            if NextLevelApprover <> '' then
            begin
                // Update escalation fields
                ApprovalRequest."Is Escalated" := true;
                ApprovalRequest."Escalation Count" += 1;
                ApprovalRequest."Last Escalation Date" := CurrentDateTime();
                ApprovalRequest."Escalated To" := NextLevelApprover;
                
                // Update current approver
                ApprovalRequest."Current Approver ID" := NextLevelApprover;
                ApprovalRequest.Modify(true);
                
                // Log escalation
                LogHistory(
                    ApprovalRequest."Entry No.",
                    'Escalated',
                    ApprovalRequest.Status,
                    ApprovalRequest.Status,
                    'Escalated due to timeout',
                    ApprovalRequest."Current Level",
                    ApprovalRequest."Current Level"
                );
                
                // Send notification
                SendEmailNotification(ApprovalRequest."Entry No.", NextLevelApprover, 'ESCALATE');
            end;
        end;
    end;
    
    /// <summary>
    /// Get next level approver for escalation
    /// </summary>
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
    
    /// <summary>
    /// Get department head for escalation
    /// </summary>
    local procedure GetDepartmentHead(Department: Enum Department): Code[50]
    {
        case Department of
            Department::Sales: exit('SALES_DIRECTOR');
            Department::Operations: exit('OPS_DIRECTOR');
            Department::Finance: exit('CFO');
            Department::IT: exit('IT_DIRECTOR');
            Department::HR: exit('HR_DIRECTOR');
            else exit('CEO');
        end;
    end;
}