codeunit 4751 "Recommended Apps Impl."
{
    Access = Internal;

    var
        RecommendedApps: Record "Recommended Apps";
        AppSourceURLLbl: Label 'https://appsource.microsoft.com/%1/product/dynamics-365-business-central/PUBID.%2|AID.%3|PAPPID.%4?tab=Overview', Locked = true;
        URLNotReachableErrLbl: Label 'Cannot add the recommended app with ID %1. The URL %2 cannot be reached, and the HTTP status code is %3. Are you sure that the information about the app is correct?',
            Comment = '%1 = App Id; %2 = App Source URL created with app info provided by the partner; %3 = Http StatusCode';
        LogoDoesNotExistErrLbl: Label 'Cannot add the recommended app with ID %1. The logo image cannot be downloaded, and the HTTP status code is %2.',
            Comment = '%1 = App Id; %2 = Http StatusCode';
        AppExistURLLbl: Label 'https://appsource.microsoft.com/view/app/pubid.%1|aid.%2|pappid.%3/?version=2017-04-24', Locked = true;
        AppSourceURLNotFoundErrLbl: Label 'Cannot get the AppSource URL.';

    [NonDebuggable]
    procedure InsertApp(Id: Guid; SortingId: Integer; Name: Text[250]; Publisher: Text[250]; "Short Description": Text[250]; "Long Description": Text[2048];
    "Recommended By": Enum "App Recommended By"; AppSourceURL: Text): Boolean
    var
        MemoryStream: DotNet MemoryStream;
        LanguageCode: Text;
        PubId: Text;
        AId: Text;
        PAppId: Text;
    begin
        // read the app information from the URL
        GetAppURLParametersFromAppSourceURL(AppSourceURL, LanguageCode, PubId, AId, PAppId);

        CheckIfURLExistsAndDownloadLogo(Id, LanguageCode, PubId, AId, PAppId, MemoryStream);

        RecommendedApps.Init();
        RecommendedApps.Id := Id;
        RecommendedApps.SortingId := SortingId;
        RecommendedApps.Name := Name;
        RecommendedApps.Publisher := Publisher;
        RecommendedApps."Short Description" := "Short Description";
        RecommendedApps."Long Description" := "Long Description";
        RecommendedApps.Logo.ImportStream(MemoryStream, 'logo', 'image/png');
        RecommendedApps."Recommended By" := "Recommended By";
        RecommendedApps."Language Code" := LanguageCode;
        RecommendedApps.PubId := PubId;
        RecommendedApps.AId := AId;
        RecommendedApps.PAppId := PAppId;
        exit(RecommendedApps.Insert());
    end;

    [NonDebuggable]
    procedure GetApp(Id: Guid; var SortingId: Integer; var Name: Text[250]; var Publisher: Text[250]; var "Short Description": Text[250]; var "Long Description": Text[2048];
        var "Recommended By": Enum "App Recommended By"; var AppSourceURL: Text)
    begin
        RecommendedApps.Get(Id);

        SortingId := RecommendedApps.SortingId;
        Name := RecommendedApps.Name;
        Publisher := RecommendedApps.Publisher;
        "Short Description" := RecommendedApps."Short Description";
        "Long Description" := RecommendedApps."Long Description";
        "Recommended By" := RecommendedApps."Recommended By";
        AppSourceURL := StrSubstNo(AppSourceURLLbl, RecommendedApps."Language Code", RecommendedApps.PubId, RecommendedApps.AId, RecommendedApps.PAppId)
    end;

    [NonDebuggable]
    procedure UpdateApp(Id: Guid; SortingId: Integer; Name: Text[250]; Publisher: Text[250]; "Short Description": Text[250]; "Long Description": Text[2048];
        "Recommended By": Enum "App Recommended By"; AppSourceURL: Text): Boolean
    var
        MemoryStream: DotNet MemoryStream;
        LanguageCode: Text;
        PubId: Text;
        AId: Text;
        PAppId: Text;
        IsModified: Boolean;
    begin
        // read the app information from the URL
        GetAppURLParametersFromAppSourceURL(AppSourceURL, LanguageCode, PubId, AId, PAppId);

        RecommendedApps.Get(Id);

        if RecommendedApps.SortingId <> SortingId then begin
            RecommendedApps.SortingId := SortingId;
            IsModified := true;
        end;

        if (RecommendedApps.Name <> Name)
            or (RecommendedApps.Publisher <> Publisher)
            or (RecommendedApps."Short Description" <> "Short Description")
            or (RecommendedApps."Long Description" <> "Long Description")
            or (RecommendedApps."Recommended By" <> "Recommended By")
        then begin
            RecommendedApps.Name := Name;
            RecommendedApps.Publisher := Publisher;
            RecommendedApps."Short Description" := "Short Description";
            RecommendedApps."Long Description" := "Long Description";
            RecommendedApps."Recommended By" := "Recommended By";
            IsModified := true;
        end;

        if (RecommendedApps."Language Code" <> LanguageCode) or (RecommendedApps.PubId <> PubId) or (RecommendedApps.AId <> AId) or (RecommendedApps.PAppId <> PAppId) then begin
            CheckIfURLExistsAndDownloadLogo(Id, LanguageCode, PubId, AId, PAppId, MemoryStream);
            RecommendedApps.Logo.ImportStream(MemoryStream, 'logo', 'image/png');
            RecommendedApps."Language Code" := LanguageCode;
            RecommendedApps.PubId := PubId;
            RecommendedApps.AId := AId;
            RecommendedApps.PAppId := PAppId;

            IsModified := true;
        end;

        if IsModified then
            exit(RecommendedApps.Modify());
        exit(true);
    end;

    [NonDebuggable]
    procedure RefreshImage(Id: Guid): Boolean
    var
        MemoryStream: DotNet MemoryStream;
    begin
        RecommendedApps.Get(Id);
        CheckIfURLExistsAndDownloadLogo(Id, RecommendedApps."Language Code", RecommendedApps.PubId, RecommendedApps.AId, RecommendedApps.PAppId, MemoryStream);
        RecommendedApps.Logo.ImportStream(MemoryStream, 'logo', 'image/png');
        exit(RecommendedApps.Modify());
    end;

    [NonDebuggable]
    procedure DeleteApp(Id: Guid): Boolean
    begin
        RecommendedApps.Get(Id);
        exit(RecommendedApps.Delete());
    end;

    [NonDebuggable]
    procedure DeleteAllApps()
    begin
        RecommendedApps.DeleteAll();
    end;

    [NonDebuggable]
    procedure GetAppURL(Id: Guid): Text
    begin
        if not RecommendedApps.Get(Id) then
            Error(AppSourceURLNotFoundErrLbl);

        exit(StrSubstNo(AppSourceURLLbl, RecommendedApps."Language Code", RecommendedApps.PubId, RecommendedApps.AId, RecommendedApps.PAppId));
    end;

    [NonDebuggable]
    local procedure GetAppURL(LanguageCode: Text; PubId: Text; AId: Text; PAppId: Text): Text
    begin
        exit(StrSubstNo(AppSourceURLLbl, LanguageCode, PubId, AId, PAppId));
    end;

    [NonDebuggable]
    local procedure GetAppURLParametersFromAppSourceURL(AppSourceURL: Text; var LanguageCode: Text; var PubId: Text; var AId: Text; var PAppId: Text)
    var
        Matches: Record Matches;
        Regex: Codeunit Regex;
    begin
        Regex.Match(AppSourceURL, '(?<=appsource.microsoft.com\/)(.+)(?=\/product)', 1, Matches);
        LanguageCode := Matches.ReadValue();

        Regex.Match(AppSourceURL, '(?<=PUBID.)(.+)(?=(%7CAID|\|AID))', 1, Matches);
        PubId := Matches.ReadValue();

        Regex.Match(AppSourceURL, '(?<=AID.)(.+)(?=(%7CPAPPID|\|PAPPID))', 1, Matches);
        AId := Matches.ReadValue();

        Regex.Match(AppSourceURL, '(?<=PAPPID.)(.+)(?=(\?tab=Overview))|(?<=PAPPID.)(.+)(?=($))', 1, Matches);
        PAppId := Matches.ReadValue();
    end;

    [NonDebuggable]
    local procedure CheckIfURLExistsAndDownloadLogo(Id: Guid; LanguageCode: Text; PubId: Text; AId: Text; PAppId: Text; var MemoryStream: DotNet MemoryStream)
    var
        WebClient: DotNet WebClient;
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        StatusCode: Integer;
        HttpResponseBodyText: Text;
        LogoURL: Text;
        ErrMsg: Text;
    begin
        HttpClient.Get(StrSubstNo(AppExistURLLbl, PubId, AId, PAppId), HttpResponseMessage);
        StatusCode := HttpResponseMessage.HttpStatusCode();

        if (StatusCode = 200) then begin
            HttpResponseMessage.Content().ReadAs(HttpResponseBodyText);
            JsonObj.ReadFrom(HttpResponseBodyText);
            JsonObj.Get('detailInformation', JsonTok);
            JsonObj := JsonTok.AsObject();
            JsonObj.Get('LargeIconUri', JsonTok);
            LogoURL := JsonTok.AsValue().AsText();

            if (StatusCode = 200) then begin
                WebClient := WebClient.WebClient();
                MemoryStream := MemoryStream.MemoryStream(WebClient.DownloadData(LogoURL));
                exit;
            end;

            ErrMsg := StrSubstNo(LogoDoesNotExistErrLbl, Id, StatusCode);
        end else
            ErrMsg := StrSubstNo(URLNotReachableErrLbl, Id, GetAppURL(LanguageCode, PubId, AId, PAppId), StatusCode);

        Error(ErrMsg);
    end;
}