page 50105 "Approval Mobile"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Approval Request";
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(entryNo; "Entry No.")
                {
                    ApplicationArea = All;
                }
                
                field(amount; "Request Amount")
                {
                    ApplicationArea = All;
                    Style = Strong;
                }
                
                field(type; "Request Type")
                {
                    ApplicationArea = All;
                }
                
                field(status; Status)
                {
                    ApplicationArea = All;
                }
                
                field(approveButton; ApprovalAction)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
    var
        ApprovalAction: Action;
}