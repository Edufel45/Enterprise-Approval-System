codeunit 50108 "WebSocket Notifier"
{
    /// <summary>
    /// Send real-time notification to user
    /// </summary>
    procedure PushNotification(UserId: Code[50]; Title: Text; Message: Text; RequestNo: Integer)
    {
        var
            UserNotification: Record "User Notification";
        begin
            // Store notification
            UserNotification.Init();
            UserNotification."User ID" := UserId;
            UserNotification.Title := Title;
            UserNotification.Message := Message;
            UserNotification."Request No." := RequestNo;
            UserNotification."Is Read" := false;
            UserNotification."Created Date" := CurrentDateTime();
            UserNotification.Insert();
            
            // In production, use SignalR or WebSocket
            // This would push to browser in real-time
            
            // For now, show message
            Message('Real-time notification to %1: %2 - %3', UserId, Title, Message);
        end;
    end;
    
    /// <summary>
    /// Subscribe user to approval events
    /// </summary>
    procedure SubscribeToApprovals(UserId: Code[50])
    {
        var
            Subscription: Record "Notification Subscription";
        begin
            Subscription.Init();
            Subscription."User ID" := UserId;
            Subscription."Subscription Type" := Subscription."Subscription Type"::AllApprovals;
            Subscription."Is Active" := true;
            Subscription."Created Date" := CurrentDateTime();
            Subscription.Insert();
            
            Message('User %1 subscribed to approval notifications', UserId);
        end;
    end;
    
    /// <summary>
    /// Send batch notifications
    /// </summary>
    procedure BroadcastNotification(Message: Text; RequestNo: Integer)
    {
        var
            Subscription: Record "Notification Subscription";
        begin
            Subscription.SetRange("Is Active", true);
            if Subscription.FindSet() then
                repeat
                    PushNotification(
                        Subscription."User ID",
                        'Approval Update',
                        Message,
                        RequestNo
                    );
                until Subscription.Next() = 0;
        end;
    end;
}

table 50121 "User Notification"
{
    fields
    {
        field(1; "Entry No."; Integer)
        { AutoIncrement = true; }
        
        field(2; "User ID"; Code[50])
        { TableRelation = User; }
        
        field(3; "Title"; Text[100])
        { }
        
        field(4; "Message"; Text[500])
        { }
        
        field(5; "Request No."; Integer)
        { TableRelation = "Approval Request"; }
        
        field(6; "Is Read"; Boolean)
        { DefaultValue = false; }
        
        field(7; "Created Date"; DateTime)
        { }
        
        field(8; "Read Date"; DateTime)
        { }
    }
}

table 50122 "Notification Subscription"
{
    fields
    {
        field(1; "Entry No."; Integer)
        { AutoIncrement = true; }
        
        field(2; "User ID"; Code[50])
        { TableRelation = User; }
        
        field(3; "Subscription Type"; Option)
        { OptionMembers = AllApprovals,MyApprovals,MyRequests,Departmental; }
        
        field(4; "Is Active"; Boolean)
        { DefaultValue = true; }
        
        field(5; "Created Date"; DateTime)
        { }
    }
}