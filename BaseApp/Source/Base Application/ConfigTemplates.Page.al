page 1340 "Config Templates"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Templates';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Manage';
    SourceTable = "Config. Template Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater("Repeater")
            {
                field("Template Name"; Description)
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    ToolTip = 'Specifies a description of the template.';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    ToolTip = 'Specifies if the template is ready to be used';
                    Visible = NOT NewMode;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
#if not CLEAN18
            action(NewCustomerTemplate)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                RunObject = Page "Cust. Template Card";
                RunPageMode = Create;
                ToolTip = 'Create a new template for a customer card.';
                Visible = CreateCustomerActionVisible;
                ObsoleteReason = 'Action will be removed with other functionality related to "old" templates. Use "Customer Templ. List" page instead.';
                ObsoleteState = Pending;
                ObsoleteTag = '18.0';
            }
            action(NewVendorTemplate)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                RunObject = Page "Vendor Template Card";
                RunPageMode = Create;
                ToolTip = 'Create a new template for a vendor card.';
                Visible = CreateVendorActionVisible;
                ObsoleteReason = 'Action will be removed with other functionality related to "old" templates. Use "Vendor Templ. List" page instead.';
                ObsoleteState = Pending;
                ObsoleteTag = '18.0';
            }
            action(NewItemTemplate)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                RunObject = Page "Item Template Card";
                RunPageMode = Create;
                ToolTip = 'Create a new template for an item card.';
                Visible = CreateItemActionVisible;
                ObsoleteReason = 'Action will be removed with other functionality related to "old" templates. Use "Item Templ. List" page instead.';
                ObsoleteState = Pending;
                ObsoleteTag = '18.0';
            }
#endif
            action(NewConfigTemplate)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                RunObject = Page "Config. Template Header";
                RunPageMode = Create;
                ToolTip = 'Create a new configuration template.';
                Visible = CreateConfigurationTemplateActionVisible;
            }
        }
        area(processing)
        {
            action(Delete)
            {
                ApplicationArea = Basic, Suite, Invoicing;
                Caption = 'Delete';
                Image = Delete;
                ToolTip = 'Delete the record.';

                trigger OnAction()
                begin
                    if Confirm(StrSubstNo(DeleteQst, Code)) then
                        Delete(true);
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        case "Table ID" of
            DATABASE::Customer,
          DATABASE::Item:
                ConfigTemplateManagement.DeleteRelatedTemplates(Code, DATABASE::"Default Dimension");
        end;
    end;

    trigger OnOpenPage()
    var
        FilterValue: Text;
    begin
        FilterValue := GetFilter("Table ID");

        if not Evaluate(FilteredTableId, FilterValue) then
            FilteredTableId := 0;

        UpdateActionsVisibility;
        UpdatePageCaption;

        if NewMode then
            UpdateSelection;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if NewMode and (CloseAction = ACTION::LookupOK) then
            SaveSelection;
    end;

    var
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        CreateConfigurationTemplateActionVisible: Boolean;
        NewMode: Boolean;
        FilteredTableId: Integer;
        ConfigurationTemplatesCap: Label 'Configuration Templates';
        CustomerTemplatesCap: Label 'Customer Templates';
        VendorTemplatesCap: Label 'Vendor Templates';
        ItemTemplatesCap: Label 'Item Templates';
        SelectConfigurationTemplatesCap: Label 'Select a template';
        SelectCustomerTemplatesCap: Label 'Select a template for a new customer';
        SelectVendorTemplatesCap: Label 'Select a template for a new vendor';
        SelectItemTemplatesCap: Label 'Select a template for a new item';
        DeleteQst: Label 'Delete %1?', Comment = '%1 - configuration template code';

    protected var
        CreateCustomerActionVisible: Boolean;
        CreateVendorActionVisible: Boolean;
        CreateItemActionVisible: Boolean;

    local procedure UpdateActionsVisibility()
    begin
        CreateCustomerActionVisible := false;
        CreateItemActionVisible := false;
        CreateConfigurationTemplateActionVisible := false;
        CreateVendorActionVisible := false;

        case FilteredTableId of
            DATABASE::Customer:
                CreateCustomerActionVisible := true;
            DATABASE::Item:
                CreateItemActionVisible := true;
            DATABASE::Vendor:
                CreateVendorActionVisible := true;
            else
                CreateConfigurationTemplateActionVisible := true;
        end;
    end;

    local procedure UpdatePageCaption()
    var
        PageCaption: Text;
    begin
        if not NewMode then
            case FilteredTableId of
                DATABASE::Customer:
                    PageCaption := CustomerTemplatesCap;
                DATABASE::Vendor:
                    PageCaption := VendorTemplatesCap;
                DATABASE::Item:
                    PageCaption := ItemTemplatesCap;
                else
                    PageCaption := ConfigurationTemplatesCap;
            end
        else
            case FilteredTableId of
                DATABASE::Customer:
                    PageCaption := SelectCustomerTemplatesCap;
                DATABASE::Vendor:
                    PageCaption := SelectVendorTemplatesCap;
                DATABASE::Item:
                    PageCaption := SelectItemTemplatesCap;
                else
                    PageCaption := SelectConfigurationTemplatesCap;
            end;

        CurrPage.Caption(PageCaption);
    end;

    local procedure UpdateSelection()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        TemplateSelectionMgt: Codeunit "Template Selection Mgt.";
        TemplateCode: Code[10];
    begin
        case FilteredTableId of
            DATABASE::Customer:
                TemplateSelectionMgt.GetLastCustTemplateSelection(TemplateCode);
            DATABASE::Vendor:
                TemplateSelectionMgt.GetLastVendorTemplateSelection(TemplateCode);
            DATABASE::Item:
                TemplateSelectionMgt.GetLastItemTemplateSelection(TemplateCode);
        end;

        if not (TemplateCode = '') then
            if ConfigTemplateHeader.Get(TemplateCode) then
                SetPosition(ConfigTemplateHeader.GetPosition);
    end;

    local procedure SaveSelection()
    var
        TemplateSelectionMgt: Codeunit "Template Selection Mgt.";
    begin
        case FilteredTableId of
            DATABASE::Customer:
                TemplateSelectionMgt.SaveCustTemplateSelectionForCurrentUser(Code);
            DATABASE::Vendor:
                TemplateSelectionMgt.SaveVendorTemplateSelectionForCurrentUser(Code);
            DATABASE::Item:
                TemplateSelectionMgt.SaveItemTemplateSelectionForCurrentUser(Code);
        end;
    end;

    procedure SetNewMode()
    begin
        NewMode := true;
    end;
}

