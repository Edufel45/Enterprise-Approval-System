table 50104 "Approval Delegation"
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
        
        field(2; "Delegate From"; Code[50])
        {
            Caption = 'Delegate From';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(3; "Delegate To"; Code[50])
        {
            Caption = 'Delegate To';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = ToBeClassified;
        }
        
        field(5; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = ToBeClassified;
        }
        
        field(6; "Request Type"; Enum "Request Type")
        {
            Caption = 'Request Type';
            DataClassification = ToBeClassified;
        }
        
        field(7; "Max Amount"; Decimal)
        {
            Caption = 'Maximum Amount';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2:2;
        }
        
        field(8; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = ToBeClassified;
            DefaultValue = true;
        }
        
        field(9; "Reason"; Text[200])
        {
            Caption = 'Reason';
            DataClassification = ToBeClassified;
        }
    }
    
    keys
    {
        key(PrimaryKey; "Entry No.")
        {
            Clustered = true;
        }
        
        key(DelegateKey; "Delegate From", "Is Active")
        {
        }
    }
}