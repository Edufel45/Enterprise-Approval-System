table 50101 "Approval History"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        
        field(2; "Approval Request No."; Integer)
        {
            Caption = 'Approval Request No.';
            DataClassification = ToBeClassified;
            TableRelation = "Approval Request";
        }
        
        field(3; "Action Date"; DateTime)
        {
            Caption = 'Action Date';
            DataClassification = ToBeClassified;
        }
        
        field(4; "Action Type"; Option)
        {
            Caption = 'Action Type';
            OptionMembers = Created,Submitted,Approved,Rejected,Returned,Expired;
            OptionCaption = 'Created','Submitted','Approved','Rejected','Returned','Expired';
            DataClassification = ToBeClassified;
        }
        
        field(5; "Action By"; Code[50])
        {
            Caption = 'Action By';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(6; "From Level"; Integer)
        {
            Caption = 'From Level';
            DataClassification = ToBeClassified;
        }
        
        field(7; "To Level"; Integer)
        {
            Caption = 'To Level';
            DataClassification = ToBeClassified;
        }
        
        field(8; "Comments"; Text[500])
        {
            Caption = 'Comments';
            DataClassification = ToBeClassified;
        }
        
        field(9; "Old Status"; Option)
        {
            Caption = 'Old Status';
            DataClassification = ToBeClassified;
            OptionMembers = Draft,Submitted,"In Review",Approved,Rejected,Expired;
        }
        
        field(10; "New Status"; Option)
        {
            Caption = 'New Status';
            DataClassification = ToBeClassified;
            OptionMembers = Draft,Submitted,"In Review",Approved,Rejected,Expired;
        }
    }
    
    keys
    {
        key(PrimaryKey; "Entry No.")
        {
            Clustered = true;
        }
        
        key(RequestKey; "Approval Request No.")
        {
        }
    }
    
    trigger OnInsert()
    begin
        "Action Date" := CurrentDateTime();
        "Action By" := UserId();
    end;
}