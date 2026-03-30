table 50102 "Approval Rule"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Rule Code';
            DataClassification = ToBeClassified;
        }
        
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        
        field(3; "Request Type"; Enum "Request Type")
        {
            Caption = 'Request Type';
            DataClassification = ToBeClassified;
        }
        
        field(4; "Department"; Enum Department)
        {
            Caption = 'Department';
            DataClassification = ToBeClassified;
        }
        
        field(5; "Min Amount"; Decimal)
        {
            Caption = 'Minimum Amount';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2:2;
            DefaultValue = 0;
        }
        
        field(6; "Max Amount"; Decimal)
        {
            Caption = 'Maximum Amount';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2:2;
            DefaultValue = 999999999;
        }
        
        field(7; "Approval Level"; Integer)
        {
            Caption = 'Approval Level';
            DataClassification = ToBeClassified;
            MinValue = 1;
            MaxValue = 5;
        }
        
        field(8; "Approver ID"; Code[50])
        {
            Caption = 'Approver ID';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(9; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = ToBeClassified;
            DefaultValue = true;
        }
        
        field(10; "Priority"; Integer)
        {
            Caption = 'Priority';
            DataClassification = ToBeClassified;
            DefaultValue = 1;
        }
    }
    
    keys
    {
        key(PrimaryKey; Code)
        {
            Clustered = true;
        }
        
        key(ActiveRules; "Is Active")
        {
        }
    }
}