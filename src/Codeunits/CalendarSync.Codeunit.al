codeunit 50112 "Calendar Sync"
{
    /// <summary>
    /// Create calendar event for approval
    /// </summary>
    procedure CreateCalendarEvent(Request: Record "Approval Request")
    {
        var
            EventSubject: Text;
            EventBody: Text;
            EventStart: DateTime;
            EventEnd: DateTime;
        begin
            EventSubject := 'APPROVAL NEEDED: Request #' + Format(Request."Entry No.") + 
                            ' - ' + Format(Request."Request Amount") + 
                            ' - Due ' + Format(Request."Due Date");
            
            EventBody := 'Request Details:' + '\n' +
                         'Type: ' + Format(Request."Request Type") + '\n' +
                         'Amount: ' + Format(Request."Request Amount") + '\n' +
                         'Reason: ' + Request."Request Reason" + '\n' +
                         'Submitted By: ' + Request."Requested By User ID" + '\n' +
                         'Link: https://businesscentral/approvals/' + Format(Request."Entry No.");
            
            EventStart := Request."Due Date" - 1;
            EventEnd := Request."Due Date";
            
            // In production, call Outlook/Google Calendar API
            Message('Calendar event created for %1:\nSubject: %2\nStart: %3', 
                Request."Current Approver ID", EventSubject, EventStart);
        end;
    end;
    
    /// <summary>
    /// Sync approvals with user calendar
    /// </summary>
    procedure SyncWithOutlook(UserId: Code[50])
    {
        var
            Request: Record "Approval Request";
        begin
            Request.SetRange("Current Approver ID", UserId);
            Request.SetRange(Status, "Approval Status"::Submitted);
            
            if Request.FindSet() then
                repeat
                    CreateCalendarEvent(Request);
                until Request.Next() = 0;
            
            Message('Calendar synced for user %1', UserId);
        end;
    end;
    
    /// <summary>
    /// Create reminder for overdue approvals
    /// </summary>
    procedure CreateReminders()
    {
        var
            Request: Record "Approval Request";
        begin
            Request.SetRange(Status, "Approval Status"::Submitted);
            Request.SetFilter("Due Date", '<%1', Today());
            
            if Request.FindSet() then
                repeat
                    CreateCalendarEvent(Request);
                until Request.Next() = 0;
        end;
    end;
}