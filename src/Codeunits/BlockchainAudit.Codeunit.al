codeunit 50107 "Blockchain Audit"
{
    /// <summary>
    /// Create blockchain hash for approval action
    /// </summary>
    procedure CreateBlockchainHash(RequestNo: Integer; Action: Text; ActionBy: Code[50]; ActionData: Text)
    {
        var
            Blockchain: Record "Blockchain Hash";
            LastBlock: Record "Blockchain Hash";
            HashInput: Text;
            NewHash: Text;
            NewBlockNumber: Integer;
        begin
            // Get last block number
            LastBlock.SetRange("Request No.", RequestNo);
            LastBlock.SetRange("Chain Valid", true);
            if LastBlock.FindLast() then
                NewBlockNumber := LastBlock."Block Number" + 1
            else
                NewBlockNumber := 1;
            
            // Create hash input
            HashInput := Format(RequestNo) + Action + ActionBy + ActionData + Format(CurrentDateTime());
            
            // Add previous hash if exists
            if LastBlock.FindLast() then
                HashInput := HashInput + LastBlock."Action Hash";
            
            // Generate SHA-256 hash (simplified)
            NewHash := GenerateSimpleHash(HashInput);
            
            // Create blockchain record
            Blockchain.Init();
            Blockchain."Request No." := RequestNo;
            Blockchain."Action Hash" := NewHash;
            Blockchain."Previous Hash" := LastBlock."Action Hash";
            Blockchain."Block Number" := NewBlockNumber;
            Blockchain.Timestamp := CurrentDateTime();
            Blockchain.Verified := true;
            Blockchain."Chain Valid" := true;
            Blockchain.Insert();
            
            // Update Merkle root if needed
            if NewBlockNumber = 1 then
                UpdateMerkleRoot(RequestNo);
        end;
    end;
    
    /// <summary>
    /// Verify blockchain integrity for a request
    /// </summary>
    procedure VerifyChain(RequestNo: Integer): Boolean
    {
        var
            Blockchain: Record "Blockchain Hash";
            PreviousHash: Text;
            CurrentHash: Text;
            HashInput: Text;
            Valid: Boolean;
        begin
            Valid := true;
            PreviousHash := '';
            
            Blockchain.SetRange("Request No.", RequestNo);
            Blockchain.SetRange("Chain Valid", true);
            
            if Blockchain.FindSet() then
                repeat
                    // Verify hash integrity
                    HashInput := Format(Blockchain."Request No.") + 
                                 Blockchain."Action Type" + 
                                 Blockchain."Action By" + 
                                 Blockchain.Comments +
                                 Format(Blockchain.Timestamp);
                    
                    if PreviousHash <> '' then
                        HashInput := HashInput + PreviousHash;
                    
                    CurrentHash := GenerateSimpleHash(HashInput);
                    
                    if CurrentHash <> Blockchain."Action Hash" then
                    begin
                        Valid := false;
                        Blockchain.Verified := false;
                        Blockchain."Chain Valid" := false;
                        Blockchain.Modify();
                    end;
                    
                    PreviousHash := Blockchain."Action Hash";
                    
                until Blockchain.Next() = 0;
            
            exit(Valid);
        end;
    end;
    
    local procedure GenerateSimpleHash(Input: Text): Text
    {
        var
            Hash: Text;
            i: Integer;
        begin
            // Simplified hash for demonstration
            // In production, use System.Security.Cryptography
            Hash := '';
            for i := 1 to Length(Input) do
                Hash := Hash + Format(Int(Round(Random() * 255)), 'X2');
            
            exit(Hash);
        end;
    end;
    
    local procedure UpdateMerkleRoot(RequestNo: Integer)
    {
        var
            Blockchain: Record "Blockchain Hash";
            Hashes: Text;
            MerkleRoot: Text;
        begin
            // Collect all hashes
            Blockchain.SetRange("Request No.", RequestNo);
            if Blockchain.FindSet() then
                repeat
                    Hashes := Hashes + Blockchain."Action Hash";
                until Blockchain.Next() = 0;
            
            // Generate Merkle root
            MerkleRoot := GenerateSimpleHash(Hashes);
            
            // Update all records with same Merkle root
            Blockchain.SetRange("Request No.", RequestNo);
            if Blockchain.FindSet() then
                repeat
                    Blockchain."Merkle Root" := MerkleRoot;
                    Blockchain.Modify();
                until Blockchain.Next() = 0;
        end;
    end;
}