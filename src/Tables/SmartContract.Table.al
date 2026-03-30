table 50108 "Smart Contract"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Contract Code"; Code[20])
        {
            Caption = 'Contract Code';
        }
        
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        
        field(3; "Trigger Condition"; Text[500])
        {
            Caption = 'IF this happens...';
        }
        
        field(4; "Action Type"; Option)
        {
            Caption = 'Action Type';
            OptionMembers = Email,API,CreateOrder,UpdateCredit,CreateInvoice,NotifyERP,CreateTask;
            OptionCaption = 'Email','API Call','Create Order','Update Credit','Create Invoice','Notify ERP','Create Task';
        }
        
        field(5; "Action Config"; Text[1000])
        {
            Caption = 'THEN do this...';
        }
        
        field(6; "Request Type"; Enum "Request Type")
        {
            Caption = 'Request Type';
        }
        
        field(7; "Department"; Enum Department)
        {
            Caption = 'Department';
        }
        
        field(8; "Min Amount"; Decimal)
        {
            Caption = 'Minimum Amount';
            DecimalPlaces = 2:2;
        }
        
        field(9; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            DefaultValue = true;
        }
        
        field(10; "Execution Count"; Integer)
        {
            Caption = 'Execution Count';
            Editable = false;
        }
        
        field(11; "Last Execution"; DateTime)
        {
            Caption = 'Last Execution';
            Editable = false;
        }
    }
    
    keys
    {
        key(PrimaryKey; "Contract Code")
        {
            Clustered = true;
        }
    }
}

codeunit 50109 "SmartContractEngine"
{
    procedure ExecuteContract(RequestNo: Integer)
    {
        var
            ApprovalRequest: Record "Approval Request";
            SmartContract: Record "Smart Contract";
        begin
            if not ApprovalRequest.Get(RequestNo) then
                exit;
            
            // Only execute on approved requests
            if ApprovalRequest.Status <> "Approval Status"::Approved then
                exit;
            
            // Find matching contracts
            SmartContract.SetRange("Is Active", true);
            SmartContract.SetRange("Request Type", ApprovalRequest."Request Type");
            
            if ApprovalRequest.Department <> '' then
                SmartContract.SetRange(Department, ApprovalRequest.Department);
            
            SmartContract.SetFilter("Min Amount", '<=%1', ApprovalRequest."Request Amount");
            
            if SmartContract.FindSet() then
                repeat
                    ExecuteAction(SmartContract, ApprovalRequest);
                    
                    // Update execution count
                    SmartContract."Execution Count" += 1;
                    SmartContract."Last Execution" := CurrentDateTime();
                    SmartContract.Modify();
                    
                until SmartContract.Next() = 0;
        end;
    end;
    
    local procedure ExecuteAction(Contract: Record "Smart Contract"; Request: Record "Approval Request")
    {
        case Contract."Action Type" of
            Contract."Action Type"::Email:
                ExecuteEmailAction(Contract, Request);
            Contract."Action Type"::API:
                ExecuteAPIAction(Contract, Request);
            Contract."Action Type"::"Create Order":
                ExecuteCreateOrder(Contract, Request);
            Contract."Action Type"::"Update Credit":
                ExecuteUpdateCredit(Contract, Request);
            Contract."Action Type"::"Create Invoice":
                ExecuteCreateInvoice(Contract, Request);
            Contract."Action Type"::"Notify ERP":
                ExecuteNotifyERP(Contract, Request);
            Contract."Action Type"::"Create Task":
                ExecuteCreateTask(Contract, Request);
        end;
    end;
    
    local procedure ExecuteEmailAction(Contract: Record "Smart Contract"; Request: Record "Approval Request")
    {
        var
            EmailNotif: Codeunit "Email Notification";
        begin
            EmailNotif.SendApprovalEmail(
                Request."Entry No.",
                Request."Requested By User ID",
                'CONTRACT_EXECUTED'
            );
        end;
    end;
    
    local procedure ExecuteAPIAction(Contract: Record "Smart Contract"; Request: Record "Approval Request")
    {
        var
            APIEndpoint: Text;
        begin
            // In production, call external API
            APIEndpoint := Contract."Action Config";
            Message('API call to %1 for request #%2', APIEndpoint, Request."Entry No.");
        end;
    end;
    
    local procedure ExecuteCreateOrder(Contract: Record "Smart Contract"; Request: Record "Approval Request")
    {
        Message('Creating sales order for request #%1', Request."Entry No.");
    end;
    
    local procedure ExecuteUpdateCredit(Contract: Record "Smart Contract"; Request: Record "Approval Request")
    {
        Message('Updating credit limit for request #%1', Request."Entry No.");
    end;
    
    local procedure ExecuteCreateInvoice(Contract: Record "Smart Contract"; Request: Record "Approval Request")
    {
        Message('Creating invoice for request #%1', Request."Entry No.");
    end;
    
    local procedure ExecuteNotifyERP(Contract: Record "Smart Contract"; Request: Record "Approval Request")
    {
        Message('Notifying ERP system for request #%1', Request."Entry No.");
    end;
    
    local procedure ExecuteCreateTask(Contract: Record "Smart Contract"; Request: Record "Approval Request")
    {
        Message('Creating task for request #%1', Request."Entry No.");
    end;
}