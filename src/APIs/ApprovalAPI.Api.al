page 50103 "Approval API"
{
    PageType = API;
    APIPublisher = 'YourCompany';
    APIVersion = 'v1.0';
    APIGroup = 'approvals';
    
    EntityName = 'approval';
    EntitySetName = 'approvals';
    SourceTable = "Approval Request";
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(entryNo; "Entry No.")
                {
                    Caption = 'entryNo';
                }
                
                field(requestType; "Request Type")
                {
                    Caption = 'requestType';
                }
                
                field(amount; "Request Amount")
                {
                    Caption = 'amount';
                }
                
                field(status; Status)
                {
                    Caption = 'status';
                }
                
                field(requestedBy; "Requested By User ID")
                {
                    Caption = 'requestedBy';
                }
                
                field(currentApprover; "Current Approver ID")
                {
                    Caption = 'currentApprover';
                }
                
                field(submittedDate; "Submitted Date")
                {
                    Caption = 'submittedDate';
                }
                
                field(reason; "Request Reason")
                {
                    Caption = 'reason';
                }
            }
        }
    }
}