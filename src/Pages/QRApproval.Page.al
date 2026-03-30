page 50112 "QR Approval Scanner"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    
    layout
    {
        area(Content)
        {
            group("QR Scanner")
            {
                field(QRCode; QRCodeInput)
                {
                    Caption = 'Scan QR Code';
                }
                
                field(RequestInfo; RequestDetails)
                {
                    Caption = 'Request Details';
                    ApplicationArea = All;
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(ScanQR)
            {
                Caption = 'Scan QR Code';
                Image = Camera;
                
                trigger OnAction();
                begin
                    // In production, open camera and scan
                    Message('Camera opened. Please scan QR code.');
                end;
            }
            
            action(ProcessQR)
            {
                Caption = 'Process QR Code';
                
                trigger OnAction();
                var
                    ApprovalEngine: Codeunit "Approval Engine";
                    Request: Record "Approval Request";
                    QRData: Text;
                    RequestNo: Integer;
                begin
                    QRData := QRCodeInput;
                    
                    // Parse QR data (format: APPROVAL|REQUESTNO|HASH)
                    if StrPos(QRData, 'APPROVAL|') = 1 then
                    begin
                        RequestNo := Evaluate(StrSubstNo(QRData, 'APPROVAL|%1|', RequestNo));
                        
                        if Request.Get(RequestNo) then
                        begin
                            RequestDetails := Format(Request);
                            
                            if Request.Status = "Approval Status"::Submitted then
                            begin
                                if Request."Current Approver ID" = UserId() then
                                begin
                                    if Confirm('Approve request #' + Format(RequestNo) + '?') then
                                    begin
                                        ApprovalEngine.ApproveRequest(Request, 'Approved via QR code');
                                        Message('Request approved');
                                    end;
                                end
                                else
                                    Message('You are not the assigned approver');
                            end
                            else
                                Message('Request is not pending approval');
                        end
                        else
                            Message('Request not found');
                    end
                    else
                        Message('Invalid QR code');
                end;
            }
        }
    }
    
    var
        QRCodeInput: Text;
        RequestDetails: Text;
}