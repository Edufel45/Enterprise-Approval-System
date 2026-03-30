table 50107 "Blockchain Hash"
{
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        
        field(2; "Request No."; Integer)
        {
            Caption = 'Request No.';
            TableRelation = "Approval Request";
        }
        
        field(3; "Action Hash"; Text[256])
        {
            Caption = 'SHA-256 Hash';
        }
        
        field(4; "Previous Hash"; Text[256])
        {
            Caption = 'Previous Hash';
        }
        
        field(5; "Merkle Root"; Text[256])
        {
            Caption = 'Merkle Root';
        }
        
        field(6; "Block Number"; Integer)
        {
            Caption = 'Block Number';
        }
        
        field(7; "Timestamp"; DateTime)
        {
            Caption = 'Timestamp';
        }
        
        field(8; "Verified"; Boolean)
        {
            Caption = 'Verified';
            DefaultValue = false;
        }
        
        field(9; "Verification Hash"; Text[256])
        {
            Caption = 'Verification Hash';
        }
        
        field(10; "Chain Valid"; Boolean)
        {
            Caption = 'Chain Valid';
            DefaultValue = true;
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
        
        key(BlockKey; "Block Number")
        {
        }
    }
}