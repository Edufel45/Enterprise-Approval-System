codeunit 50111 "Voice Assistant"
{
    /// <summary>
    /// Process voice command for approval
    /// </summary>
    procedure ProcessVoiceCommand(Command: Text)
    {
        var
            RequestNo: Integer;
            ApprovalEngine: Codeunit "Approval Engine";
            Request: Record "Approval Request";
        begin
            // Parse command
            Command := Lower(Command);
            
            // Pattern: "approve request one two three four"
            if StrPos(Command, 'approve request') > 0 then
            begin
                RequestNo := ExtractRequestNumber(Command);
                
                if Request.Get(RequestNo) then
                begin
                    if Request.Status = "Approval Status"::Submitted then
                    begin
                        if Request."Current Approver ID" = UserId() then
                        begin
                            ApprovalEngine.ApproveRequest(Request, 'Approved via voice command');
                            Respond('Request ' + Format(RequestNo) + ' approved');
                        end
                        else
                            Respond('You are not authorized to approve this request');
                    end
                    else
                        Respond('Request is not pending approval');
                end
                else
                    Respond('Request not found');
            end
            else if StrPos(Command, 'reject request') > 0 then
            begin
                RequestNo := ExtractRequestNumber(Command);
                
                if Request.Get(RequestNo) then
                begin
                    if Request.Status = "Approval Status"::Submitted then
                    begin
                        if Request."Current Approver ID" = UserId() then
                        begin
                            ApprovalEngine.RejectRequest(Request, 'Rejected via voice command');
                            Respond('Request ' + Format(RequestNo) + ' rejected');
                        end
                        else
                            Respond('You are not authorized to reject this request');
                    end
                    else
                        Respond('Request is not pending approval');
                end
                else
                    Respond('Request not found');
            end
            else if StrPos(Command, 'status of request') > 0 then
            begin
                RequestNo := ExtractRequestNumber(Command);
                
                if Request.Get(RequestNo) then
                    Respond('Request ' + Format(RequestNo) + ' is ' + Format(Request.Status))
                else
                    Respond('Request not found');
            end
            else
                Respond('Command not recognized. Try: approve request [number]');
        end;
    end;
    
    local procedure ExtractRequestNumber(Command: Text): Integer
    {
        var
            Words: Text;
            RequestNo: Integer;
        begin
            // Simple word to number conversion
            Command := Lower(Command);
            
            Command := StrSubstNo(Command, 'one', '1');
            Command := StrSubstNo(Command, 'two', '2');
            Command := StrSubstNo(Command, 'three', '3');
            Command := StrSubstNo(Command, 'four', '4');
            Command := StrSubstNo(Command, 'five', '5');
            Command := StrSubstNo(Command, 'six', '6');
            Command := StrSubstNo(Command, 'seven', '7');
            Command := StrSubstNo(Command, 'eight', '8');
            Command := StrSubstNo(Command, 'nine', '9');
            Command := StrSubstNo(Command, 'zero', '0');
            
            // Extract numbers
            // Simplified: assume last word is number
            exit(0);
        end;
    end;
    
    local procedure Respond(Message: Text)
    {
        // In production, use text-to-speech
        Message('Voice Assistant: ' + Message);
    end;
}