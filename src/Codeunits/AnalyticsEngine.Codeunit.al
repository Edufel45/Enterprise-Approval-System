codeunit 50110 "Analytics Engine"
{
    /// <summary>
    /// Calculate approval velocity metrics
    /// </summary>
    procedure GetApprovalVelocity(Department: Enum Department; StartDate: Date; EndDate: Date): Decimal
    {
        var
            ApprovalRequest: Record "Approval Request";
            TotalRequests: Integer;
            TotalHours: Decimal;
            AvgHours: Decimal;
        begin
            ApprovalRequest.SetRange(Department, Department);
            ApprovalRequest.SetRange("Request Date", StartDate, EndDate);
            ApprovalRequest.SetRange(Status, "Approval Status"::Approved);
            
            TotalRequests := ApprovalRequest.Count();
            
            if TotalRequests > 0 then
            begin
                if ApprovalRequest.FindSet() then
                    repeat
                        TotalHours += (ApprovalRequest."Approval Date" - ApprovalRequest."Submitted Date") / (1000 * 3600);
                    until ApprovalRequest.Next() = 0;
                
                AvgHours := TotalHours / TotalRequests;
            end;
            
            exit(AvgHours);
        end;
    end;
    
    /// <summary>
    /// Identify bottlenecks
    /// </summary>
    procedure GetBottlenecks(): Text
    {
        var
            ApprovalRequest: Record "Approval Request";
            ApproverStats: Record ApproverStat;
            Bottlenecks: Text;
        begin
            // Analyze pending requests by approver
            ApprovalRequest.SetRange(Status, "Approval Status"::Submitted);
            
            if ApprovalRequest.FindSet() then
                repeat
                    ApproverStats."Approver ID" := ApprovalRequest."Current Approver ID";
                    ApproverStats.PendingCount += 1;
                until ApprovalRequest.Next() = 0;
            
            // Find approvers with > 10 pending
            if ApproverStats.FindSet() then
                repeat
                    if ApproverStats.PendingCount > 10 then
                        Bottlenecks += ApproverStats."Approver ID" + ' (' + Format(ApproverStats.PendingCount) + ' pending), ';
                until ApproverStats.Next() = 0;
            
            if Bottlenecks = '' then
                Bottlenecks := 'No bottlenecks detected';
            
            exit(Bottlenecks);
        end;
    end;
    
    /// <summary>
    /// Get approval forecast
    /// </summary>
    procedure GetForecast(Months: Integer): Decimal
    {
        var
            Historical: Record "Approval Request";
            MonthlyAverage: Decimal;
            TotalRequests: Integer;
            MonthsCount: Integer;
        begin
            Historical.SetRange(Status, "Approval Status"::Approved);
            Historical.SetRange("Approval Date", Date - (Months * 30), Today());
            
            TotalRequests := Historical.Count();
            MonthsCount := Months;
            
            if MonthsCount > 0 then
                MonthlyAverage := TotalRequests / MonthsCount;
            
            // Apply growth factor (simplified)
            exit(MonthlyAverage * 1.1);
        end;
    end;
}

table 50123 "Approver Stat"
{
    fields
    {
        field(1; "Approver ID"; Code[50])
        { TableRelation = User; }
        
        field(2; "Pending Count"; Integer)
        { }
        
        field(3; "Approval Rate"; Decimal)
        { DecimalPlaces = 2:2; }
        
        field(4; "Avg Approval Time"; Decimal)
        { DecimalPlaces = 2:2; }
    }
}