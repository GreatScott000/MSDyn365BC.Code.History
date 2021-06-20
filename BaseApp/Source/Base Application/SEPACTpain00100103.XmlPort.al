xmlport 1000 "SEPA CT pain.001.001.03"
{
    Caption = 'SEPA CT pain.001.001.03';
    DefaultNamespace = 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.03';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        tableelement("Gen. Journal Line"; "Gen. Journal Line")
        {
            XmlName = 'Document';
            UseTemporary = true;
            tableelement(companyinformation; "Company Information")
            {
                XmlName = 'CstmrCdtTrfInitn';
                textelement(GrpHdr)
                {
                    textelement(messageid)
                    {
                        XmlName = 'MsgId';
                    }
                    textelement(createddatetime)
                    {
                        XmlName = 'CreDtTm';
                    }
                    textelement(nooftransfers)
                    {
                        XmlName = 'NbOfTxs';
                    }
                    textelement(controlsum)
                    {
                        XmlName = 'CtrlSum';
                    }
                    textelement(InitgPty)
                    {
                        fieldelement(Nm; CompanyInformation.Name)
                        {
                        }
                        textelement(initgptypstladr)
                        {
                            XmlName = 'PstlAdr';
                            fieldelement(StrtNm; CompanyInformation.Address)
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation.Address = '' then
                                        currXMLport.Skip;
                                end;
                            }
                            fieldelement(PstCd; CompanyInformation."Post Code")
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation."Post Code" = '' then
                                        currXMLport.Skip;
                                end;
                            }
                            fieldelement(TwnNm; CompanyInformation.City)
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation.City = '' then
                                        currXMLport.Skip;
                                end;
                            }
                            fieldelement(Ctry; CompanyInformation."Country/Region Code")
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation."Country/Region Code" = '' then
                                        currXMLport.Skip;
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if SwissExport then
                                    currXMLport.Skip;
                            end;
                        }
                        textelement(initgptyid)
                        {
                            XmlName = 'Id';
                            textelement(initgptyorgid)
                            {
                                XmlName = 'OrgId';
                                textelement(initgptyothrinitgpty)
                                {
                                    XmlName = 'Othr';
                                    fieldelement(Id; CompanyInformation."VAT Registration No.")
                                    {
                                    }
                                }
                            }
                        }
                    }
                }
                tableelement(paymentexportdatagroup; "Payment Export Data")
                {
                    XmlName = 'PmtInf';
                    UseTemporary = true;
                    fieldelement(PmtInfId; PaymentExportDataGroup."Payment Information ID")
                    {
                    }
                    fieldelement(PmtMtd; PaymentExportDataGroup."SEPA Payment Method Text")
                    {
                    }
                    fieldelement(BtchBookg; PaymentExportDataGroup."SEPA Batch Booking")
                    {
                    }
                    fieldelement(NbOfTxs; PaymentExportDataGroup."Line No.")
                    {
                    }
                    fieldelement(CtrlSum; PaymentExportDataGroup.Amount)
                    {

                        trigger OnBeforePassField()
                        begin
                            if SwissExport then
                                currXMLport.Skip;
                        end;
                    }
                    textelement(PmtTpInf)
                    {
                        fieldelement(InstrPrty; PaymentExportDataGroup."SEPA Instruction Priority Text")
                        {
                        }
                        textelement(SvcLvl)
                        {
                            textelement(Cd)
                            {

                                trigger OnBeforePassVariable()
                                begin
                                    Cd := 'SEPA';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if not SwissExport then
                                    currXMLport.Skip;
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if not (PaymentExportDataGroup."Swiss Payment Type" = PaymentExportDataGroup."Swiss Payment Type"::"5") and SwissExport then
                                currXMLport.Skip;
                        end;
                    }
                    fieldelement(ReqdExctnDt; PaymentExportDataGroup."Transfer Date")
                    {
                    }
                    textelement(Dbtr)
                    {
                        fieldelement(Nm; CompanyInformation.Name)
                        {
                        }
                        textelement(dbtrpstladr)
                        {
                            XmlName = 'PstlAdr';
                            fieldelement(StrtNm; CompanyInformation.Address)
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation.Address = '' then
                                        currXMLport.Skip;
                                end;
                            }
                            fieldelement(PstCd; CompanyInformation."Post Code")
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation."Post Code" = '' then
                                        currXMLport.Skip;
                                end;
                            }
                            fieldelement(TwnNm; CompanyInformation.City)
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation.City = '' then
                                        currXMLport.Skip;
                                end;
                            }
                            fieldelement(Ctry; CompanyInformation."Country/Region Code")
                            {

                                trigger OnBeforePassField()
                                begin
                                    if CompanyInformation."Country/Region Code" = '' then
                                        currXMLport.Skip;
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if SwissExport then
                                    currXMLport.Skip;
                            end;
                        }
                        textelement(dbtrid)
                        {
                            XmlName = 'Id';
                            textelement(dbtrorgid)
                            {
                                XmlName = 'OrgId';
                                fieldelement(BICOrBEI; PaymentExportDataGroup."Sender Bank BIC")
                                {
                                }
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if SwissExport then
                                    currXMLport.Skip;

                                if PaymentExportDataGroup."Sender Bank BIC" = '' then
                                    currXMLport.Skip;
                            end;
                        }
                    }
                    textelement(DbtrAcct)
                    {
                        textelement(dbtracctid)
                        {
                            XmlName = 'Id';
                            fieldelement(IBAN; PaymentExportDataGroup."Sender Bank Account No.")
                            {
                                MaxOccurs = Once;
                                MinOccurs = Once;
                            }
                        }
                    }
                    textelement(DbtrAgt)
                    {
                        textelement(dbtragtfininstnid)
                        {
                            XmlName = 'FinInstnId';
                            fieldelement(BIC; PaymentExportDataGroup."Sender Bank BIC")
                            {
                                MaxOccurs = Once;
                                MinOccurs = Once;
                            }
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if PaymentExportDataGroup."Sender Bank BIC" = '' then
                                currXMLport.Skip;
                        end;
                    }
                    fieldelement(ChrgBr; PaymentExportDataGroup."SEPA Charge Bearer Text")
                    {
                    }
                    tableelement(paymentexportdata; "Payment Export Data")
                    {
                        LinkFields = "Sender Bank BIC" = FIELD("Sender Bank BIC"), "SEPA Instruction Priority Text" = FIELD("SEPA Instruction Priority Text"), "Transfer Date" = FIELD("Transfer Date"), "SEPA Batch Booking" = FIELD("SEPA Batch Booking"), "SEPA Charge Bearer Text" = FIELD("SEPA Charge Bearer Text");
                        LinkTable = PaymentExportDataGroup;
                        XmlName = 'CdtTrfTxInf';
                        UseTemporary = true;
                        textelement(PmtId)
                        {
                            fieldelement(InstrId; PaymentExportData."End-to-End ID")
                            {

                                trigger OnBeforePassField()
                                begin
                                    if not SwissExport then
                                        currXMLport.Skip;
                                end;
                            }
                            fieldelement(EndToEndId; PaymentExportData."End-to-End ID")
                            {
                            }
                        }
                        textelement(cdtrpmttpinf)
                        {
                            XmlName = 'PmtTpInf';
                            textelement(LclInstrm)
                            {
                                textelement(Prtry)
                                {

                                    trigger OnBeforePassVariable()
                                    begin
                                        case PaymentExportData."Swiss Payment Type" of
                                            PaymentExportData."Swiss Payment Type"::"1":
                                                Prtry := 'CH01';
                                            PaymentExportData."Swiss Payment Type"::"2.1":
                                                Prtry := 'CH02';
                                            PaymentExportData."Swiss Payment Type"::"2.2":
                                                Prtry := 'CH03';
                                        end;
                                    end;
                                }
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if not SwissExport or not (PaymentExportData."Swiss Payment Type" in [PaymentExportData."Swiss Payment Type"::"1",
                                                                                                      PaymentExportData."Swiss Payment Type"::"2.1",
                                                                                                      PaymentExportData."Swiss Payment Type"::"2.2"])
                                then
                                    currXMLport.Skip;
                            end;
                        }
                        textelement(Amt)
                        {
                            fieldelement(InstdAmt; PaymentExportData.Amount)
                            {
                                fieldattribute(Ccy; PaymentExportData."Currency Code")
                                {
                                }
                            }
                        }
                        textelement(CdtrAgt)
                        {
                            textelement(cdtragtfininstnid)
                            {
                                XmlName = 'FinInstnId';
                                fieldelement(BIC; PaymentExportData."Recipient Bank BIC")
                                {
                                    FieldValidate = yes;

                                    trigger OnBeforePassField()
                                    begin
                                        if SwissExport and
                                           (PaymentExportData."Swiss Payment Type" = PaymentExportData."Swiss Payment Type"::"2.2") or
                                           (PaymentExportData."Recipient Bank BIC" = '')
                                        then
                                            currXMLport.Skip;
                                    end;
                                }
                                textelement(ClrSysMmbId)
                                {
                                    textelement(ClrSysId)
                                    {
                                        textelement(clrsysid_cd)
                                        {
                                            XmlName = 'Cd';

                                            trigger OnBeforePassVariable()
                                            begin
                                                ClrSysId_Cd := 'CHBCC';
                                            end;
                                        }
                                    }
                                    fieldelement(MmbId; PaymentExportData."Recipient Bank BIC")
                                    {
                                    }

                                    trigger OnBeforePassVariable()
                                    begin
                                        if not SwissExport or (PaymentExportData."Swiss Payment Type" <> PaymentExportData."Swiss Payment Type"::"2.2") then
                                            currXMLport.Skip;
                                    end;
                                }
                                fieldelement(Nm; PaymentExportData."Recipient Bank Name")
                                {
                                    FieldValidate = yes;

                                    trigger OnBeforePassField()
                                    begin
                                        if SwissExport and
                                           (PaymentExportData."Swiss Payment Type" <> PaymentExportData."Swiss Payment Type"::"6") or
                                           (PaymentExportData."Recipient Bank Name" = '')
                                        then
                                            currXMLport.Skip;
                                    end;
                                }
                                textelement(PstlAdr)
                                {
                                    fieldelement(StrtNm; PaymentExportData."Recipient Bank Address")
                                    {

                                        trigger OnBeforePassField()
                                        begin
                                            if PaymentExportData."Recipient Bank Address" = '' then
                                                currXMLport.Skip;
                                        end;
                                    }
                                    fieldelement(PstCd; PaymentExportData."Recipient Bank Post Code")
                                    {

                                        trigger OnBeforePassField()
                                        begin
                                            if PaymentExportData."Recipient Bank Post Code" = '' then
                                                currXMLport.Skip;
                                        end;
                                    }
                                    fieldelement(TwnNm; PaymentExportData."Recipient Bank City")
                                    {

                                        trigger OnBeforePassField()
                                        begin
                                            if PaymentExportData."Recipient Bank City" = '' then
                                                currXMLport.Skip;
                                        end;
                                    }
                                    fieldelement(Ctry; PaymentExportData."Recipient Bank Country/Region")
                                    {

                                        trigger OnBeforePassField()
                                        begin
                                            if PaymentExportData."Recipient Bank Country/Region" = '' then
                                                currXMLport.Skip;
                                        end;
                                    }

                                    trigger OnBeforePassVariable()
                                    begin
                                        if SwissExport and
                                           (PaymentExportData."Swiss Payment Type" <> PaymentExportData."Swiss Payment Type"::"6") or
                                           ((PaymentExportData."Recipient Bank Address" = '') and (PaymentExportData."Recipient Bank Post Code" = '') and
                                            (PaymentExportData."Recipient Bank Name" = '') and (PaymentExportData."Recipient Bank Country/Region" = ''))
                                        then
                                            currXMLport.Skip;

                                        if SwissExport and
                                           (PaymentExportData."Swiss Payment Type" = PaymentExportData."Swiss Payment Type"::"6") and
                                           (PaymentExportData."Recipient Bank BIC" <> '') and (PaymentExportData."Recipient Bank Acc. No." <> '')
                                        then
                                            currXMLport.Skip;
                                    end;
                                }
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if (PaymentExportData."Recipient Bank BIC" = '') and
                                   (not SwissExport or (PaymentExportData."Recipient Bank Name" = ''))
                                then
                                    currXMLport.Skip;
                            end;
                        }
                        textelement(Cdtr)
                        {
                            fieldelement(Nm; PaymentExportData."Recipient Name")
                            {
                            }
                            textelement(cdtrpstladr)
                            {
                                XmlName = 'PstlAdr';
                                fieldelement(StrtNm; PaymentExportData."Recipient Address")
                                {

                                    trigger OnBeforePassField()
                                    begin
                                        if PaymentExportData."Recipient Address" = '' then
                                            currXMLport.Skip;
                                    end;
                                }
                                fieldelement(PstCd; PaymentExportData."Recipient Post Code")
                                {

                                    trigger OnBeforePassField()
                                    begin
                                        if PaymentExportData."Recipient Post Code" = '' then
                                            currXMLport.Skip;
                                    end;
                                }
                                fieldelement(TwnNm; PaymentExportData."Recipient City")
                                {

                                    trigger OnBeforePassField()
                                    begin
                                        if PaymentExportData."Recipient City" = '' then
                                            currXMLport.Skip;
                                    end;
                                }
                                fieldelement(Ctry; PaymentExportData."Recipient Country/Region Code")
                                {

                                    trigger OnBeforePassField()
                                    begin
                                        if PaymentExportData."Recipient Country/Region Code" = '' then
                                            currXMLport.Skip;
                                    end;
                                }

                                trigger OnBeforePassVariable()
                                begin
                                    if (PaymentExportData."Recipient Address" = '') and
                                       (PaymentExportData."Recipient Post Code" = '') and
                                       (PaymentExportData."Recipient City" = '') and
                                       (PaymentExportData."Recipient Country/Region Code" = '')
                                    then
                                        currXMLport.Skip;
                                end;
                            }
                        }
                        textelement(CdtrAcct)
                        {
                            textelement(cdtracctid)
                            {
                                XmlName = 'Id';
                                fieldelement(IBAN; PaymentExportData."Recipient Bank Acc. No.")
                                {
                                    FieldValidate = yes;
                                    MaxOccurs = Once;
                                    MinOccurs = Once;

                                    trigger OnBeforePassField()
                                    begin
                                        if PaymentExportData."Recipient Bank Acc. No." = '' then
                                            currXMLport.Skip;
                                    end;
                                }
                                textelement(Othr)
                                {
                                    fieldelement(Id; PaymentExportData."Recipient Acc. No.")
                                    {
                                    }

                                    trigger OnBeforePassVariable()
                                    begin
                                        if PaymentExportData."Recipient Acc. No." = '' then
                                            currXMLport.Skip;
                                    end;
                                }
                            }
                        }
                        textelement(RmtInf)
                        {
                            MinOccurs = Zero;
                            textelement(remittancetext1)
                            {
                                MinOccurs = Zero;
                                XmlName = 'Ustrd';

                                trigger OnBeforePassVariable()
                                begin
                                    if RemittanceText1 = '' then
                                        currXMLport.Skip;
                                end;
                            }
                            textelement(remittancetext2)
                            {
                                MinOccurs = Zero;
                                XmlName = 'Ustrd';

                                trigger OnBeforePassVariable()
                                begin
                                    if (not SwissExport) or (RemittanceText2 = '') or (rmtstrdref <> '') then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(Strd)
                            {
                                textelement(CdtrRefInf)
                                {
                                    textelement(rmtstrdref)
                                    {
                                        XmlName = 'Ref';
                                    }
                                }

                                textelement(AddtlRmtInf)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        if (not SwissExport) or (RemittanceText2 = '') or (rmtstrdref = '') then
                                            currXMLport.Skip();
                                        AddtlRmtInf := RemittanceText2;
                                    end;
                                }

                                trigger OnBeforePassVariable()
                                begin
                                    if RmtStrdRef = '' then
                                        currXMLport.Skip;
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                RemittanceText1 := '';
                                RemittanceText2 := '';
                                TempPaymentExportRemittanceText.SetRange("Pmt. Export Data Entry No.", PaymentExportData."Entry No.");
                                if not TempPaymentExportRemittanceText.FindSet then
                                    currXMLport.Skip;
                                RemittanceText1 := TempPaymentExportRemittanceText.Text;
                                if TempPaymentExportRemittanceText.Next <> 0 then
                                    RemittanceText2 := TempPaymentExportRemittanceText.Text;
                                if not SwissExport then
                                    RemittanceText1 := CopyStr(
                                        StrSubstNo('%1; %2', RemittanceText1, RemittanceText2), 1, 140);
                                UpdateRemittanceInfo(PaymentExportData);

                                if (RemittanceText1 = '') and (RemittanceText2 = '') and (RmtStrdRef = '') then
                                    currXMLport.Skip;
                            end;
                        }
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if not PaymentExportData.GetPreserveNonLatinCharacters then
                        PaymentExportData.CompanyInformationConvertToLatin(CompanyInformation);
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPreXmlPort()
    begin
        InitData;
    end;

    var
        TempPaymentExportRemittanceText: Record "Payment Export Remittance Text" temporary;
        NoDataToExportErr: Label 'There is no data to export.', Comment = '%1=Field;%2=Value;%3=Value';
        CHMgt: Codeunit CHMgt;
        SwissExport: Boolean;

    local procedure InitData()
    var
        GenJournalLine: Record "Gen. Journal Line";
        SEPACTFillExportBuffer: Codeunit "SEPA CT-Fill Export Buffer";
        PaymentGroupNo: Integer;
    begin
        GenJournalLine.Copy("Gen. Journal Line");
        if GenJournalLine.FindFirst then
            SwissExport := CHMgt.IsSwissSEPACTExport(GenJournalLine);
        SEPACTFillExportBuffer.FillExportBuffer("Gen. Journal Line", PaymentExportData);
        PaymentExportData.GetRemittanceTexts(TempPaymentExportRemittanceText);

        NoOfTransfers := Format(PaymentExportData.Count);
        MessageID := PaymentExportData."Message ID";
        CreatedDateTime := Format(CurrentDateTime, 19, 9);
        PaymentExportData.CalcSums(Amount);
        ControlSum := Format(PaymentExportData.Amount, 0, 9);

        PaymentExportData.SetCurrentKey(
          "Sender Bank BIC", "SEPA Instruction Priority Text", "Transfer Date",
          "SEPA Batch Booking", "SEPA Charge Bearer Text");

        if not PaymentExportData.FindSet then
            Error(NoDataToExportErr);

        InitPmtGroup;
        repeat
            if IsNewGroup then begin
                InsertPmtGroup(PaymentGroupNo);
                InitPmtGroup;
            end;
            PaymentExportDataGroup."Line No." += 1;
            PaymentExportDataGroup.Amount += PaymentExportData.Amount;
        until PaymentExportData.Next = 0;
        InsertPmtGroup(PaymentGroupNo);
    end;

    local procedure IsNewGroup(): Boolean
    begin
        exit(
          (PaymentExportData."Sender Bank BIC" <> PaymentExportDataGroup."Sender Bank BIC") or
          (PaymentExportData."SEPA Instruction Priority Text" <> PaymentExportDataGroup."SEPA Instruction Priority Text") or
          (PaymentExportData."Transfer Date" <> PaymentExportDataGroup."Transfer Date") or
          (PaymentExportData."SEPA Batch Booking" <> PaymentExportDataGroup."SEPA Batch Booking") or
          (PaymentExportData."SEPA Charge Bearer Text" <> PaymentExportDataGroup."SEPA Charge Bearer Text"));
    end;

    local procedure InitPmtGroup()
    begin
        PaymentExportDataGroup := PaymentExportData;
        PaymentExportDataGroup."Line No." := 0; // used for counting transactions within group
        PaymentExportDataGroup.Amount := 0; // used for summarizing transactions within group
    end;

    local procedure InsertPmtGroup(var PaymentGroupNo: Integer)
    begin
        PaymentGroupNo += 1;
        PaymentExportDataGroup."Entry No." := PaymentGroupNo;
        PaymentExportDataGroup."Payment Information ID" :=
          CopyStr(
            StrSubstNo('%1/%2', PaymentExportData."Message ID", PaymentGroupNo),
            1, MaxStrLen(PaymentExportDataGroup."Payment Information ID"));
        PaymentExportDataGroup.Insert();
    end;

    local procedure UpdateRemittanceInfo(PaymentExportData: Record "Payment Export Data")
    begin
        RmtStrdRef := '';
        if SwissExport then begin
            RmtStrdRef := RemittanceText1;
            RemittanceText1 := '';
            if PaymentExportData."Swiss Payment Type" = PaymentExportData."Swiss Payment Type"::"1" then
                remittancetext2 := ''
            else
                if PaymentExportData."Payment Reference" = '' then
                    rmtstrdref := ''
                else
                    rmtstrdref := PaymentExportData."Payment Reference";
        end;
    end;
}

