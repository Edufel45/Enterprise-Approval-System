page 50102 "Approval Dashboard"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Reports;
    
    layout
    {
        area(Content)
        {
            group("Quick Statistics")
            {
                field(PendingCount; PendingCount)
                {
                    Caption = 'Pending Approvals';
                    ApplicationArea = All;
                }
                
                field(ApprovedToday; ApprovedToday)
                {
                    Caption = 'Approved Today';
                    ApplicationArea = All;
                }
                
                field(AverageTime; AverageTime)
                {
                    Caption = 'Avg Approval Time (Hours)';
                    ApplicationArea = All;
                }
                
                field(OverdueCount; OverdueCount)
                {
                    Caption = 'Overdue Approvals';
                    ApplicationArea = All;
                }
            }
            
            group("By Request Type")
            {
                part(SalesOrders; SalesOrdersPart)
                {
                    ApplicationArea = All;
                }
            }
            
            group("Top Approvers")
            {
                part(TopApprovers; TopApproversPart)
                {
                    ApplicationArea = All;
                }
            }
            
            group("Recent Activity")
            {
                part(RecentActivity; RecentActivityPart)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
    trigger OnOpenPage()
    begin
        UpdateStatistics();
    end;
    
    local procedure UpdateStatistics()
    {
        var
            ApprovalRequest: Record "Approval Request";
        begin
            // Count pending
            ApprovalRequest.SetRange(Status, "Approval Status"::Submitted);
            PendingCount := ApprovalRequest.Count();
            
            // Count approved today
            ApprovalRequest.SetRange(Status, "Approval Status"::Approved);
            ApprovalRequest.SetRange("Approval Date", Today(), Today());
            ApprovedToday := ApprovalRequest.Count();
            
            // Calculate average approval time
            CalculateAverageTime(AverageTime);
            
            // Count overdue
            ApprovalRequest.SetRange(Status, "Approval Status"::Submitted);
            ApprovalRequest.SetFilter("Due Date", '<%1', Today());
            OverdueCount := ApprovalRequest.Count();
        end;
    end;
    
    local procedure CalculateAverageTime(var AvgHours: Decimal)
    {
        var
            ApprovalRequest: Record "Approval Request";
            TotalHours: Decimal;
            Count: Integer;
        begin
            ApprovalRequest.SetRange(Status, "Approval Status"::Approved);
            
            if ApprovalRequest.FindSet() then
                repeat
                    TotalHours += (ApprovalRequest."Approval Date" - ApprovalRequest."Created Date") / (1000 * 3600);
                    Count += 1;
                until ApprovalRequest.Next() = 0;
            
            if Count > 0 then
                AvgHours := TotalHours / Count
            else
                AvgHours := 0;
        end;
    end;
    
    var
        PendingCount: Integer;
        ApprovedToday: Integer;
        AverageTime: Decimal;
        OverdueCount: Integer;
        SalesOrdersPart: Part;
        TopApproversPart: Part;
        RecentActivityPart: Part;
}