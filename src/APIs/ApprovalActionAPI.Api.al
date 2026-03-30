page 50104 "Approval Action API"
{
    PageType = API;
    APIPublisher = 'YourCompany';
    APIVersion = 'v1.0';
    APIGroup = 'approvals';
    
    EntityName = 'action';
    EntitySetName = 'actions';
    
    actions
    {
        action(Submit)
        {
            Caption = 'submit';
            
            trigger OnAction(var request: Record "Approval Request")
            var
                ApprovalEngine: Codeunit "Approval Engine";
            begin
                ApprovalEngine.SubmitRequest(request);
            end;
        }
        
        action(Approve)
        {
            Caption = 'approve';
            
            trigger OnAction(var request: Record "Approval Request")
            var
                ApprovalEngine: Codeunit "Approval Engine";
            begin
                ApprovalEngine.ApproveRequest(request, 'Approved via mobile');
            end;
        }
        
        action(Reject)
        {
            Caption = 'reject';
            
            trigger OnAction(var request: Record "Approval Request")
            var
                ApprovalEngine: Codeunit "Approval Engine";
            begin
                ApprovalEngine.RejectRequest(request, 'Rejected via mobile');
            end;
        }
    }
}