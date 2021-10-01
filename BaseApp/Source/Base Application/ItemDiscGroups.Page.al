page 513 "Item Disc. Groups"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Item Discount Groups';
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Prices & Discounts';
    SourceTable = "Item Discount Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the item discount group.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description for the item discount group.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Item &Disc. Groups")
            {
                Caption = 'Item &Disc. Groups';
#if not CLEAN19
                action("Sales &Line Discounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales &Line Discounts';
                    Image = SalesLineDisc;
                    Visible = not ExtendedPriceEnabled;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'View the sales line discounts that are available. These discount agreements can be for individual customers, for a group of customers, for all customers or for a campaign.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';

                    trigger OnAction()
                    var
                        SalesLineDiscount: Record "Sales Line Discount";
                    begin
                        SalesLineDiscount.SetCurrentKey(Type, Code);
                        SalesLineDiscount.SetRange(Type, SalesLineDiscount.Type::"Item Disc. Group");
                        SalesLineDiscount.SetRange(Code, Code);
                        Page.Run(Page::"Sales Line Discounts", SalesLineDiscount);
                    end;
                }
#endif
            }
            group(Discounts)
            {
                Caption = 'Discounts';
                Image = Discount;
                action(SalesPriceListsDiscounts)
                {
                    AccessByPermission = TableData "Sales Discount Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Discounts';
                    Image = SalesLineDisc;
                    Visible = ExtendedPriceEnabled;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Set up sales discounts for the item discount group.';

                    trigger OnAction()
                    var
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        Rec.ShowPriceListLines(PriceType::Sale, AmountType::Discount);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
    end;

    var
        ExtendedPriceEnabled: Boolean;

    procedure GetSelectionFilter(): Text
    var
        ItemDiscGr: Record "Item Discount Group";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        CurrPage.SetSelectionFilter(ItemDiscGr);
        exit(SelectionFilterManagement.GetSelectionFilterForItemDiscountGroup(ItemDiscGr));
    end;
}

