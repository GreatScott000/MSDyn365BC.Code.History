page 5662 "FA Posting Types Overview"
{
    Caption = 'FA Posting Types Overview';
    DataCaptionExpression = '';
    DataCaptionFields = "No.", Description;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    SaveValues = true;
    SourceTable = "Fixed Asset";

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(RoundingFactor; RoundingFactor)
                {
                    ApplicationArea = FixedAssets;
                    AutoFormatType = 1;
                    Caption = 'Rounding Factor';
                    ToolTip = 'Specifies the factor that is used to round the amounts.';
                }
            }
            group("Matrix Options")
            {
                Caption = 'Matrix Options';
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'View by';
                    ToolTip = 'Specifies by which period amounts are displayed.';
                }
                field(AmountType; AmountType)
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'View as';
                    ToolTip = 'Specifies how amounts are displayed. Net Change: The net change in the balance for the selected period. Balance at Date: The balance as of the last day in the selected period.';

                    trigger OnValidate()
                    begin
                        SetStartFilter(' ');
                    end;
                }
                field(MATRIX_CaptionRange; MATRIX_CaptionRange)
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'Column Set';
                    Editable = false;
                    ToolTip = 'Specifies the range of values that are displayed in the matrix window, for example, the total period. To change the contents of the field, choose Next Set or Previous Set.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowMatrix)
            {
                ApplicationArea = FixedAssets;
                Caption = '&Show Matrix';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'View the data overview according to the selected filters and options.';

                trigger OnAction()
                var
                    MatrixForm: Page "FA Posting Types Overv. Matrix";
                begin
                    Clear(MatrixForm);
                    MatrixForm.LoadMatrix(
                      MATRIX_CaptionSet, MatrixRecords, NoOfColumns, GetFilter("FA Posting Date Filter"), RoundingFactor);
                    MatrixForm.RunModal;
                end;
            }
            action("Previous Set")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Previous Set';
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Go to the previous set of data.';

                trigger OnAction()
                begin
                    GenerateColumnCaptions("Matrix Page Step Type"::Previous);
                end;
            }
            action("Next Set")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Next Set';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Go to the next set of data.';

                trigger OnAction()
                begin
                    GenerateColumnCaptions("Matrix Page Step Type"::Next);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        FAMatrixPostingType: Record "FA Matrix Posting Type";
    begin
        FAMatrixPostingType.CreateTypes;

        PeriodType := PeriodType::Year;
        AmountType := AmountType::"Balance at Date";
        NoOfColumns := GetMatrixDimension;
        SetStartFilter(' ');
        GenerateColumnCaptions("Matrix Page Step Type"::Initial);
    end;

    var
        Calendar: Record Date;
        MatrixRecord: Record "FA Matrix Posting Type";
        MatrixRecords: array[32] of Record "FA Matrix Posting Type";
        MATRIX_CaptionSet: array[32] of Text[80];
        MATRIX_CaptionRange: Text;
        MATRIX_PKFirstRecInCurrSet: Text;
        MATRIX_CurrentNoOfColumns: Integer;
        PeriodType: Enum "Analysis Period Type";
        RoundingFactor: Enum "Analysis Rounding Factor";
        AmountType: Enum "Analysis Amount Type";
        NoOfColumns: Integer;

    procedure SetStartFilter(SearchString: Code[10])
    var
        PeriodPageMgt: Codeunit PeriodPageManagement;
    begin
        if GetFilter("FA Posting Date Filter") <> '' then begin
            Calendar.SetFilter("Period Start", GetFilter("FA Posting Date Filter"));
            if not PeriodPageMgt.FindDate('+', Calendar, PeriodType) then
                PeriodPageMgt.FindDate('+', Calendar, PeriodType::Day);
            Calendar.SetRange("Period Start");
        end;
        PeriodPageMgt.FindDate(SearchString, Calendar, PeriodType);
        if AmountType = AmountType::"Net Change" then begin
            SetRange("FA Posting Date Filter", Calendar."Period Start", Calendar."Period End");
            if GetRangeMin("FA Posting Date Filter") = GetRangeMax("FA Posting Date Filter") then
                SetRange("FA Posting Date Filter", GetRangeMin("FA Posting Date Filter"));
        end else
            SetRange("FA Posting Date Filter", 0D, Calendar."Period End");
    end;

    local procedure GenerateColumnCaptions(StepType: Enum "Matrix Page Step Type")
    var
        MatrixMgt: Codeunit "Matrix Management";
        RecRef: RecordRef;
        CurrentMatrixRecordOrdinal: Integer;
    begin
        Clear(MATRIX_CaptionSet);
        Clear(MatrixRecords);
        CurrentMatrixRecordOrdinal := 1;

        RecRef.GetTable(MatrixRecord);
        RecRef.SetTable(MatrixRecord);

        MatrixMgt.GenerateMatrixData(
          RecRef, StepType.AsInteger(), ArrayLen(MatrixRecords), 2, MATRIX_PKFirstRecInCurrSet,
          MATRIX_CaptionSet, MATRIX_CaptionRange, MATRIX_CurrentNoOfColumns);

        if MATRIX_CurrentNoOfColumns > 0 then begin
            MatrixRecord.SetPosition(MATRIX_PKFirstRecInCurrSet);
            MatrixRecord.Find;
            repeat
                MatrixRecords[CurrentMatrixRecordOrdinal].Copy(MatrixRecord);
                CurrentMatrixRecordOrdinal := CurrentMatrixRecordOrdinal + 1;
            until (CurrentMatrixRecordOrdinal > MATRIX_CurrentNoOfColumns) or (MatrixRecord.Next <> 1);
        end;
    end;

    local procedure GetMatrixDimension(): Integer
    begin
        exit(ArrayLen(MATRIX_CaptionSet));
    end;
}

