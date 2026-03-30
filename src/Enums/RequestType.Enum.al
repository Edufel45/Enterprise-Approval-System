enum 50101 "Request Type"
{
    Extensible = true;
    
    value(0; "Sales Order")
    {
        Caption = 'Sales Order';
    }
    
    value(1; "Purchase Order")
    {
        Caption = 'Purchase Order';
    }
    
    value(2; "Credit Limit")
    {
        Caption = 'Credit Limit Increase';
    }
    
    value(3; "Time Off")
    {
        Caption = 'Time Off Request';
    }
    
    value(4; "Expense Report")
    {
        Caption = 'Expense Report';
    }
}