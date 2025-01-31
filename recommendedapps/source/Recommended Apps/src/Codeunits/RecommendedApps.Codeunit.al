// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4750 "Recommended Apps"
{
    var
        [NonDebuggable]
        RecommendedAppsImpl: Codeunit "Recommended Apps Impl.";

    /// <summary>
    /// Insert a new recommended app.
    /// </summary>
    /// <param name="Id">The identifier for the app.</param>
    /// <param name="SortingId">The ID used to display apps in ascending order on the Recommended Apps page.</param>
    /// <param name="Name">The app name.</param>
    /// <param name="Publisher">The app publisher.</param>
    /// <param name="Short Description">The short description of the app that is displayed on the Recommended Apps page.</param>
    /// <param name="Long Description">The long description of the app that is displayed on the Recommended Apps page.</param>
    /// <param name="Recommended By">The entity that is recommending the app.</param>
    /// <param name="AppSourceURL">The AppSource URL of the app.</param>
    procedure InsertApp(Id: Guid; SortingId: Integer; Name: Text[250]; Publisher: Text[250]; "Short Description": Text[250]; "Long Description": Text[2048];
        "Recommended By": Enum "App Recommended By"; AppSourceURL: Text): Boolean
    begin
        exit(RecommendedAppsImpl.InsertApp(Id, SortingId, Name, Publisher, "Short Description", "Long Description", "Recommended By", AppSourceURL));
    end;

    /// <summary>
    /// Get a recommended app. Values are retrieved by reference. 
    /// </summary>
    /// <param name="Id">The identifier for the app.</param>
    /// <param name="SortingId">The ID used to display apps in ascending order on the Recommended Apps page.</param>
    /// <param name="Name">The app name.</param>
    /// <param name="Publisher">The app publisher.</param>
    /// <param name="Short Description">The short description of the app that is displayed on the Recommended Apps page.</param>
    /// <param name="Long Description">The long description of the app that is displayed on the Recommended Apps page.</param>
    /// <param name="Recommended By">The entity that is recommending the app.</param>
    /// <param name="AppSourceURL">The AppSource URL of the app.</param>
    procedure GetApp(Id: Guid; var SortingId: Integer; var Name: Text[250]; var Publisher: Text[250]; var "Short Description": Text[250]; var "Long Description": Text[2048];
        var "Recommended By": Enum "App Recommended By"; var AppSourceURL: Text)
    begin
        RecommendedAppsImpl.GetApp(Id, SortingId, Name, Publisher, "Short Description", "Long Description", "Recommended By", AppSourceURL);
    end;

    /// <summary>
    /// Update a recommended app.
    /// </summary>
    /// <param name="Id">The identifier for the app.</param>
    /// <param name="SortingId">The ID used to display apps in ascending order on the Recommended Apps page.</param>
    /// <param name="Name">The app name.</param>
    /// <param name="Publisher">The app publisher.</param>
    /// <param name="Short Description">The short description of the app that is displayed on the Recommended Apps page.</param>
    /// <param name="Long Description">The long description of the app that is displayed on the Recommended Apps page.</param>
    /// <param name="Recommended By">The entity that is recommending the app.</param>
    /// <param name="AppSourceURL">The AppSource URL of the app.</param>
    procedure UpdateApp(Id: Guid; SortingId: Integer; Name: Text[250]; Publisher: Text[250]; "Short Description": Text[250]; "Long Description": Text[2048];
        "Recommended By": Enum "App Recommended By"; AppSourceURL: Text): Boolean
    begin
        exit(RecommendedAppsImpl.UpdateApp(Id, SortingId, Name, Publisher, "Short Description", "Long Description", "Recommended By", AppSourceURL));
    end;

    /// <summary>
    /// Download the app's logo from AppSource. This is useful when the logo is changed.
    /// </summary>
    /// <param name="Id">The identifier for the app.</param>
    procedure RefreshImage(Id: Guid): Boolean
    begin
        exit(RecommendedAppsImpl.RefreshImage(Id));
    end;

    /// <summary>
    /// Delete a recommended app
    /// </summary>
    /// <param name="Id">The identifier for the app.</param>
    procedure DeleteApp(Id: Guid): Boolean
    begin
        exit(RecommendedAppsImpl.DeleteApp(Id));
    end;

    /// <summary>
    /// Delete all apps
    /// </summary>
    procedure DeleteAllApps()
    begin
        RecommendedAppsImpl.DeleteAllApps();
    end;

    /// <summary>
    /// Get the the AppSource URL of a recommended app.
    /// </summary>
    /// <param name="Id">The identifier for the app.</param>
    /// <returns>The AppSource URL for the app</returns>
    procedure GetAppURL(Id: Guid): Text
    begin
        exit(RecommendedAppsImpl.GetAppURL(Id));
    end;
}