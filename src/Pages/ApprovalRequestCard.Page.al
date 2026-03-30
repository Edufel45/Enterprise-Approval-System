page 50101 "Approval Request Card"
{
    // CARD page = detail view (like a form)
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Records;
    SourceTable = "Approval Request";
    
    // LAYOUT = what appears on the screen
    layout
    {
        area(Content)
        {
            // Group = sections on the page
            group("Request Details")
            {
                // Fields that are editable (user can type)
                
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;  // Can't edit - auto-generated
                }
                
                field("Request Type"; "Request Type")
                {
                    ApplicationArea = All;
                    // When user changes type, we might need to update approvers
                    trigger OnValidate();
                    begin
                        // If it's a draft, we can reset approvers
                        if Rec.Status = "Approval Status"::Draft then
                            Rec."Total Levels" := 0;
                    end;
                }
                
                field(Department; Department)
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
                
                field("Request Reason"; "Request Reason")
                {
                    ApplicationArea = All;
                }
            }
            
            group("Requestor Information")
            {
                field("Requested By User ID"; "Requested By User ID")
                {
                    ApplicationArea = All;
                    Editable = false;  // Can't change who requested
                }
            }
            
            group("Approval Workflow")
            {
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;  // Status changes via buttons only
                }
                
                field("Current Level"; "Current Level")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                
                field("Total Levels"; "Total Levels")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                
                field("Current Approver ID"; "Current Approver ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = All;
                }
            }
            
            group("Approvers")
            {
                ShowCaption = true;
                
                field("Approver 1 ID"; "Approver 1 ID")
                {
                    ApplicationArea = All;
                    Editable = false;  // Set by rules engine
                }
                
                field("Approver 2 ID"; "Approver 2 ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                
                field("Approver 3 ID"; "Approver 3 ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                
                field("Approver 4 ID"; "Approver 4 ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                
                field("Approver 5 ID"; "Approver 5 ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            
            group(Comments)
            {
                field("Approver Comments"; "Approver Comments")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
    // BUTTONS
    actions
    {
        area(Processing)
        {
            // SUBMIT button - calls the Approval Engine
            action(SubmitAction)
            {
                Caption = 'Submit for Approval';
                Enabled = Status = "Approval Status"::Draft;
                
                trigger OnAction();
                var
                    ApprovalEngine: Codeunit "Approval Engine";
                begin
                    // Call the Codeunit to submit the request
                    ApprovalEngine.SubmitRequest(Rec);
                    
                    // Refresh the page to show updated status
                    CurrPage.Update();
                end;
            }
            
            // APPROVE button - calls the Approval Engine
            action(ApproveAction)
            {
                Caption = 'Approve';
                Enabled = Status = "Approval Status"::Submitted and 
                          "Current Approver ID" = UserId();
                
                trigger OnAction();
                var
                    ApprovalEngine: Codeunit "Approval Engine";
                    Comments: Text;
                begin
                    // Get comments from the field
                    Comments := Rec."Approver Comments";
                    
                    // Call the Codeunit to approve
                    ApprovalEngine.ApproveRequest(Rec, Comments);
                    
                    // Refresh the page
                    CurrPage.Update();
                end;
            }
            
            // REJECT button - calls the Approval Engine
            action(RejectAction)
            {
                Caption = 'Reject';
                Enabled = Status = "Approval Status"::Submitted and 
                          "Current Approver ID" = UserId();
                
                trigger OnAction();
                var
                    ApprovalEngine: Codeunit "Approval Engine";
                    Comments: Text;
                begin
                    // Get comments or use default
                    Comments := Rec."Approver Comments";
                    if Comments = '' then
                        Comments := 'Rejected by approver';
                    
                    // Call the Codeunit to reject
                    ApprovalEngine.RejectRequest(Rec, Comments);
                    
                    // Refresh the page
                    CurrPage.Update();
                end;
            }
        }
    }
    
    // This runs when creating a NEW request
    trigger OnInsert()
    begin
        // Default values for a new request
        Rec."Requested By User ID" := UserId();
        Rec."Request Date" := Today();
        Rec.Status := "Approval Status"::Draft;
        Rec."Current Level" := 1;
        
        // Temporary: set a default approver so we can test
        // In real system, this comes from rules
        Rec."Approver 1 ID" := 'MANAGER';  // You'll change this later
        Rec."Total Levels" := 1;
    end;
    
    // This runs when loading an existing request
    trigger OnAfterGetRecord()
    begin
        // Update UI based on status
        if Rec.Status = "Approval Status"::Approved then
        begin
            // If approved, disable approve button
            CurrPage.ApproveAction.Enabled := false;
            CurrPage.SubmitAction.Enabled := false;
        end
        else if Rec.Status = "Approval Status"::Rejected then
        begin
            CurrPage.ApproveAction.Enabled := false;
            CurrPage.SubmitAction.Enabled := false;
        end;
    end;
}