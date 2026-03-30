table 50103 "Email Template"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = ToBeClassified;
        }
        
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        
        field(3; "Subject"; Text[200])
        {
            Caption = 'Subject';
            DataClassification = ToBeClassified;
        }
        
        field(4; "Body"; Text[4000])
        {
            Caption = 'Email Body';
            DataClassification = ToBeClassified;
        }
        
        field(5; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = table 50103 "Email Template"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = ToBeClassified;
        }
        
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        
        field(3; "Subject"; Text[200])
        {
            Caption = 'Subject';
            DataClassification = ToBeClassified;
        }
        
        field(4; "Body"; Text[4000])
        {
            Caption = 'Email Body';
            DataClassification = ToBeClassified;
        }
        
        field(5; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = ToBeClassified;
            DefaultValue = true;
        }
    }
    
    keys
    {
        key(PrimaryKey; Code)
        {
            Clustered = true;
        }
    }
}ToBeClassified;
            DefaultValue = true;
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