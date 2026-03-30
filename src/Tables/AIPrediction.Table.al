table 50106 "AI Prediction"
{
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        
        field(2; "Request No."; Integer)
        {
            Caption = 'Request No.';
            DataClassification = ToBeClassified;
            TableRelation = "Approval Request";
        }
        
        field(3; "Predicted Outcome"; Option)
        {
            Caption = 'Predicted Outcome';
            OptionMembers = Approve,Reject,NeedsReview;
            OptionCaption = 'Approve','Reject','Needs Review';
            DataClassification = ToBeClassified;
        }
        
        field(4; "Confidence Score"; Decimal)
        {
            Caption = 'Confidence Score (%)';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2:2;
            MinValue = 0;
            MaxValue = 100;
        }
        
        field(5; "Risk Factors"; Text[500])
        {
            Caption = 'Risk Factors';
            DataClassification = ToBeClassified;
        }
        
        field(6; "Suggested Approver"; Code[50])
        {
            Caption = 'Suggested Approver';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(7; "Prediction Date"; DateTime)
        {
            Caption = 'Prediction Date';
            DataClassification = ToBeClassified;
        }
        
        field(8; "Actual Outcome"; Option)
        {
            Caption = 'Actual Outcome';
            OptionMembers = Approve,Reject;
            DataClassification = ToBeClassified;
        }
        
        field(9; "Accuracy Feedback"; Decimal)
        {
            Caption = 'Accuracy Feedback (%)';
            DataClassification = ToBeClassified;
        }
        
        field(10; "Features Analyzed"; Text[1000])
        {
            Caption = 'Features Analyzed';
            DataClassification = ToBeClassified;
        }
    }
    
    keys
    {
        key(PrimaryKey; "Entry No.")
        {
            Clustered = true;
        }
        
        key(RequestKey; "Request No.")
        {
        }
    }
    
    trigger OnInsert()
    begin
        "Prediction Date" := CurrentDateTime();
    end;
}