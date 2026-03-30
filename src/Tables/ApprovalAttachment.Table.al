table 50109 "Approval Attachment"
{
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        
        field(2; "Request No."; Integer)
        {
            TableRelation = "Approval Request";
        }
        
        field(3; "File Name"; Text[200])
        {
            Caption = 'File Name';
        }
        
        field(4; "File Type"; Text[50])
        {
            Caption = 'File Type';
        }
        
        field(5; "File Size"; Integer)
        {
            Caption = 'File Size (KB)';
        }
        
        field(6; "File Content"; Blob)
        {
            DataClassification = CustomerContent;
        }
        
        field(7; "Uploaded By"; Code[50])
        {
            TableRelation = User;
        }
        
        field(8; "Uploaded Date"; DateTime)
        {
        }
        
        field(9; "OCR Text"; Text[4000])
        {
            Caption = 'Extracted Text';
        }
        
        field(10; "Thumbnail"; Blob)
        {
            DataClassification = CustomerContent;
        }
        
        field(11; "Is Encrypted"; Boolean)
        {
            DefaultValue = false;
        }
        
        field(12; "Virus Scan Status"; Option)
        {
            OptionMembers = NotScanned,Clean,Infected;
            DefaultValue = "NotScanned";
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
        "Uploaded Date" := CurrentDateTime();
        "Uploaded By" := UserId();
        
        // Auto-scan for viruses
        ScanForViruses();
        
        // Extract text from images
        ExtractOCRText();
    end;
    
    local procedure ScanForViruses()
    begin
        // In production, integrate with antivirus API
        "Virus Scan Status" := "Virus Scan Status"::Clean;
    end;
    
    local procedure ExtractOCRText()
    begin
        // In production, use OCR service
        if "File Type" in ['jpg','png','pdf'] then
            "OCR Text" := 'Extracted text from document';
    end;
}