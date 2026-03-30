table 50105 "Service Level Agreement"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'SLA Code';
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
        
        field(5; "Approval Hours"; Integer)
        {
            Caption = 'Approval Hours';
            DataClassification = ToBeClassified;
            MinValue = 1;
            DefaultValue = 48;
        }
        
        field(6; "Escalation Hours"; Integer)
        {
            Caption = 'Escalation Hours';
            DataClassification = ToBeClassified;
            DefaultValue = 24;
        }
        
        field(7; "Penalty Amount"; Decimal)
        {
            Caption = 'Penalty Amount';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2:2;
        }
    }
    
    keys
    {
        key(PrimaryKey; Code)
        {
            Clustered = true;
        }
    }
}