// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9008 "User Login Times - Read"
{
    Access = Public;
    Assignable = false;


    Permissions = tabledata "User Login" = r;
}
