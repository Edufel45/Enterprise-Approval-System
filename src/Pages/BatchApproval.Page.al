page 50111 "Batch Approval"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Approval Request";
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Select; Selected)
                {
                    ApplicationArea = All;
                }
                
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                
                field("Request Type"; "Request Type")
                {
                    ApplicationArea = All;
                }
                
                field("Request Amount"; "Request Amount")
                {
                    ApplicationArea = All;
                }
                
                field("Requested By User ID"; "Requested By User ID")
                {
                    ApplicationArea = All;
                }
                
                field("Current Approver ID"; "Current Approver ID")
                {
                    ApplicationArea = All;
                }
                
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(ApproveSelected)
            {
                Caption = 'Approve Selected';
                Image = Approve;
                
                trigger OnAction();
                var
                    ApprovalEngine: Codeunit "Approval Engine";
                    Request: Record "Approval Request";
                    Count: Integer;
                    SelectedRequests: Text;
                begin
                    Count := 0;
                    SelectedRequests := '';
                    
                    // Process selected requests
                    Request.SetRange(Status, "Approval Status"::Submitted);
                    Request.SetRange("Current Approver ID", UserId());
                    
                    if Request.FindSet() then
                        repeat
                            if Selected then
                            begin
                                ApprovalEngine.ApproveRequest(Request, 'Batch approved');
                                Count += 1;
                                SelectedRequests += Format(Request."Entry No.") + ', ';
                            end;
                        until Request.Next() = 0;
                    
                    Message('%1 requests approved: %2', Count, SelectedRequests);
                    CurrPage.Update();
                end;
            }
            
            action(ApproveAllSimilar)
            {
                Caption = 'Approve All Similar';
                Image = Approve;
                
                trigger OnAction();
                var
                    ApprovalEngine: Codeunit "Approval Engine";
                    Request: Record "Approval Request";
                    Count: Integer;
                    RequestType: Enum "Request Type";
                    MinAmount: Decimal;
                    MaxAmount: Decimal;
                begin
                    // Get criteria from current selection
                    RequestType := Rec."Request Type";
                    MinAmount := Rec."Request Amount";
                    MaxAmount := MinAmount * 1.1;  // Within 10%
                    
                    // Find similar requests
                    Request.SetRange(Status, "Approval Status"::Submitted);
                    Request.SetRange("Current Approver ID", UserId());
                    Request.SetRange("Request Type", RequestType);
                    Request.SetFilter("Request Amount", '>=%1 and <=%2', MinAmount, MaxAmount);
                    
                    Count := 0;
                    if Request.FindSet() then
                        repeat
                            ApprovalEngine.ApproveRequest(Request, 'Batch approved (similar)');
                            Count += 1;
                        until Request.Next() = 0;
                    
                    Message('%1 similar requests approved', Count);
                    CurrPage.Update();
                end;
            }
            
            action(RejectSelected)
            {
                Caption = 'Reject Selected';
                Image = Deny;
                
                trigger OnAction();
                var
                    ApprovalEngine: Codeunit "Approval Engine";
                    Request: Record "Approval Request";
                    Count: Integer;
                begin
                    Count := 0;
                    
                    Request.SetRange(Status, "Approval Status"::Submitted);
                    Request.SetRange("Current Approver ID", UserId());
                    
                    if Request.FindSet() then
                        repeat
                            if Selected then
                            begin
                                ApprovalEngine.RejectRequest(Request, 'Batch rejected');
                                Count += 1;
                            end;
                        until Request.Next() = 0;
                    
                    Message('%1 requests rejected', Count);
                    CurrPage.Update();
                end;
            }
        }
    }
    
    var
        Selected: Boolean;
}