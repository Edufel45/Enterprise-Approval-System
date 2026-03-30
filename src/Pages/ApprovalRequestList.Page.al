page 50100 "Approval Request List"
{
    // PAGE TYPES:
    // List = shows multiple records in a table/grid
    // Card = shows one record in detail (like a form)
    // This is a LIST page
    
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    
    // Which table does this page show?
    SourceTable = "Approval Request";
    
    // LAYOUT = what appears on the screen
    layout
    {
        area(Content)
        {
            // repeater = the table/grid that shows rows
            repeater(General)
            {
                // These are the COLUMNS in the grid
                // Each field becomes a column
                
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    
                    // When user clicks the number, open the detail page
                    trigger OnDrillDown();
                    begin
                        Page.Run(50101, "Approval Request");
                    end;
                }
                
                field("Request Type"; "Request Type")
                {
                    ApplicationArea = All;
                }
                
                field("Request Date"; "Request Date")
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
                
                field(Status; Status)
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
    
    // ACTIONS = buttons on the page
    actions
    {
        // Processing area = main action buttons
        area(Processing)
        {
            // New Request button
            action(NewRequest)
            {
                Caption = 'New Request';
                
                trigger OnAction();
                begin
                    // Open the Card page to create a new request
                    if Page.RunModal(50101, "Approval Request") = Action::LookupOK then
                        CurrPage.Update();  // Refresh the list
                end;
            }
            
            // My Pending Approvals button - filter to show only what I need to approve
            action(MyPendingRequests)
            {
                Caption = 'My Pending Approvals';
                
                trigger OnAction();
                begin
                    // Filter to show only requests:
                    // 1. Status = Submitted (waiting for approval)
                    // 2. Current Approver = me
                    CurrPage.SetRange(Status, "Approval Status"::Submitted);
                    CurrPage.SetFilter("Current Approver ID", '=%1', UserId());
                end;
            }
            
            // Show All button - remove filters
            action(ShowAll)
            {
                Caption = 'Show All';
                
                trigger OnAction();
                begin
                    // Clear all filters
                    CurrPage.SetRange(Status);
                    CurrPage.SetFilter("Current Approver ID", '');
                end;
            }
        }
    }
    
    // This runs when page first opens
    trigger OnOpenPage()
    begin
        // Default: show requests that aren't completed
        // Don't show Approved or Rejected unless user asks
        CurrPage.SetRange(Status, 
            "Approval Status"::Draft, 
            "Approval Status"::Submitted);
    end;
}