codeunit 20 "Posting Preview Event Handler"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TempGLEntry: Record "G/L Entry" temporary;
        TempVATEntry: Record "VAT Entry" temporary;
        TempValueEntry: Record "Value Entry" temporary;
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        TempFALedgEntry: Record "FA Ledger Entry" temporary;
        TempCustLedgEntry: Record "Cust. Ledger Entry" temporary;
        TempDtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry" temporary;
        TempVendLedgEntry: Record "Vendor Ledger Entry" temporary;
        TempDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry" temporary;
        TempEmplLedgEntry: Record "Employee Ledger Entry" temporary;
        TempDtldEmplLedgEntry: Record "Detailed Employee Ledger Entry" temporary;
        TempBankAccLedgerEntry: Record "Bank Account Ledger Entry" temporary;
        TempResLedgerEntry: Record "Res. Ledger Entry" temporary;
        TempServiceLedgerEntry: Record "Service Ledger Entry" temporary;
        TempWarrantyLedgerEntry: Record "Warranty Ledger Entry" temporary;
        TempMaintenanceLedgerEntry: Record "Maintenance Ledger Entry" temporary;
        TempJobLedgerEntry: Record "Job Ledger Entry" temporary;
        CommitPrevented: Boolean;
        ShowDocNo: Boolean;
        TransactionConsistent: Boolean;

    procedure GetEntries(TableNo: Integer; var RecRef: RecordRef)
    begin
        case TableNo of
            DATABASE::"G/L Entry":
                RecRef.GETTABLE(TempGLEntry);
            DATABASE::"Cust. Ledger Entry":
                RecRef.GETTABLE(TempCustLedgEntry);
            DATABASE::"Detailed Cust. Ledg. Entry":
                RecRef.GETTABLE(TempDtldCustLedgEntry);
            DATABASE::"Vendor Ledger Entry":
                RecRef.GETTABLE(TempVendLedgEntry);
            DATABASE::"Detailed Vendor Ledg. Entry":
                RecRef.GETTABLE(TempDtldVendLedgEntry);
            DATABASE::"Employee Ledger Entry":
                RecRef.GETTABLE(TempEmplLedgEntry);
            DATABASE::"Detailed Employee Ledger Entry":
                RecRef.GETTABLE(TempDtldEmplLedgEntry);
            DATABASE::"VAT Entry":
                RecRef.GETTABLE(TempVATEntry);
            DATABASE::"Value Entry":
                RecRef.GETTABLE(TempValueEntry);
            DATABASE::"Item Ledger Entry":
                RecRef.GETTABLE(TempItemLedgerEntry);
            DATABASE::"FA Ledger Entry":
                RecRef.GETTABLE(TempFALedgEntry);
            DATABASE::"Bank Account Ledger Entry":
                RecRef.GETTABLE(TempBankAccLedgerEntry);
            DATABASE::"Res. Ledger Entry":
                RecRef.GETTABLE(TempResLedgerEntry);
            DATABASE::"Service Ledger Entry":
                RecRef.GETTABLE(TempServiceLedgerEntry);
            DATABASE::"Warranty Ledger Entry":
                RecRef.GETTABLE(TempWarrantyLedgerEntry);
            DATABASE::"Maintenance Ledger Entry":
                RecRef.GETTABLE(TempMaintenanceLedgerEntry);
            DATABASE::"Job Ledger Entry":
                RecRef.GETTABLE(TempJobLedgerEntry);
            ELSE
                OnGetEntries(TableNo, RecRef);
        end
    end;

    procedure IsTransactionConsistent(): Boolean
    begin
        exit(TransactionConsistent);
    end;

    procedure ShowEntries(TableNo: Integer)
    var
        CustLedgEntriesPreview: Page "Cust. Ledg. Entries Preview";
        VendLedgEntriesPreview: Page "Vend. Ledg. Entries Preview";
        ItemLedgerEntriesPreview: Page "Item Ledger Entries Preview";
        EmplLedgerEntriesPreview: Page "Empl. Ledger Entries Preview";
    begin
        case TableNo of
            DATABASE::"G/L Entry":
                PAGE.Run(PAGE::"G/L Entries Preview", TempGLEntry);
            DATABASE::"Cust. Ledger Entry":
                begin
                    CustLedgEntriesPreview.Set(TempCustLedgEntry, TempDtldCustLedgEntry);
                    CustLedgEntriesPreview.Run();
                    Clear(CustLedgEntriesPreview);
                end;
            DATABASE::"Detailed Cust. Ledg. Entry":
                PAGE.Run(PAGE::"Det. Cust. Ledg. Entr. Preview", TempDtldCustLedgEntry);
            DATABASE::"Vendor Ledger Entry":
                begin
                    VendLedgEntriesPreview.Set(TempVendLedgEntry, TempDtldVendLedgEntry);
                    VendLedgEntriesPreview.Run();
                    Clear(VendLedgEntriesPreview);
                end;
            DATABASE::"Detailed Vendor Ledg. Entry":
                PAGE.Run(PAGE::"Detailed Vend. Entries Preview", TempDtldVendLedgEntry);
            DATABASE::"Employee Ledger Entry":
                begin
                    EmplLedgerEntriesPreview.Set(TempEmplLedgEntry, TempDtldEmplLedgEntry);
                    EmplLedgerEntriesPreview.Run();
                    Clear(EmplLedgerEntriesPreview);
                end;
            DATABASE::"Detailed Employee Ledger Entry":
                PAGE.Run(PAGE::"Detailed Empl. Entries Preview", TempDtldEmplLedgEntry);
            DATABASE::"VAT Entry":
                PAGE.Run(PAGE::"VAT Entries Preview", TempVATEntry);
            DATABASE::"Value Entry":
                PAGE.Run(PAGE::"Value Entries Preview", TempValueEntry);
            DATABASE::"Item Ledger Entry":
                begin
                    ItemLedgerEntriesPreview.Set(TempItemLedgerEntry, TempValueEntry);
                    ItemLedgerEntriesPreview.Run();
                    Clear(ItemLedgerEntriesPreview);
                end;
            DATABASE::"FA Ledger Entry":
                PAGE.Run(PAGE::"FA Ledger Entries Preview", TempFALedgEntry);
            DATABASE::"Bank Account Ledger Entry":
                PAGE.Run(PAGE::"Bank Acc. Ledg. Entr. Preview", TempBankAccLedgerEntry);
            DATABASE::"Res. Ledger Entry":
                PAGE.Run(PAGE::"Resource Ledg. Entries Preview", TempResLedgerEntry);
            DATABASE::"Service Ledger Entry":
                PAGE.Run(PAGE::"Service Ledger Entries Preview", TempServiceLedgerEntry);
            DATABASE::"Warranty Ledger Entry":
                PAGE.Run(PAGE::"Warranty Ledg. Entries Preview", TempWarrantyLedgerEntry);
            DATABASE::"Maintenance Ledger Entry":
                PAGE.Run(PAGE::"Maint. Ledg. Entries Preview", TempMaintenanceLedgerEntry);
            DATABASE::"Job Ledger Entry":
                PAGE.Run(PAGE::"Job Ledger Entries Preview", TempJobLedgerEntry);
            else
                OnAfterShowEntries(TableNo);
        end;
    end;

    procedure FillDocumentEntry(var TempDocumentEntry: Record "Document Entry" temporary)
    begin
        TempDocumentEntry.DeleteAll();
        InsertDocumentEntry(TempGLEntry, TempDocumentEntry);
        InsertDocumentEntry(TempVATEntry, TempDocumentEntry);
        InsertDocumentEntry(TempValueEntry, TempDocumentEntry);
        InsertDocumentEntry(TempItemLedgerEntry, TempDocumentEntry);
        InsertDocumentEntry(TempCustLedgEntry, TempDocumentEntry);
        InsertDocumentEntry(TempDtldCustLedgEntry, TempDocumentEntry);
        InsertDocumentEntry(TempVendLedgEntry, TempDocumentEntry);
        InsertDocumentEntry(TempDtldVendLedgEntry, TempDocumentEntry);
        InsertDocumentEntry(TempEmplLedgEntry, TempDocumentEntry);
        InsertDocumentEntry(TempDtldEmplLedgEntry, TempDocumentEntry);
        InsertDocumentEntry(TempFALedgEntry, TempDocumentEntry);
        InsertDocumentEntry(TempBankAccLedgerEntry, TempDocumentEntry);
        InsertDocumentEntry(TempResLedgerEntry, TempDocumentEntry);
        InsertDocumentEntry(TempServiceLedgerEntry, TempDocumentEntry);
        InsertDocumentEntry(TempWarrantyLedgerEntry, TempDocumentEntry);
        InsertDocumentEntry(TempMaintenanceLedgerEntry, TempDocumentEntry);
        InsertDocumentEntry(TempJobLedgerEntry, TempDocumentEntry);

        OnAfterFillDocumentEntry(TempDocumentEntry);
    end;

    procedure InsertDocumentEntry(RecVar: Variant; var TempDocumentEntry: Record "Document Entry" temporary)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecVar);

        if RecRef.IsEmpty() then
            exit;

        TempDocumentEntry.Init();
        TempDocumentEntry."Entry No." := RecRef.Number;
        TempDocumentEntry."Table ID" := RecRef.Number;
        TempDocumentEntry."Table Name" := RecRef.Caption;
        TempDocumentEntry."No. of Records" := RecRef.Count();
        TempDocumentEntry.Insert();
    end;

    procedure PreventCommit()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if CommitPrevented then
            exit;

        // Mark any table as inconsistent as long as it is not made consistent later in the transaction
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader.Consistent(false);
        CommitPrevented := true;
    end;

    procedure SetShowDocumentNo(NewShowDocNo: Boolean)
    begin
        ShowDocNo := NewShowDocNo;
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertGLEntry(var Rec: Record "G/L Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempGLEntry := Rec;
        if not ShowDocNo then
            TempGLEntry."Document No." := '***';
        TempGLEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyGLEntry(var Rec: Record "G/L Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        TempGLEntry := Rec;
        if not ShowDocNo then
            TempGLEntry."Document No." := '***';

        OnBeforeModifyTempGLEntry(Rec, TempGLEntry);

        if TempGLEntry.Modify() then
            PreventCommit();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertVATEntry(var Rec: Record "VAT Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempVATEntry := Rec;
        if not ShowDocNo then
            TempVATEntry."Document No." := '***';
        TempVATEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Value Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertValueEntry(var Rec: Record "Value Entry")
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempValueEntry := Rec;
        if not ShowDocNo then
            TempValueEntry."Document No." := '***';
        TempValueEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertItemLedgerEntry(var Rec: Record "Item Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempItemLedgerEntry := Rec;
        if not ShowDocNo then
            TempItemLedgerEntry."Document No." := '***';
        TempItemLedgerEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertFALedgEntry(var Rec: Record "FA Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempFALedgEntry := Rec;
        if not ShowDocNo then
            TempFALedgEntry."Document No." := '***';
        TempFALedgEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertCustLedgerEntry(var Rec: Record "Cust. Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempCustLedgEntry := Rec;
        if not ShowDocNo then
            TempCustLedgEntry."Document No." := '***';
        TempCustLedgEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyCustLedgerEntry(var Rec: Record "Cust. Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        TempCustLedgEntry := Rec;
        TempCustLedgEntry."Document No." := '***';

        OnBeforeModifyTempCustLedgEntry(Rec, TempCustLedgEntry);

        if TempCustLedgEntry.Modify() then
            PreventCommit();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed Cust. Ledg. Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertDetailedCustLedgEntry(var Rec: Record "Detailed Cust. Ledg. Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempDtldCustLedgEntry := Rec;
        if not ShowDocNo then
            TempDtldCustLedgEntry."Document No." := '***';
        TempDtldCustLedgEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed Cust. Ledg. Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyDetailedCustLedgerEntry(var Rec: Record "Detailed Cust. Ledg. Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        TempDtldCustLedgEntry := Rec;
        if not ShowDocNo then
            TempDtldCustLedgEntry."Document No." := '***';

        OnBeforeModifyTempDtldCustLedgEntry(Rec, TempDtldCustLedgEntry);

        if TempDtldCustLedgEntry.Modify() then
            PreventCommit();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertVendorLedgerEntry(var Rec: Record "Vendor Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempVendLedgEntry := Rec;
        if not ShowDocNo then
            TempVendLedgEntry."Document No." := '***';
        TempVendLedgEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyVendorLedgerEntry(var Rec: Record "Vendor Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        TempVendLedgEntry := Rec;
        if not ShowDocNo then
            TempVendLedgEntry."Document No." := '***';

        OnBeforeModifyTempVendLedgEntry(Rec, TempVendLedgEntry);

        if TempVendLedgEntry.Modify() then
            PreventCommit();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed Vendor Ledg. Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertDetailedVendorLedgEntry(var Rec: Record "Detailed Vendor Ledg. Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempDtldVendLedgEntry := Rec;
        if not ShowDocNo then
            TempDtldVendLedgEntry."Document No." := '***';
        TempDtldVendLedgEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed Vendor Ledg. Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyDetailedVendorLedgerEntry(var Rec: Record "Detailed Vendor Ledg. Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        TempDtldVendLedgEntry := Rec;
        if not ShowDocNo then
            TempDtldVendLedgEntry."Document No." := '***';

        OnBeforeModifyTempDtldVendLedgEntry(Rec, TempDtldVendLedgEntry);

        if TempDtldVendLedgEntry.Modify() then
            PreventCommit();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Employee Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertEmployeeLedgerEntry(var Rec: Record "Employee Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempEmplLedgEntry := Rec;
        if not ShowDocNo then
            TempEmplLedgEntry."Document No." := '***';
        TempEmplLedgEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed Employee Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertDetailedEmployeeLedgerEntry(var Rec: Record "Detailed Employee Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempDtldEmplLedgEntry := Rec;
        if not ShowDocNo then
            TempDtldEmplLedgEntry."Document No." := '***';
        TempDtldEmplLedgEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertBankAccountLedgerEntry(var Rec: Record "Bank Account Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempBankAccLedgerEntry := Rec;
        if not ShowDocNo then
            TempBankAccLedgerEntry."Document No." := '***';
        TempBankAccLedgerEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Res. Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertResourceLedgerEntry(var Rec: Record "Res. Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempResLedgerEntry := Rec;
        if not ShowDocNo then
            TempResLedgerEntry."Document No." := '***';
        TempResLedgerEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertServiceLedgerEntry(var Rec: Record "Service Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempServiceLedgerEntry := Rec;
        if not ShowDocNo then
            TempServiceLedgerEntry."Document No." := '***';
        TempServiceLedgerEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Ledger Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyServiceLedgerEntry(var Rec: Record "Service Ledger Entry"; var xRec: Record "Service Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempServiceLedgerEntry := Rec;
        if not ShowDocNo then
            TempServiceLedgerEntry."Document No." := '***';
        if TempServiceLedgerEntry.Insert() then;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Warranty Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertWarrantyLedgerEntry(var Rec: Record "Warranty Ledger Entry")
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempWarrantyLedgerEntry := Rec;
        if not ShowDocNo then
            TempWarrantyLedgerEntry."Document No." := '***';
        TempWarrantyLedgerEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Maintenance Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertMaintenanceLedgerEntry(var Rec: Record "Maintenance Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempMaintenanceLedgerEntry := Rec;
        if not ShowDocNo then
            TempMaintenanceLedgerEntry."Document No." := '***';
        TempMaintenanceLedgerEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertJobLedgEntry(var Rec: Record "Job Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        PreventCommit();
        TempJobLedgerEntry := Rec;
        if not ShowDocNo then
            TempJobLedgerEntry."Document No." := '***';
        TempJobLedgerEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterFinishPosting', '', false, false)]
    local procedure OnAfterGenJnlPostLineFinishPosting(var GlobalGLEntry: Record "G/L Entry"; var GLRegister: Record "G/L Register"; var IsTransactionConsistent: Boolean; var GenJournalLine: Record "Gen. Journal Line")
    begin
        TransactionConsistent := IsTransactionConsistent;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFillDocumentEntry(var DocumentEntry: Record "Document Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetEntries(TableNo: Integer; var RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowEntries(TableNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyTempGLEntry(var Rec: Record "G/L Entry"; var TempCustLedgerEntry: Record "G/L Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyTempCustLedgEntry(var Rec: Record "Cust. Ledger Entry"; var TempCustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyTempDtldCustLedgEntry(var Rec: Record "Detailed Cust. Ledg. Entry"; var TempCustLedgerEntry: Record "Detailed Cust. Ledg. Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyTempVendLedgEntry(var Rec: Record "Vendor Ledger Entry"; var TempVendLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyTempDtldVendLedgEntry(var Rec: Record "Detailed Vendor Ledg. Entry"; var TempVendLedgerEntry: Record "Detailed Vendor Ledg. Entry")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnSystemSetPostingPreviewActive', '', false, false)]
    local procedure SetTrueOnSystemSetPostingPreviewActive(var Result: Boolean)
    begin
        Result := true;
    end;
}

