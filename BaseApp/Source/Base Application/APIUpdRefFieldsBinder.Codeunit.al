codeunit 5153 "API - Upd. Ref. Fields Binder"
{
    SingleInstance = true;

    trigger OnRun()
    begin
        BindApiUpdateRefFields();
    end;

    var
        APIUpdateReferencedFields: Codeunit "API - Update Referenced Fields";
        APIUpdateReferencedFieldsIsBound: boolean;

    procedure BindApiUpdateRefFields()
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if APIUpdateReferencedFieldsIsBound then
            exit;
        if not GraphMgtGeneralTools.IsApiEnabled() then
            exit;

        BindSubscription(APIUpdateReferencedFields);
        APIUpdateReferencedFieldsIsBound := true;
    end;

    procedure UnBindApiUpdateRefFields()
    begin
        if Not APIUpdateReferencedFieldsIsBound then
            exit;
        UnBindSubscription(APIUpdateReferencedFields);
        APIUpdateReferencedFieldsIsBound := false;
    end;

    // Binding will go out of scope on CompanyClose, hence no subscription need for it.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnAfterCompanyOpen', '', false, false)]
    local procedure OnAfterCompanyOpen()
    begin
        BindApiUpdateRefFields();
    end;
}