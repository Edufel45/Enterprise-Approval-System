enum 50100 "Approval Status"
{
    Extensible = false;
    
    value(0; Draft)
    {
        Caption = 'Draft';
    }
    
    value(1; Submitted)
    {
        Caption = 'Submitted';
    }
    
    value(2; "In Review")
    {
        Caption = 'In Review';
    }
    
    value(3; Approved)
    {
        Caption = 'Approved';
    }
    
    value(4; Rejected)
    {
        Caption = 'Rejected';
    }
    
    value(5; Expired)
    {
        Caption = 'Expired';
    }
    
    value(6; Returned)
    {
        Caption = 'Returned';
    }
}