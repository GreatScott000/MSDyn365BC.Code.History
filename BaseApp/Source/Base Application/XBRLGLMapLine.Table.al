table 397 "XBRL G/L Map Line"
{
    Caption = 'XBRL G/L Map Line';

    fields
    {
        field(1; "XBRL Taxonomy Name"; Code[20])
        {
            Caption = 'XBRL Taxonomy Name';
            TableRelation = "XBRL Taxonomy";
        }
        field(2; "XBRL Taxonomy Line No."; Integer)
        {
            Caption = 'XBRL Taxonomy Line No.';
            TableRelation = "XBRL Taxonomy Line"."Line No." WHERE("XBRL Taxonomy Name" = FIELD("XBRL Taxonomy Name"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "G/L Account Filter"; Text[250])
        {
            Caption = 'G/L Account Filter';
            TableRelation = "G/L Account";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5; "Business Unit Filter"; Text[250])
        {
            Caption = 'Business Unit Filter';
            TableRelation = "Business Unit";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6; "Global Dimension 1 Filter"; Text[250])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(7; "Global Dimension 2 Filter"; Text[250])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(8; "Timeframe Type"; Option)
        {
            Caption = 'Timeframe Type';
            OptionCaption = 'Net Change,Beginning Balance,Ending Balance';
            OptionMembers = "Net Change","Beginning Balance","Ending Balance";
        }
        field(9; "Amount Type"; Option)
        {
            Caption = 'Amount Type';
            OptionCaption = 'Net Amount,Debits Only,Credits Only';
            OptionMembers = "Net Amount","Debits Only","Credits Only";
        }
        field(10; "Normal Balance"; Option)
        {
            Caption = 'Normal Balance';
            OptionCaption = 'Debit (positive),Credit (negative)';
            OptionMembers = "Debit (positive)","Credit (negative)";
        }
        field(11; "Label Language Filter"; Text[10])
        {
            Caption = 'Label Language Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "XBRL Taxonomy Name", "XBRL Taxonomy Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

