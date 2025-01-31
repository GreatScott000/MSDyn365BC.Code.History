report 5756 "Create Warehouse Location"
{
    ApplicationArea = Warehouse;
    Caption = 'Create Warehouse Location';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(LocCode; LocCode)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Location Code';
                        ToolTip = 'Specifies the location where the warehouse activity takes place. ';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            Clear(Location);
                            if LocCode <> '' then
                                Location.Code := LocCode;
                            if PAGE.RunModal(0, Location) = ACTION::LookupOK then begin
                                Location.TestField("Bin Mandatory", false);
                                Location.TestField("Use As In-Transit", false);
                                Location.TestField("Directed Put-away and Pick", false);
                                LocCode := Location.Code;
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            Location.Get(LocCode);
                            Location.TestField("Bin Mandatory", false);
                            Location.TestField("Use As In-Transit", false);
                            Location.TestField("Directed Put-away and Pick", false);
                        end;
                    }
                    field(AdjBinCode; AdjBinCode)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Adjustment Bin Code';
                        ToolTip = 'Specifies the code of the item on the bin list.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            Bin.Reset();
                            if LocCode <> '' then
                                Bin.SetRange("Location Code", LocCode);

                            if PAGE.RunModal(0, Bin) = ACTION::LookupOK then begin
                                if LocCode = '' then
                                    LocCode := Bin."Location Code";
                                AdjBinCode := Bin.Code;
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            if AdjBinCode <> '' then
                                if LocCode <> '' then
                                    Bin.Get(LocCode, AdjBinCode)
                                else begin
                                    Bin.SetRange(Code, AdjBinCode);
                                    Bin.FindFirst;
                                    LocCode := Bin."Location Code";
                                end;
                        end;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
    begin
        Location."Bin Mandatory" := true;
        Location.Validate("Directed Put-away and Pick", true);
        Location.Validate("Adjustment Bin Code", AdjBinCode);
        Location.Modify();

        if TempWhseJnlLine.Find('-') then
            repeat
                WhseJnlRegisterLine.RegisterWhseJnlLine(TempWhseJnlLine);
            until TempWhseJnlLine.Next() = 0;

        if not HideValidationDialog then begin
            Window.Close;
            Message(Text004);
        end;
    end;

    trigger OnPreReport()
    var
        WhseEntry: Record "Warehouse Entry";
    begin
        if LocCode = '' then
            Error(Text001);
        if AdjBinCode = '' then
            Error(Text002);

        ItemLedgEntry.Reset();
        ItemLedgEntry.SetCurrentKey("Item No.", Open);
        if ItemLedgEntry.Find('-') then
            repeat
                ItemLedgEntry.SetRange("Item No.", ItemLedgEntry."Item No.");
                ItemLedgEntry.SetRange(Open, true);
                ItemLedgEntry.SetRange("Location Code", LocCode);
                Found := ItemLedgEntry.Find('-');
                if Found and not HideValidationDialog then
                    if not Confirm(StrSubstNo('%1 %2 %3 %4 %5 %6 %7 %8',
                           Text010, Text011, Text012, Text013, Text014,
                           Text015, StrSubstNo(Text016, LocCode), Text017), false)
                    then
                        CurrReport.Quit;
                ItemLedgEntry.SetRange("Location Code");
                ItemLedgEntry.SetRange(Open);
                ItemLedgEntry.Find('+');
                ItemLedgEntry.SetRange("Item No.");
            until (ItemLedgEntry.Next() = 0) or Found;

        if not Found then
            Error(Text018, Location.TableCaption, Location.FieldCaption(Code), LocCode);
        Clear(ItemLedgEntry);

        WhseEntry.SetRange("Location Code", LocCode);
        if not WhseEntry.IsEmpty() then
            Error(
              Text019, LocCode, WhseEntry.TableCaption);

        TempWhseJnlLine.Reset();
        TempWhseJnlLine.DeleteAll();

        LastLineNo := 0;

        with ItemLedgEntry do begin
            SetCurrentKey(
              "Item No.", "Location Code", Open, "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Package No.");

            Location.Get(LocCode);
            Location.TestField("Adjustment Bin Code", '');
            CheckWhseDocs;

            Bin.Get(LocCode, AdjBinCode);

            if Find('-') then begin
                if not HideValidationDialog then begin
                    Window.Open(StrSubstNo(Text020, "Location Code") + Text003);
                    i := 1;
                    CountItemLedgEntries := Count;
                end;

                repeat
                    if not HideValidationDialog then begin
                        Window.Update(100, i);
                        Window.Update(102, Round(i / CountItemLedgEntries * 10000, 1));
                    end;

                    SetRange("Item No.", "Item No.");
                    if Find('-') then begin
                        SetRange("Location Code", LocCode);
                        SetRange(Open, true);
                        if Find('-') then
                            repeat
                                SetRange("Variant Code", "Variant Code");
                                if Find('-') then
                                    repeat
                                        SetRange("Unit of Measure Code", "Unit of Measure Code");
                                        if Find('-') then
                                            repeat
                                                SetRange("Lot No.", "Lot No.");
                                                if Find('-') then
                                                    repeat
                                                        SetRange("Package No.", "Package No.");
                                                        if Find('-') then
                                                            repeat
                                                                SetRange("Serial No.", "Serial No.");
                                                                CalcSums("Remaining Quantity");
                                                                if "Remaining Quantity" < 0 then
                                                                    Error(
                                                                      StrSubstNo(Text005, BuildErrorText) +
                                                                      StrSubstNo(Text009, ItemsWithNegativeInventory.ObjectId));
                                                                if "Remaining Quantity" > 0 then
                                                                    CreateWhseJnlLine();
                                                                Find('+');
                                                                SetRange("Serial No.");
                                                            until Next() = 0;
                                                        Find('+');
                                                        SetRange("Package No.");
                                                    until Next() = 0;
                                                Find('+');
                                                SetRange("Lot No.");
                                            until Next() = 0;
                                        Find('+');
                                        SetRange("Unit of Measure Code")
                                    until Next() = 0;
                                Find('+');
                                SetRange("Variant Code");
                            until Next() = 0;
                    end;

                    SetRange(Open);
                    SetRange("Location Code");
                    Find('+');
                    if not HideValidationDialog then
                        i := i + Count;
                    SetRange("Item No.");
                until Next() = 0;
            end;
        end;
    end;

    var
        TempWhseJnlLine: Record "Warehouse Journal Line" temporary;
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        Location: Record Location;
        Bin: Record Bin;
        ItemsWithNegativeInventory: Report "Items with Negative Inventory";
        WMSMgt: Codeunit "WMS Management";
        UOMMgt: Codeunit "Unit of Measure Management";
        Window: Dialog;
        LocCode: Code[10];
        Text001: Label 'Enter a location code.';
        Text002: Label 'Enter an adjustment bin code.';
        Text003: Label 'Count #100##### @102@@@@@@@@';
        AdjBinCode: Code[20];
        i: Integer;
        CountItemLedgEntries: Integer;
        LastLineNo: Integer;
        Text004: Label 'The conversion was successfully completed.';
        Text005: Label 'Negative inventory was found in the location. You must clear this negative inventory in the program before you can proceed with the conversion.\\%1.\\';
        Text006: Label 'Location %1 cannot be converted because at least one %2 is not completely posted yet.\\Post or delete all of them before restarting the conversion batch job.';
        Text007: Label 'Location %1 cannot be converted because at least one %2 is not completely registered yet.\\Register or delete all of them before restarting the conversion batch job.';
        Text008: Label 'Location %1 cannot be converted because at least one %2 exists.\\Delete all of them before restarting the conversion batch job.';
        Text009: Label 'Run %1 for a report of all negative inventory in the location.';
        Text010: Label 'Inventory exists on this location. By choosing Yes from this warning, you are confirming that you want to enable this location to use Warehouse Management Systems by running a batch job to create warehouse entries for the inventory in this location.\\';
        Text011: Label 'If you want to proceed, you must first ensure that no negative inventory exists in the location. Negative inventory is not allowed in a location that uses warehouse management logic and must be cleared by posting a suitable quantity to inventory. ';
        Text012: Label 'You can perform a check for negative inventory by using the Items with Negative Inventory report.\\';
        Text013: Label 'If you can confirm that no negative inventory exists in the location, proceed with the conversion batch job. If negative inventory is found, the batch job will stop with an error message. ';
        Text014: Label 'The result of this batch job is that initial warehouse entries will be created. You must balance these initial warehouse entries on the adjustment bin by posting a warehouse physical inventory journal or a warehouse item journal to assign zones and bins to items.\';
        Text015: Label 'You must create zones and bins before posting a warehouse physical inventory.\\';
        Text016: Label 'Location %1 will be a warehouse management location after the batch job has run successfully. This conversion cannot be reversed or undone after it has run.';
        Text017: Label '\\Do you really want to proceed?';
        Text018: Label 'There is nothing to convert for %1 %2 ''%3''.';
        Text019: Label 'Location %1 cannot be converted because at least one %2 exists for this location.';
        Text020: Label 'Location %1 will be converted to a WMS location.\\This might take some time so please be patient.';
        PrimaryFieldsTxt: Label '%1: %2, %3: %4', Locked = true, Comment = 'Do not translate';
        AdditionalFieldsTxt: Label '%1, %2: %3', Locked = true, Comment = 'Do not translate';

        Found: Boolean;

    protected var
        HideValidationDialog: Boolean;

    local procedure CheckWhseDocs()
    var
        WhseRcptHeader: Record "Warehouse Receipt Header";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WhseActivHeader: Record "Warehouse Activity Header";
        WhseWkshLine: Record "Whse. Worksheet Line";
    begin
        WhseRcptHeader.SetRange("Location Code", Location.Code);
        if not WhseRcptHeader.IsEmpty() then
            Error(
              Text006,
              Location.Code,
              WhseRcptHeader.TableCaption);

        WarehouseShipmentHeader.SetRange("Location Code", Location.Code);
        if not WarehouseShipmentHeader.IsEmpty() then
            Error(
              Text006,
              Location.Code,
              WarehouseShipmentHeader.TableCaption);

        WhseActivHeader.SetCurrentKey("Location Code");
        WhseActivHeader.SetRange("Location Code", Location.Code);
        if WhseActivHeader.FindFirst then
            Error(
              Text007,
              Location.Code,
              WhseActivHeader.Type);

        WhseWkshLine.SetRange("Location Code", Location.Code);
        if not WhseWkshLine.IsEmpty() then
            Error(
              Text008,
              Location.Code,
              WhseWkshLine.TableCaption);
    end;

    local procedure CreateWhseJnlLine()
    begin
        LastLineNo := LastLineNo + 10000;

        with ItemLedgEntry do begin
            TempWhseJnlLine.Init();
            TempWhseJnlLine."Entry Type" := TempWhseJnlLine."Entry Type"::"Positive Adjmt.";
            TempWhseJnlLine."Line No." := LastLineNo;
            TempWhseJnlLine."Location Code" := "Location Code";
            TempWhseJnlLine."Registering Date" := Today;
            TempWhseJnlLine."Item No." := "Item No.";
            TempWhseJnlLine.Quantity := Round("Remaining Quantity" / "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision);
            TempWhseJnlLine."Qty. (Base)" := "Remaining Quantity";
            TempWhseJnlLine."Qty. (Absolute)" := Round(Abs("Remaining Quantity") / "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision);
            TempWhseJnlLine."Qty. (Absolute, Base)" := Abs("Remaining Quantity");
            TempWhseJnlLine."User ID" := UserId;
            TempWhseJnlLine."Variant Code" := "Variant Code";
            if "Unit of Measure Code" = '' then begin
                Item.Get("Item No.");
                "Unit of Measure Code" := Item."Base Unit of Measure";
            end;
            TempWhseJnlLine."Unit of Measure Code" := "Unit of Measure Code";
            TempWhseJnlLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
            TempWhseJnlLine.CopyTrackingFromItemLedgEntry(ItemLedgEntry);
            TempWhseJnlLine.Validate("Zone Code", Bin."Zone Code");
            TempWhseJnlLine."Bin Code" := AdjBinCode;
            TempWhseJnlLine."To Bin Code" := AdjBinCode;
            GetItemUnitOfMeasure("Item No.", "Unit of Measure Code");
            TempWhseJnlLine.Cubage := TempWhseJnlLine."Qty. (Absolute)" * ItemUnitOfMeasure.Cubage;
            TempWhseJnlLine.Weight := TempWhseJnlLine."Qty. (Absolute)" * ItemUnitOfMeasure.Weight;
            OnCreateWhseJnlLineOnBeforeCheck(TempWhseJnlLine, ItemLedgEntry);
            WMSMgt.CheckWhseJnlLine(TempWhseJnlLine, 0, 0, false);
            TempWhseJnlLine.Insert();
        end;
    end;

    local procedure GetItemUnitOfMeasure(ItemNo: Code[20]; UOMCode: Code[10])
    begin
        if (ItemUnitOfMeasure."Item No." <> ItemNo) or
           (ItemUnitOfMeasure.Code <> UOMCode)
        then
            if not ItemUnitOfMeasure.Get(ItemNo, UOMCode) then
                ItemUnitOfMeasure.Init();
    end;

    local procedure BuildErrorText(): Text
    var
        ErrorText: Text;
    begin
        with ItemLedgEntry do begin
            ErrorText :=
                StrSubstNo(
                    PrimaryFieldsTxt, FieldCaption("Location Code"), "Location Code", FieldCaption("Item No."), "Item No.");
            if "Variant Code" <> '' then
                ErrorText :=
                    StrSubstNo(AdditionalFieldsTxt, ErrorText, FieldCaption("Variant Code"), "Variant Code");
            if "Unit of Measure Code" <> '' then
                ErrorText :=
                    StrSubstNo(AdditionalFieldsTxt, ErrorText, FieldCaption("Unit of Measure Code"), "Unit of Measure Code");
            if "Lot No." <> '' then
                ErrorText :=
                    StrSubstNo(AdditionalFieldsTxt, ErrorText, FieldCaption("Lot No."), "Lot No.");
            if "Serial No." <> '' then
                ErrorText :=
                    StrSubstNo(AdditionalFieldsTxt, ErrorText, FieldCaption("Serial No."), "Serial No.");
            if "Package No." <> '' then
                ErrorText :=
                    StrSubstNo(AdditionalFieldsTxt, ErrorText, FieldCaption("Package No."), "Package No.");
        end;
        exit(ErrorText);
    end;

    procedure InitializeRequest(LocationCode: Code[10]; AdjustmentBinCode: Code[20])
    begin
        LocCode := LocationCode;
        AdjBinCode := AdjustmentBinCode;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateWhseJnlLineOnBeforeCheck(var WarehouseJournalLine: Record "Warehouse Journal Line"; ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;
}

