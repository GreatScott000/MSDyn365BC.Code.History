#if not CLEAN18
page 5473 "Company Information Entity"
{
    Caption = 'companyInformation', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'companyInformation';
    EntitySetName = 'companyInformation';
    InsertAllowed = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SaveValues = true;
    SourceTable = "Company Information";
    ObsoleteState = Pending;
    ObsoleteReason = 'API version beta will be deprecated.';
    ObsoleteTag = '18.0';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    ApplicationArea = All;
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(displayName; Name)
                {
                    ApplicationArea = All;
                    Caption = 'DisplayName', Locked = true;
                }
                field(address; PostalAddressJSON)
                {
                    ApplicationArea = All;
                    Caption = 'Address', Locked = true;
                    ODataEDMType = 'POSTALADDRESS';
                    ToolTip = 'Specifies the company''s primary business address.';
                }
                field(phoneNumber; "Phone No.")
                {
                    ApplicationArea = All;
                    Caption = 'PhoneNumber', Locked = true;
                }
                field(faxNumber; "Fax No.")
                {
                    ApplicationArea = All;
                    Caption = 'FaxNumber', Locked = true;
                }
                field(email; "E-Mail")
                {
                    ApplicationArea = All;
                    Caption = 'Email', Locked = true;
                }
                field(website; "Home Page")
                {
                    ApplicationArea = All;
                    Caption = 'Website', Locked = true;
                }
                field(taxRegistrationNumber; "VAT Registration No.")
                {
                    ApplicationArea = All;
                    Caption = 'TaxRegistrationNumber', Locked = true;
                }
                field(currencyCode; CurrencyCode)
                {
                    ApplicationArea = All;
                    Caption = 'CurrencyCode', Locked = true;
                    Editable = false;
                }
                field(currentFiscalYearStartDate; FiscalYearStart)
                {
                    ApplicationArea = All;
                    Caption = 'CurrentFiscalYearStartDate', Locked = true;
                    Editable = false;
                }
                field(industry; "Industrial Classification")
                {
                    ApplicationArea = All;
                    Caption = 'Industry', Locked = true;
                }
                field(picture; Picture)
                {
                    ApplicationArea = All;
                    Caption = 'Picture', Locked = true;
                    Editable = false;
                }
                field(businessProfileId; BusinessId)
                {
                    ApplicationArea = All;
                    Caption = 'BusinessProfileId', Locked = true;
                }
                field(lastModifiedDateTime; "Last Modified Date Time")
                {
                    ApplicationArea = All;
                    Caption = 'LastModifiedDateTime', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields;
    end;

    trigger OnModifyRecord(): Boolean
    var
        GraphMgtCompanyInfo: Codeunit "Graph Mgt - Company Info.";
    begin
        GraphMgtCompanyInfo.ProcessComplexTypes(Rec, PostalAddressJSON);
        Modify(true);

        SetCalculatedFields;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields;
    end;

    var
        CurrencyCode: Code[10];
        FiscalYearStart: Date;
        PostalAddressJSON: Text;
        BusinessId: Text[250];

    local procedure SetCalculatedFields()
    var
        AccountingPeriod: Record "Accounting Period";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GraphMgtCompanyInfo: Codeunit "Graph Mgt - Company Info.";
    begin
        PostalAddressJSON := GraphMgtCompanyInfo.PostalAddressToJSON(Rec);

        GeneralLedgerSetup.Get();
        CurrencyCode := GeneralLedgerSetup."LCY Code";

        AccountingPeriod.SetRange("New Fiscal Year", true);
        if AccountingPeriod.FindLast then
            FiscalYearStart := AccountingPeriod."Starting Date";
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(PostalAddressJSON);
        Clear(BusinessId);
    end;
}
#endif