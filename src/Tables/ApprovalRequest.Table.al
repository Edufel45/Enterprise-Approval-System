table 50100 "Approval Request"
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
        
        field(2; "Request Type"; Enum "Request Type")
        {
            Caption = 'Request Type';
            DataClassification = ToBeClassified;
        }
        
        field(3; "Request Date"; Date)
        {
            Caption = 'Request Date';
            DataClassification = ToBeClassified;
        }
        
        field(4; "Request Amount"; Decimal)
        {
            Caption = 'Request Amount';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2:2;
            MinValue = 0;
        }
        
        field(5; "Request Reason"; Text[500])
        {
            Caption = 'Request Reason';
            DataClassification = ToBeClassified;
        }
        
        field(6; "Department"; Enum Department)
        {
            Caption = 'Department';
            DataClassification = ToBeClassified;
        }
        
        field(10; "Requested By User ID"; Code[50])
        {
            Caption = 'Requested By';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(20; "Status"; Enum "Approval Status")
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        
        field(21; "Current Level"; Integer)
        {
            Caption = 'Current Approval Level';
            DataClassification = ToBeClassified;
            Editable = false;
            InitValue = 1;
        }
        
        field(22; "Total Levels"; Integer)
        {
            Caption = 'Total Approval Levels';
            DataClassification = ToBeClassified;
            Editable = false;
            InitValue = 0;
        }
        
        field(23; "Current Approver ID"; Code[50])
        {
            Caption = 'Current Approver';
            DataClassification = ToBeClassified;
            TableRelation = User;
            Editable = false;
        }
        
        field(30; "Approver 1 ID"; Code[50])
        {
            Caption = 'Approver Level 1';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(31; "Approver 2 ID"; Code[50])
        {
            Caption = 'Approver Level 2';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(32; "Approver 3 ID"; Code[50])
        {
            Caption = 'Approver Level 3';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(33; "Approver 4 ID"; Code[50])
        {
            Caption = 'Approver Level 4';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(34; "Approver 5 ID"; Code[50])
        {
            Caption = 'Approver Level 5';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
        
        field(40; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        
        field(41; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        
        field(42; "Submitted Date"; DateTime)
        {
            Caption = 'Submitted Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        
        field(43; "Approval Date"; DateTime)
        {
            Caption = 'Approval Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        
        field(44; "Completed Date"; DateTime)
        {
            Caption = 'Completed Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        
        field(45; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = ToBeClassified;
        }
        
        field(50; "Approver Comments"; Text[500])
        {
            Caption = 'Approver Comments';
            DataClassification = ToBeClassified;
        }
        
        field(51; "Rejection Reason"; Text[500])
        {
            Caption = 'Rejection Reason';
            DataClassification = ToBeClassified;
        }
    }
    
    keys
    {
        key(PrimaryKey; "Entry No.")
        {
            Clustered = true;
        }
        
        key(StatusKey; Status)
        {
        }
        
        key(RequestorKey; "Requested By User ID")
        {
        }
        
        key(ApproverKey; "Current Approver ID")
        {
        }
    }
    
    trigger OnInsert()
    begin
        "Created Date" := CurrentDateTime();
        "Created By" := UserId();
        "Status" := "Approval Status"::Draft;
        "Current Level" := 1;
    end;
        // Escalation Fields
        field(60; "Escalation Count"; Integer)
        {
            Caption = 'Escalation Count';
            DataClassification = ToBeClassified;
            Editable = false;
            InitValue = 0;
        }
        
        field(61; "Last Escalation Date"; DateTime)
        {
            Caption = 'Last Escalation Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        
        field(62; "Is Escalated"; Boolean)
        {
            Caption = 'Is Escalated';
            DataClassification = ToBeClassified;
            Editable = false;
            InitValue = false;
        }
        
        field(63; "Escalated To"; Code[50])
        {
            Caption = 'Escalated To';
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
}