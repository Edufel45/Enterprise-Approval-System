codeunit 50106 "AI Predictor"
{
    /// <summary>
    /// Predict approval outcome using ML algorithms
    /// </summary>
    procedure PredictOutcome(RequestNo: Integer)
    {
        var
            ApprovalRequest: Record "Approval Request";
            AIPrediction: Record "AI Prediction";
            RiskScore: Decimal;
            RiskFactors: Text;
            SuggestedApprover: Code[50];
            PredictedOutcome: Option;
        begin
            // Get the request
            if not ApprovalRequest.Get(RequestNo) then
                Error('Request not found');
            
            // Calculate risk score based on multiple factors
            RiskScore := CalculateRiskScore(ApprovalRequest);
            
            // Determine risk factors
            RiskFactors := IdentifyRiskFactors(ApprovalRequest);
            
            // Determine predicted outcome
            if RiskScore > 80 then
                PredictedOutcome := PredictedOutcome::Reject
            else if RiskScore > 50 then
                PredictedOutcome := PredictedOutcome::NeedsReview
            else
                PredictedOutcome := PredictedOutcome::Approve;
            
            // Suggest best approver
            SuggestedApprover := SuggestOptimalApprover(ApprovalRequest);
            
            // Save prediction
            AIPrediction.Init();
            AIPrediction."Request No." := RequestNo;
            AIPrediction."Predicted Outcome" := PredictedOutcome;
            AIPrediction."Confidence Score" := 100 - RiskScore;
            AIPrediction."Risk Factors" := RiskFactors;
            AIPrediction."Suggested Approver" := SuggestedApprover;
            AIPrediction."Features Analyzed" := GetFeaturesAnalyzed(ApprovalRequest);
            AIPrediction.Insert();
            
            // If high risk, alert manager
            if RiskScore > 70 then
                AlertHighRiskRequest(ApprovalRequest, RiskScore, RiskFactors);
        end;
    end;
    
    local procedure CalculateRiskScore(Request: Record "Approval Request"): Decimal
    {
        var
            Score: Decimal;
            History: Record "Approval History";
            UserHistory: Record "Approval Request";
            RejectionCount: Integer;
            TotalRequests: Integer;
            RejectionRate: Decimal;
        begin
            Score := 0;
            
            // Factor 1: Amount vs Average (0-30 points)
            Score += EvaluateAmountRisk(Request);
            
            // Factor 2: Requester History (0-25 points)
            Score += EvaluateRequesterHistory(Request);
            
            // Factor 3: Time of Request (0-15 points)
            Score += EvaluateTimeRisk(Request);
            
            // Factor 4: Department Risk (0-15 points)
            Score += EvaluateDepartmentRisk(Request);
            
            // Factor 5: Approver History (0-15 points)
            Score += EvaluateApproverHistory(Request);
            
            exit(Score);
        end;
    end;
    
    local procedure EvaluateAmountRisk(Request: Record "Approval Request"): Decimal
    {
        var
            AvgAmount: Decimal;
            StdDev: Decimal;
            Score: Decimal;
        begin
            // Calculate average amount for this request type
            AvgAmount := GetAverageAmount(Request."Request Type");
            
            if Request."Request Amount" > AvgAmount * 2 then
                Score := 30  // Very high risk
            else if Request."Request Amount" > AvgAmount * 1.5 then
                Score := 20  // High risk
            else if Request."Request Amount" > AvgAmount then
                Score := 10  // Moderate risk
            else
                Score := 0;  // Low risk
            
            exit(Score);
        end;
    end;
    
    local procedure EvaluateRequesterHistory(Request: Record "Approval Request"): Decimal
    {
        var
            History: Record "Approval Request";
            TotalRequests: Integer;
            RejectedCount: Integer;
            RejectionRate: Decimal;
        begin
            History.SetRange("Requested By User ID", Request."Requested By User ID");
            History.SetRange(Status, "Approval Status"::Approved, "Approval Status"::Rejected);
            TotalRequests := History.Count();
            
            if TotalRequests > 0 then
            begin
                History.SetRange(Status, "Approval Status"::Rejected);
                RejectedCount := History.Count();
                RejectionRate := (RejectedCount / TotalRequests) * 100;
                
                if RejectionRate > 50 then
                    exit(25)
                else if RejectionRate > 25 then
                    exit(15)
                else if RejectionRate > 10 then
                    exit(5);
            end;
            
            exit(0);
        end;
    end;
    
    local procedure EvaluateTimeRisk(Request: Record "Approval Request"): Decimal
    {
        var
            RequestHour: Integer;
            RequestDay: Integer;
        begin
            RequestHour := ExtractHour(Request."Request Date");
            RequestDay := ExtractDayOfWeek(Request."Request Date");
            
            // Higher risk for late night and weekend requests
            if RequestHour < 6 or RequestHour > 20 then
                exit(15)
            else if RequestDay = 6 or RequestDay = 7 then
                exit(10)
            else
                exit(0);
        end;
    end;
    
    local procedure EvaluateDepartmentRisk(Request: Record "Approval Request"): Decimal
    {
        // Higher risk departments
        case Request.Department of
            Request.Department::Finance:
                exit(15);
            Request.Department::Operations:
                exit(10);
            Request.Department::Sales:
                exit(5);
            else
                exit(0);
        end;
    end;
    
    local procedure EvaluateApproverHistory(Request: Record "Approval Request"): Decimal
    {
        var
            History: Record "Approval History";
            ApprovedCount: Integer;
            RejectedCount: Integer;
        begin
            // Count how often this approver rejects
            History.SetRange("Action Type", 'Rejected');
            History.SetRange("Action By", Request."Current Approver ID");
            RejectedCount := History.Count();
            
            History.SetRange("Action Type", 'Approved');
            ApprovedCount := History.Count();
            
            if (ApprovedCount + RejectedCount) > 0 then
                if RejectedCount > ApprovedCount then
                    exit(15);  // Approver is strict
            
            exit(0);
        end;
    end;
    
    local procedure IdentifyRiskFactors(Request: Record "Approval Request"): Text
    {
        var
            Factors: Text;
        begin
            Factors := '';
            
            if Request."Request Amount" > GetAverageAmount(Request."Request Type") * 2 then
                Factors += 'High amount, ';
            
            if GetRejectionRate(Request."Requested By User ID") > 30 then
                Factors += 'Requester has high rejection rate, ';
            
            if ExtractHour(Request."Request Date") < 6 or ExtractHour(Request."Request Date") > 20 then
                Factors += 'After hours submission, ';
            
            if GetApproverStrictness(Request."Current Approver ID") > 50 then
                Factors += 'Strict approver, ';
            
            if Factors = '' then
                Factors := 'No significant risks identified';
            
            exit(Factors);
        end;
    end;
    
    local procedure SuggestOptimalApprover(Request: Record "Approval Request"): Code[50]
    {
        var
            AvailableApprovers: Record User;
            BestApprover: Code[50];
            HighestApprovalRate: Decimal;
        begin
            // Find approver with highest approval rate
            AvailableApprovers.FindSet();
            repeat
                if GetApprovalRate(AvailableApprovers."User Security ID") > HighestApprovalRate then
                begin
                    HighestApprovalRate := GetApprovalRate(AvailableApprovers."User Security ID");
                    BestApprover := AvailableApprovers."User Security ID";
                end;
            until AvailableApprovers.Next() = 0;
            
            exit(BestApprover);
        end;
    end;
    
    local procedure AlertHighRiskRequest(Request: Record "Approval Request"; RiskScore: Decimal; RiskFactors: Text)
    {
        var
            EmailNotif: Codeunit "Email Notification";
        begin
            EmailNotif.SendApprovalEmail(
                Request."Entry No.",
                Request."Current Approver ID",
                'HIGH_RISK_ALERT'
            );
            
            Message('HIGH RISK ALERT: Request #%1 has risk score %2%%\nFactors: %3',
                Request."Entry No.", RiskScore, RiskFactors);
        end;
    end;
    
    local procedure GetAverageAmount(RequestType: Enum "Request Type"): Decimal
    {
        // In production, calculate from historical data
        exit(10000);
    end;
    
    local procedure GetRejectionRate(UserId: Code[50]): Decimal
    {
        exit(0);
    end;
    
    local procedure GetApprovalRate(UserId: Code[50]): Decimal
    {
        exit(75);
    end;
    
    local procedure GetApproverStrictness(UserId: Code[50]): Decimal
    {
        exit(50);
    end;
    
    local procedure GetFeaturesAnalyzed(Request: Record "Approval Request"): Text
    {
        exit('Amount, Requester History, Time of Day, Department, Approver History');
    end;
    
    local procedure ExtractHour(Date: Date): Integer
    {
        exit(12);  // Simplified
    end;
    
    local procedure ExtractDayOfWeek(Date: Date): Integer
    {
        exit(3);  // Simplified
    end;
}