codeunit 134161 "Pmt Export Mgt Gen. Jnl Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [Data Exchange] [Payment Export Management]
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPaymentExport: Codeunit "Library - Payment Export";
        LibraryHumanResource: Codeunit "Library - Human Resource";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        ActualContentLengthErr: Label 'Only 35 characters should be read from the file.';
        ActualContentValueErr: Label 'Unexpected file content.';
        PmtJnlLineExportFlagErr: Label 'Payment Journal Line is not marked as exported.';
        RecordNotFoundErr: Label '%1 was not found.', Comment = '%1=TableCaption';

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    [Scope('OnPrem')]
    procedure ExportAgainPmtJnlLineAutoApplied()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        InvGenJournalLine: Record "Gen. Journal Line";
        PmtGenJournalLine: Record "Gen. Journal Line";
        DataExchMapping: Record "Data Exch. Mapping";
        Vendor: Record Vendor;
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
        MessageToRecipient: Text;
    begin
        // [SCENARIO 1] Re-Export Payment Journal Line to a File
        // [GIVEN] Gen. Journal Line of type Payment
        // [GIVEN] Gen. Journal Line is auto-applied to a Posted Purchase Invoice
        // [GIVEN] The Exported to Payment File flag is set to true on the Gen. Journal Line
        // [WHEN] User clicks the Export Payment to File action on the Payment Journal
        // [THEN] Confirmation message pops up
        // [THEN] File is created

        // Pre-Setup
        LibraryPaymentExport.CreateVendorWithBankAccount(Vendor);
        PostPurchaseInvoice(InvGenJournalLine, Vendor."No.");

        DefinePaymentExportFormat(DataExchMapping);
        UpdatePaymentMethodLineDef(Vendor."Payment Method Code", DataExchMapping."Data Exch. Line Def Code");

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJournalBatch, DataExchMapping."Data Exch. Def Code");
        UpdateBankExportImportSetup(GenJournalBatch."Bal. Account No.");

        LibraryPaymentExport.CreateVendorPmtJnlLine(PmtGenJournalLine, GenJournalBatch, Vendor."No.");
        MessageToRecipient := LibraryUtility.GenerateRandomText(MaxStrLen(PmtGenJournalLine."Message to Recipient"));
        PmtGenJournalLine."Message to Recipient" := CopyStr(MessageToRecipient, 1, MaxStrLen(PmtGenJournalLine."Message to Recipient"));
        if PmtGenJournalLine."Account Type" = PmtGenJournalLine."Account Type"::"Bank Account" then
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        if PmtGenJournalLine."Bal. Account Type" = PmtGenJournalLine."Bal. Account Type"::"Bank Account" then
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        PmtGenJournalLine.Modify;

        ApplyPaymentToPurchaseInvoice(PmtGenJournalLine, InvGenJournalLine);

        // Exercise
        PmtGenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        PmtGenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);

        PmtExportMgtGenJnlLine.EnableExportToServerTempFile(true, 'txt');
        PmtExportMgtGenJnlLine.ExportJournalPaymentFileYN(PmtGenJournalLine); // Will set exported flag
        PmtExportMgtGenJnlLine.ExportJournalPaymentFileYN(PmtGenJournalLine); // Will ask for export again

        // Verify
        ValidatePaymentFile(PmtExportMgtGenJnlLine.GetServerTempFileName, MessageToRecipient);
        ValidateExportedPmtJnlLine(GenJournalBatch);
        ValidateCreditTransferRegister(DataExchMapping."Data Exch. Def Code", GenJournalBatch."Bal. Account No.");
    end;

    local procedure UpdatePaymentMethodLineDef(PaymentMethodCode: Code[10]; DataExchLineDefCode: Code[20])
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.Get(PaymentMethodCode);
        PaymentMethod.Validate("Pmt. Export Line Definition", DataExchLineDefCode);
        PaymentMethod.Modify(true);
    end;

    local procedure PostPurchaseInvoice(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Vendor, VendorNo, -LibraryRandom.RandDec(100, 2));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure DefinePaymentExportFormat(var DataExchMapping: Record "Data Exch. Mapping")
    var
        PaymentExportData: Record "Payment Export Data";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        LibraryPaymentExport.CreateSimpleDataExchDefWithMapping(DataExchMapping,
          DATABASE::"Payment Export Data", PaymentExportData.FieldNo("Message to Recipient 1"));

        DataExchDef.Get(DataExchMapping."Data Exch. Def Code");
        DataExchDef.Validate("File Type", DataExchDef."File Type"::"Variable Text");
        DataExchDef.Validate("Reading/Writing XMLport", XMLPORT::"Export Generic CSV");
        DataExchDef.Modify(true);

        DataExchLineDef.Get(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code");
        DataExchLineDef.Validate("Column Count", 1);
        DataExchLineDef.Modify(true);
    end;

    local procedure UpdateBankExportImportSetup(BankAccountNo: Code[20])
    var
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankAccount.Get(BankAccountNo);
        BankAccount.GetBankExportImportSetup(BankExportImportSetup);
        BankExportImportSetup."Processing Codeunit ID" := CODEUNIT::"Pmt Export Mgt Gen. Jnl Line";
        BankExportImportSetup.Modify;
    end;

    local procedure ApplyPaymentToPurchaseInvoice(var PmtGenJournalLine: Record "Gen. Journal Line"; InvGenJournalLine: Record "Gen. Journal Line")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, InvGenJournalLine."Document No.");
        PmtGenJournalLine.Validate("Applies-to Doc. Type", PmtGenJournalLine."Applies-to Doc. Type"::Invoice);
        PmtGenJournalLine.Validate("Applies-to Doc. No.", VendorLedgerEntry."Document No.");
        PmtGenJournalLine.Validate(Amount, -InvGenJournalLine.Amount);
        PmtGenJournalLine.Modify(true);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure ValidatePaymentFile(FileName: Text; MessageToRecipient: Text)
    var
        ActualMessageToRecipient: Text[37];
    begin
        ActualMessageToRecipient := CopyStr(ReadPaymentFile(FileName), 1, 37);
        Assert.AreEqual(35, StrLen(DelChr(ActualMessageToRecipient, '=', '"')), ActualContentLengthErr);
        Assert.AreNotEqual(0, StrPos(MessageToRecipient, DelChr(ActualMessageToRecipient, '=', '"')), ActualContentValueErr);
    end;

    local procedure ReadPaymentFile(FileName: Text) Content: Text
    var
        PaymentFile: File;
    begin
        PaymentFile.WriteMode := false;
        PaymentFile.TextMode := true;
        PaymentFile.Open(FileName);
        PaymentFile.Read(Content);
        PaymentFile.Close;
    end;

    local procedure ValidateExportedPmtJnlLine(GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst;
        Assert.IsTrue(GenJournalLine."Exported to Payment File", PmtJnlLineExportFlagErr);
    end;

    local procedure ValidateCreditTransferRegister(Identifier: Code[20]; FromBankAccountNo: Code[20])
    var
        CreditTransferRegister: Record "Credit Transfer Register";
    begin
        CreditTransferRegister.SetRange(Identifier, Identifier);
        CreditTransferRegister.SetRange(Status, CreditTransferRegister.Status::"File Created");
        CreditTransferRegister.SetRange("From Bank Account No.", FromBankAccountNo);
        Assert.IsFalse(CreditTransferRegister.IsEmpty, StrSubstNo(RecordNotFoundErr, CreditTransferRegister.TableCaption));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ExportPmtJnlLineManuallyApplied()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        InvGenJournalLine: Record "Gen. Journal Line";
        PmtGenJournalLine: Record "Gen. Journal Line";
        DataExchMapping: Record "Data Exch. Mapping";
        Vendor: Record Vendor;
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
        MessageToRecipient: Text;
    begin
        // [SCENARIO 2] Export Payment Journal Line to a File
        // [GIVEN] Gen. Journal Line of type Payment
        // [GIVEN] Gen. Journal Line is manually-applied to a Posted Purchase Invoice
        // [WHEN] User clicks the Export Payment to File action on the Payment Journal
        // [THEN] File is created

        // Pre-Setup
        LibraryPaymentExport.CreateVendorWithBankAccount(Vendor);
        PostPurchaseInvoice(InvGenJournalLine, Vendor."No.");

        DefinePaymentExportFormat(DataExchMapping);
        UpdatePaymentMethodLineDef(Vendor."Payment Method Code", DataExchMapping."Data Exch. Line Def Code");

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJournalBatch, DataExchMapping."Data Exch. Def Code");
        UpdateBankExportImportSetup(GenJournalBatch."Bal. Account No.");

        LibraryPaymentExport.CreateVendorPmtJnlLine(PmtGenJournalLine, GenJournalBatch, Vendor."No.");
        MessageToRecipient := LibraryUtility.GenerateRandomText(MaxStrLen(PmtGenJournalLine."Message to Recipient"));
        PmtGenJournalLine."Message to Recipient" := CopyStr(MessageToRecipient, 1, MaxStrLen(PmtGenJournalLine."Message to Recipient"));
        if PmtGenJournalLine."Account Type" = PmtGenJournalLine."Account Type"::"Bank Account" then
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        if PmtGenJournalLine."Bal. Account Type" = PmtGenJournalLine."Bal. Account Type"::"Bank Account" then
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        PmtGenJournalLine.Modify;

        ApplyPaymentToPurchaseInvoiceManually(PmtGenJournalLine, InvGenJournalLine);

        // Exercise
        PmtExportMgtGenJnlLine.EnableExportToServerTempFile(true, 'txt');
        PmtExportMgtGenJnlLine.ExportJournalPaymentFileYN(PmtGenJournalLine);

        // Verify
        ValidatePaymentFile(PmtExportMgtGenJnlLine.GetServerTempFileName, MessageToRecipient);
        ValidateExportedPmtJnlLine(GenJournalBatch);
        ValidateCreditTransferRegister(DataExchMapping."Data Exch. Def Code", GenJournalBatch."Bal. Account No.");
    end;

    local procedure ApplyPaymentToPurchaseInvoiceManually(var PmtGenJournalLine: Record "Gen. Journal Line"; InvGenJournalLine: Record "Gen. Journal Line")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, InvGenJournalLine."Document No.");
        VendorLedgerEntry.Validate("Applies-to ID", UserId);
        CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendorLedgerEntry);

        PmtGenJournalLine.Validate("Applies-to Doc. Type", PmtGenJournalLine."Applies-to Doc. Type"::Invoice);
        PmtGenJournalLine.Validate("Applies-to ID", UserId);
        PmtGenJournalLine.Validate(Amount, -InvGenJournalLine.Amount);
        PmtGenJournalLine.Modify(true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ExportPmtJnlLineNotApplied()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        InvGenJournalLine: Record "Gen. Journal Line";
        PmtGenJournalLine: Record "Gen. Journal Line";
        DataExchMapping: Record "Data Exch. Mapping";
        Vendor: Record Vendor;
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
        MessageToRecipient: Text;
    begin
        // [SCENARIO 3] Export Payment Journal Line to a File
        // [GIVEN] Gen. Journal Line of type Payment
        // [GIVEN] The Gen. Journal Line is not applied to any Posted Purchase Invoices
        // [WHEN] User clicks the Export Payment to File action on the Payment Journal
        // [THEN] File is created

        // Pre-Setup
        LibraryPaymentExport.CreateVendorWithBankAccount(Vendor);
        PostPurchaseInvoice(InvGenJournalLine, Vendor."No.");

        DefinePaymentExportFormat(DataExchMapping);
        UpdatePaymentMethodLineDef(Vendor."Payment Method Code", DataExchMapping."Data Exch. Line Def Code");

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJournalBatch, DataExchMapping."Data Exch. Def Code");
        UpdateBankExportImportSetup(GenJournalBatch."Bal. Account No.");

        LibraryPaymentExport.CreateVendorPmtJnlLine(PmtGenJournalLine, GenJournalBatch, Vendor."No.");
        MessageToRecipient := LibraryUtility.GenerateRandomText(MaxStrLen(PmtGenJournalLine."Message to Recipient"));
        PmtGenJournalLine."Message to Recipient" := CopyStr(MessageToRecipient, 1, MaxStrLen(PmtGenJournalLine."Message to Recipient"));
        if PmtGenJournalLine."Account Type" = PmtGenJournalLine."Account Type"::"Bank Account" then
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        if PmtGenJournalLine."Bal. Account Type" = PmtGenJournalLine."Bal. Account Type"::"Bank Account" then
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        PmtGenJournalLine.Modify;

        // Exercise
        PmtExportMgtGenJnlLine.EnableExportToServerTempFile(true, 'txt');
        PmtExportMgtGenJnlLine.ExportJournalPaymentFileYN(PmtGenJournalLine);

        // Verify
        ValidatePaymentFile(PmtExportMgtGenJnlLine.GetServerTempFileName, MessageToRecipient);
        ValidateExportedPmtJnlLine(GenJournalBatch);
        ValidateCreditTransferRegister(DataExchMapping."Data Exch. Def Code", GenJournalBatch."Bal. Account No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ExportPaymentJournalWithEmployee()
    var
        Employee: Record Employee;
        DataExchMapping: Record "Data Exch. Mapping";
        PaymentMethod: Record "Payment Method";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        // [FEATURE] [Employee]
        // [SCENARIO 330729] Export payment journal for employee using codeunit 1206 "Pmt Export Mgt Gen. Jnl Line" for processing.

        // [GIVEN] Employee "E".
        LibraryHumanResource.CreateEmployeeWithBankAccount(Employee);

        // [GIVEN] Set up Data Exchange Definition for exporting "Amount" field.
        DefinePaymentExportFormatForAmount(DataExchMapping);

        // [GIVEN] Set up payment method.
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.Validate("Pmt. Export Line Definition", DataExchMapping."Data Exch. Line Def Code");
        PaymentMethod.Modify(true);

        // [GIVEN] Create bank account.
        // [GIVEN] Create payment journal batch for the bank account, allow payment export.
        // [GIVEN] Set up Bank Export/Import Setup for using processing codeunit 1206.
        LibraryPaymentExport.CreatePaymentExportBatch(GenJournalBatch, DataExchMapping."Data Exch. Def Code");
        UpdateBankExportImportSetup(GenJournalBatch."Bal. Account No.");

        // [GIVEN] Create payment journal line for employee "E" and Amount = "X" in the batch created.
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Employee, Employee."No.", LibraryRandom.RandDec(100, 2));
        GenJournalLine.Validate("Payment Method Code", PaymentMethod.Code);
        GenJournalLine.Validate("Bank Payment Type", GenJournalLine."Bank Payment Type"::"Electronic Payment");
        GenJournalLine.Modify(true);

        // [WHEN] Export the payment journal line.
        PmtExportMgtGenJnlLine.EnableExportToServerTempFile(true, 'txt');
        PmtExportMgtGenJnlLine.ExportJournalPaymentFileYN(GenJournalLine);

        // [THEN] Read amount in the export file, ensure it is equal to "X".
        Assert.AreEqual(GenJournalLine.Amount, GetAmountFromFile(PmtExportMgtGenJnlLine.GetServerTempFileName), 'Amount');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PreparedPaymentDataFromPmtJournalWithEmployee()
    var
        Employee: Record Employee;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        TempPaymentExportData: Record "Payment Export Data" temporary;
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        // [FEATURE] [Employee] [UT]
        // [SCENARIO 330729] PreparePaymentExportDataJnl function in Codeunit 1206 "Pmt Export Mgt Gen. Jnl Line" populates Payment Export Data from a payment journal line with an employee.

        // [GIVEN] Employee "E".
        with Employee do begin
            LibraryHumanResource.CreateEmployeeWithBankAccount(Employee);
            Address := LibraryUtility.GenerateGUID;
            City := LibraryUtility.GenerateGUID;
            County := LibraryUtility.GenerateGUID;
            "Post Code" := LibraryUtility.GenerateGUID;
            "Country/Region Code" := LibraryUtility.GenerateGUID;
            "E-Mail" := LibraryUtility.GenerateGUID;
            Modify;
        end;

        // [GIVEN] Payment journal line for employee "E".
        LibraryPaymentExport.CreatePaymentExportBatch(GenJournalBatch, '');
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Employee, Employee."No.", LibraryRandom.RandDec(100, 2));

        // [WHEN] Invoke "PreparePaymentExportDataJnl" function in Codeunit 1206.
        PmtExportMgtGenJnlLine.PreparePaymentExportDataJnl(TempPaymentExportData, GenJournalLine, 0, 0);

        // [THEN] Recipient information on Payment Export Data record is filled in with employee "E" data.
        with TempPaymentExportData do begin
            TestField("Recipient Name", Employee.FullName);
            TestField("Recipient Address", Employee.Address);
            TestField("Recipient City", Employee.City);
            TestField("Recipient County", Employee.County);
            TestField("Recipient Post Code", Employee."Post Code");
            TestField("Recipient Country/Region Code", Employee."Country/Region Code");
            TestField("Recipient Email Address", Employee."E-Mail");
            TestField("Recipient Bank Acc. No.", Employee.GetBankAccountNo);
            TestField("Recipient Reg. No.", Employee."Bank Branch No.");
            TestField("Recipient Acc. No.", Employee."Bank Account No.");
        end;
    end;

    local procedure GetAmountFromFile(FilePath: Text) Amount: Decimal
    var
        String: Text;
    begin
        String := ReadPaymentFile(FilePath);
        String := CopyStr(String, 2, StrLen(String) - 2);
        Evaluate(Amount, String);
    end;

    local procedure DefinePaymentExportFormatForAmount(var DataExchMapping: Record "Data Exch. Mapping")
    var
        PaymentExportData: Record "Payment Export Data";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        LibraryPaymentExport.CreateSimpleDataExchDefWithMapping(DataExchMapping,
          DATABASE::"Payment Export Data", PaymentExportData.FieldNo(Amount));

        DataExchDef.Get(DataExchMapping."Data Exch. Def Code");
        DataExchDef.Validate("File Type", DataExchDef."File Type"::"Variable Text");
        DataExchDef.Validate("Reading/Writing XMLport", XMLPORT::"Export Generic CSV");
        DataExchDef.Modify(true);

        DataExchLineDef.Get(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code");
        DataExchLineDef.Validate("Column Count", 1);
        DataExchLineDef.Modify(true);
    end;
}

