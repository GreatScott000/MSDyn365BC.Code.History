// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134692 "Email E2E Tests"
{
    SubType = Test;

    var
        Assert: Codeunit "Library Assert";
        Email: Codeunit Email;
        EmailMessageOpenPermissionErr: Label 'You can only open your own email messages.';
        EmailWasQueuedForSendingMsg: Label 'The message was queued for sending.';
        FromDisplayNameLbl: Label '%1 (%2)', Comment = '%1 - Account Name, %2 - Email address', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteSentEmailDeletesMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        EmailRecipient: Record "Email Recipient";
        Attachment: Record "Email Message Attachment";
        ConnectorMock: Codeunit "Connector Mock";
        Base64Convert: Codeunit "Base64 Convert";
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
    begin
        // [SCENARIO] When a sent email is deleted, the underlying email message is also deleted

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        // [GIVEn] A email message is created
        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment2', 'text/plain', Base64Convert.ToBase64('Content'));

        // [GIVEN] The message has been sent
        SentEmail.Init();
        SentEmail."Message Id" := Message.GetId();
        SentEmail.Insert();

        // [WHEN] Deleting the sent email record
        SentEmail.SetRange("Message Id", Message.GetId());
        SentEmail.FindSet();
        SentEmail.Delete();

        // [THEN] The email message is deleted as well
        Assert.IsFalse(Message.Get(Message.GetId()), 'The message was not deleted.');

        EmailRecipient.SetRange("Email Message Id", Message.GetId());
        Assert.RecordIsEmpty(EmailRecipient);

        Attachment.SetRange("Email Message Id", Message.GetId());
        Assert.RecordIsEmpty(Attachment);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteEmailOutboxDeletesMessageTest()
    var
        Outbox: Record "Email Outbox";
        TempAccount: Record "Email Account" temporary;
        EmailRecipient: Record "Email Recipient";
        Attachment: Record "Email Message Attachment";
        ConnectorMock: Codeunit "Connector Mock";
        Base64Convert: Codeunit "Base64 Convert";
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
    begin
        // [SCENARIO] When an outbox entry is deleted, the underlying email message is deleted as well

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        // [GIVEn] A email message is created
        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment2', 'text/plain', Base64Convert.ToBase64('Content'));

        // [GIVEN] The message has been queued
        Outbox.Init();
        Outbox."Message Id" := Message.GetId();
        Outbox.Insert();

        // [WHEN] The first outbox record is deleted
        Outbox.SetRange("Message Id", Message.GetId());
        Outbox.FindSet();
        Outbox.Delete();

        // [THEN] The email message is deleted
        Assert.IsFalse(Message.Get(Message.GetId()), 'The message was not deleted.');

        EmailRecipient.SetRange("Email Message Id", Message.GetId());
        Assert.RecordIsEmpty(EmailRecipient);

        Attachment.SetRange("Email Message Id", Message.GetId());
        Assert.RecordIsEmpty(Attachment);
    end;

    [Test]
    [HandlerFunctions('ChooseAccountHandler,SaveAsDraftOnCloseHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SaveDraftThroughEditor()
    var
        TempAccount: Record "Email Account" temporary;
        Outbox: Record "Email Outbox";
        Message: Record "Email Message";
        EmailRecipient: Record "Email Recipient";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] When the editor page is closed and the user choose to save a draft, a draft email is enqued in the outbox

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Outbox.DeleteAll(); // Outbox should be empty

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailEditor.Run();

        Editor.Account.AssistEdit(); // Handled in ChooseAccountHandler
        Editor.ToField.SetValue('recipient1@test.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The page is closed and the email is saved as draft. See SaveAsDraftOnCloseHandler
        Editor.Close();

        // [THEN] The mail is saved in the outbox as a draft and the info is correct
        Outbox.Reset();
        Assert.RecordCount(Outbox, 1); // There is only one record in the outbox

        Assert.IsTrue(Outbox.FindFirst(), 'An Email Outbox record should have been inserted.');
        Assert.AreEqual('Test Subject', Outbox.Description, 'A different description was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector".AsInteger(), Outbox.Connector.AsInteger(), 'A different connector was expected.');
        Assert.AreEqual(TempAccount."Account Id", Outbox."Account Id", 'A different account was expected');
        Assert.AreEqual('', Outbox."Send From", 'An empty sent from was expected');
        Assert.AreEqual(Enum::"Email Status"::Draft.AsInteger(), Outbox.Status.AsInteger(), 'A different sent from was expected');

        Assert.IsTrue(Message.Get(Outbox."Message Id"), 'The email message should have been created');
        Assert.AreEqual('Test Subject', Message.Subject, 'Wrong subject on the email message');

        EmailRecipient.SetRange("Email Message Id", Message.Id);
        Assert.IsTrue(EmailRecipient.FindSet(), 'Email recipient should have been created');
        Assert.AreEqual(Enum::"Email Recipient Type"::"To", EmailRecipient."Email Recipient Type", 'Wrong recipient type');
        Assert.AreEqual('recipient1@test.com', EmailRecipient."Email Address", 'Wrong email address on the recipient');
        Assert.AreEqual(0, EmailRecipient.Next(), 'There should not be another recipient');
    end;

    [Test]
    [HandlerFunctions('ChooseAccountHandler,DiscardEmailEditorHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DiscardEmailThroughEditor()
    var
        TempAccount: Record "Email Account" temporary;
        Outbox: Record "Email Outbox";
        Message: Record "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] When the editor page is closed and the user choose to discard the email, there is no outbox entry.

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Outbox.DeleteAll(); // Outbox should be empty
        Message.DeleteAll();

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailEditor.Run();

        Editor.Account.AssistEdit(); // Handled in ChooseAccountHandler
        Editor.ToField.SetValue('recipient@test.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The page is closed and the email is discarded. See DiscardEmailEditorHandler
        Editor.Close();

        // [THEN] The mail is saved in the outbox as a draft and the info is correct
        Outbox.Reset();
        Assert.RecordCount(Outbox, 0);
        Assert.RecordCount(Message, 0);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SaveExistingDraftThroughEditor()
    var
        TempAccount: Record "Email Account" temporary;
        Outbox: Record "Email Outbox";
        OutboxForUser: Record "Email Outbox" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        Message: Codeunit "Email Message";
        Editor: TestPage "Email Editor";
        OutboxPage: TestPage "Email Outbox";
        DraftId: Guid;
        Recipients: List of [Text];
    begin
        // [SCENARIO] When an existing draft is opened and the editor page is closed, the draft email is saved

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Outbox.DeleteAll(); // Outbox should be empty
        Assert.RecordCount(Outbox, 0); // Outbox is empty

        // [GIVEN] A draft email message exists
        Recipients.Add('recipient1@test.com');
        Message.Create(Recipients, 'Test Subject', 'Test body', true);
        DraftId := Message.GetId();
        Outbox.Init();
        Outbox."Message Id" := DraftId;
        Outbox.Description := 'Test Subject';
        Outbox.Connector := Enum::"Email Connector"::"Test Email Connector";
        Outbox."Account Id" := TempAccount."Account Id";
        Outbox.Status := Enum::"Email Status"::Draft;
        Outbox."User Security Id" := UserSecurityId();
        Outbox.Insert();

        // [GIVEN] The draft email was opened from outbox and subject is changed
        Editor.Trap();
        OutboxPage.OpenView();
        OutboxForUser.Transferfields(Outbox);
        OutboxPage.GoToRecord(OutboxForUser);
        OutboxPage.Desc.Drilldown();
        Editor.SubjectField.SetValue('Test Subject Changed');

        // [WHEN] The page page is closed and the email is saved as draft again
        Editor.Close(); // Draft email is saved on close

        // [THEN] The mail is saved as the same draft in the outbox, no new draft is created and the info is correct
        Outbox.Reset();
        Assert.RecordCount(Outbox, 1); // There is only one record in the outbox
        Outbox.SetRange("Message Id", DraftId);
        Assert.RecordCount(Outbox, 1); // The one outbox record is the same record as before
        Assert.IsTrue(Outbox.FindFirst(), 'An Email Outbox record should have been inserted.');
        Assert.AreEqual('Test Subject Changed', Outbox.Description, 'A different description was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector".AsInteger(), Outbox.Connector.AsInteger(), 'A different connector was expected.');
        Assert.AreEqual(TempAccount."Account Id", Outbox."Account Id", 'A different account was expected');
        Assert.AreEqual('', Outbox."Send From", 'An empty sent from was expected');
        Assert.AreEqual(Enum::"Email Status"::Draft.AsInteger(), Outbox.Status.AsInteger(), 'A different sent from was expected');
    end;

    [Test]
    procedure SendNewMessageThroughEditorTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] A new email message can be create in the email editor page from the Accouns page

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailMessage.Create('', '', '', false);
        Email.OpenInEditor(EmailMessage, TempAccount);

        Editor.ToField.SetValue('recipient@test.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The send action is invoked
        Editor.Send.Invoke();

        // [THEN] The mail is sent and the info is correct
        EmailMessage.Get(ConnectorMock.GetEmailMessageID());
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A Sent Email record should have been inserted.');
        Assert.AreEqual('Test Subject', SentEmail.Description, 'A different description was expected');
        Assert.AreEqual(TempAccount."Account Id", SentEmail."Account Id", 'A different account was expected');
        Assert.AreEqual(TempAccount."Email Address", SentEmail."Sent From", 'A different sent from was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", SentEmail.Connector, 'A different connector was expected');
    end;

    [Test]
    procedure SendNewMessageThroughEditorFailureAndCorrectionTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        Outbox: Record "Email Outbox";
        OutboxForUser: Record "Email Outbox" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Editor: TestPage "Email Editor";
        OutboxPage: TestPage "Email Outbox";
    begin
        // [SCENARIO] A new email message can be created and corrected in the email editor after successful sending only one record in Sent emails exists and not record in outbox

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        // [GIVEN] There was a mistake on typing the email
        ConnectorMock.FailOnSend(true);

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailMessage.Create('', '', '', false);
        Email.OpenInEditor(EmailMessage, TempAccount);

        Editor.ToField.SetValue('recipient@test.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The send action is invoked
        asserterror Editor.Send.Invoke();
        Assert.ExpectedError('Failed to send email');
        Editor.Close();

        // [THEN] There is a record in Outbox for this email with status failed
        EmailMessage.Get(ConnectorMock.GetEmailMessageID());
        Outbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.RecordCount(Outbox, 1);
        Assert.IsTrue(Outbox.FindFirst(), 'An Email Outbox record should have been inserted.');
        Assert.AreEqual('Test Subject', Outbox.Description, 'A different description was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector".AsInteger(), Outbox.Connector.AsInteger(), 'A different connector was expected.');
        Assert.AreEqual(TempAccount."Account Id", Outbox."Account Id", 'A different account was expected');
        Assert.AreEqual(TempAccount."Email Address", Outbox."Send From", 'A different sent from was expected');
        Assert.AreEqual(Enum::"Email Status"::Failed.AsInteger(), Outbox.Status.AsInteger(), 'A different sent from was expected');

        // [GIVEN] The email was opened from outbox and corrected
        ConnectorMock.FailOnSend(false);
        Editor.Trap();
        OutboxPage.OpenView();
        OutboxForUser.Transferfields(Outbox);
        OutboxPage.GoToRecord(OutboxForUser);
        OutboxPage.Desc.Drilldown();

        // [WHEN] The email is sent again

        Editor.Send.Invoke();

        // [THEN] The mail is sent and the info is correct and the outbox record for the previous failure is deleted
        EmailMessage.Get(ConnectorMock.GetEmailMessageID());
        Outbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.RecordIsEmpty(Outbox);

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A Sent Email record should have been inserted.');
        Assert.AreEqual('Test Subject', SentEmail.Description, 'A different description was expected');
        Assert.AreEqual(TempAccount."Account Id", SentEmail."Account Id", 'A different account was expected');
        Assert.AreEqual(TempAccount."Email Address", SentEmail."Sent From", 'A different sent from was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", SentEmail.Connector, 'A different connector was expected');
    end;

    [Test]
    [HandlerFunctions('MessageQueued')]
    procedure OpenAndResendSentEmailTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        Any: Codeunit Any;
        EmailMessage: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorMock: Codeunit "Connector Mock";
        EmailViewer: TestPage "Email Viewer";
        SentEmails: TestPage "Sent Emails";
        Recipient, Subject, Body : Text;
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipient := Any.Email();
        Subject := Any.UnicodeText(50);
        Body := Any.UnicodeText(1024);

        EmailMessage.Create(Recipient, Subject, Body, true);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        // Send the email
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        // Exercise
        SentEmails.Trap();
        Page.Run(Page::"Sent Emails");

        Assert.IsTrue(SentEmails.GoToRecord(SentEmail), 'The sent email record should be present on the Sent Emails page');

        // Open the Sent Email
        EmailViewer.Trap();
        SentEmails.Desc.Drilldown();

        // Verify
        Assert.IsFalse(EmailViewer.Account.Editable(), 'Account field is editable');
        Assert.AreEqual(StrSubstNo(FromDisplayNameLbl, TempAccount.Name, TempAccount."Email Address"), EmailViewer.Account.Value(), 'Account value is incorrect');

        Assert.IsFalse(EmailViewer.ToField.Editable(), 'To field is editable');
        Assert.AreEqual(Recipient, EmailViewer.ToField.Value(), 'To field value is incorrect');

        Assert.IsFalse(EmailViewer.CcField.Editable(), 'Cc field is editable');
        Assert.AreEqual('', EmailViewer.CcField.Value(), 'Cc field value is incorrect');

        Assert.IsFalse(EmailViewer.BccField.Editable(), 'Bcc field is editable');
        Assert.AreEqual('', EmailViewer.BccField.Value(), 'Bcc field value is incorrect');

        Assert.IsFalse(EmailViewer.SubjectField.Editable(), 'Subject field is editable');
        Assert.AreEqual(Subject, EmailViewer.SubjectField.Value(), 'Subject field value is incorrect');

        Assert.IsFalse(EmailViewer.BodyField.Editable(), 'Body field is editable');
        Assert.AreEqual(Body, EmailViewer.BodyField.Value(), 'Body field value is incorrect');

        Assert.IsFalse(EmailViewer.Attachments.Delete.Visible(), 'Delete attachment is visible');
        Assert.IsFalse(EmailViewer.Attachments.Upload.Visible(), 'Visible attachment is visible');

        Assert.IsTrue(EmailViewer.Resend.Visible(), 'Resend action should be visible');
        Assert.IsTrue(EmailViewer.Resend.Enabled(), 'Resend action should be enabled');

        // Resend the send email
        EmailViewer.Resend.Invoke();

        // Message appears (see MessageQueued handler)
    end;

    [Test]
    procedure OpenSentEmailFromAnotherUserTest()
    var
        SentEmail: Record "Sent Email";
        Any: Codeunit Any;
        SentEmails: TestPage "Sent Emails";
    begin
        // Create a sent email
        SentEmail.Init();
        SentEmail.Description := CopyStr(Any.UnicodeText(50), 1, MaxStrLen(SentEmail.Description));
        SentEmail."Date Time Sent" := CurrentDateTime();
        SentEmail."User Security Id" := CreateGuid(); // Created by another user
        SentEmail.Insert();

        // Exercise
        SentEmails.Trap();
        Page.Run(Page::"Sent Emails");

        Assert.IsTrue(SentEmails.GoToRecord(SentEmail), 'The sent email record should be present on the Sent Emails page');

        // An error appears when a user tries to open an email sent from another user
        asserterror SentEmails.Desc.Drilldown();
        Assert.ExpectedError(EmailMessageOpenPermissionErr);
    end;

    [Test]
    procedure CopyRelatedRecordsWhenEditSend()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        EmailRelatedRecord: Record "Email Related Record";
        Any: Codeunit Any;
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
        SentEmails: TestPage "Sent Emails";
        Recipients: List of [Text];
        TableId, NumberOfRelations, i : Integer;
        SystemId: Guid;
    begin
        // Initialize
        EmailRelatedRecord.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient@test.com');
        EmailMessage.Create(Recipients, 'Test subject', 'Test body', true);

        NumberOfRelations := Any.IntegerInRange(2, 5);
        TableId := Any.IntegerInRange(1, 10000);
        for i := 1 to NumberOfRelations do begin
            SystemId := Any.GuidValue();
            Email.AddRelation(EmailMessage, TableId, SystemId, Enum::"Email Relation Type"::"Primary Source");
        end;

        // Send the email
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        // Check if the email has a related record 
        EmailRelatedRecord.SetRange("Table Id", TableId);
        Assert.AreEqual(NumberOfRelations, EmailRelatedRecord.Count(), 'Not all related records were created for sent email');

        // Exercise
        SentEmails.Trap();
        Page.Run(Page::"Sent Emails");

        Assert.IsTrue(SentEmails.GoToRecord(SentEmail), 'The sent email record should be present on the Sent Emails page');

        // Open the Sent Email by Edit and Send 
        EmailEditor.Trap();
        SentEmails.EditAndSend.Invoke();

        // Send 
        EmailEditor.Send.Invoke();

        // Verify
        EmailRelatedRecord.SetRange("Table Id", TableId);
        Assert.AreEqual(2 * NumberOfRelations, EmailRelatedRecord.Count(), 'Not all related records were copied over when Edit and Send');
    end;

    [Test]
    [HandlerFunctions('MessageQueued')]
    procedure CopyRelatedRecordsWhenResend()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        EmailRelatedRecord: Record "Email Related Record";
        Any: Codeunit Any;
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        SentEmails: TestPage "Sent Emails";
        Recipients: List of [Text];
        TableId, NumberOfRelations, i : Integer;
        SystemId: Guid;
    begin
        // Initialize
        EmailRelatedRecord.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient@test.com');
        EmailMessage.Create(Recipients, 'Test subject', 'Test body', true);

        NumberOfRelations := Any.IntegerInRange(2, 5);
        TableId := Any.IntegerInRange(1, 10000);
        for i := 1 to NumberOfRelations do begin
            SystemId := Any.GuidValue();
            Email.AddRelation(EmailMessage, TableId, SystemId, Enum::"Email Relation Type"::"Primary Source");
        end;

        // Send the email
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        // Check if the email has a related record 
        EmailRelatedRecord.SetRange("Table Id", TableId);
        Assert.AreEqual(NumberOfRelations, EmailRelatedRecord.Count(), 'Not all related records were created for sent email');

        // Exercise
        SentEmails.Trap();
        Page.Run(Page::"Sent Emails");

        Assert.IsTrue(SentEmails.GoToRecord(SentEmail), 'The sent email record should be present on the Sent Emails page');

        // Open the Sent Email by Edit and Send 
        SentEmails.Resend.Invoke();

        // Verify
        EmailRelatedRecord.SetRange("Table Id", TableId);
        Assert.AreEqual(2 * NumberOfRelations, EmailRelatedRecord.Count(), 'Not all related records were copied over when resending');
    end;

    [Test]
    procedure EmailOutboxEntriesVisibilityTest()
    var
        EmailOutbox: Record "Email Outbox";
        EmailOutboxes: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
        EmailOutboxesIds: List of [BigInteger];
        i: Integer;
        iAsText: Text;
    begin
        // [Scenario] Email Outbox entries can only be opened by the user who created them

        // Create four email outbox entries
        EmailOutbox.DeleteAll();
        for i := 1 to 4 do begin
            iAsText := Format(i);
            CreateEmailOutbox('Recipient ' + iAsText, 'Subject ' + iAsText, 'Body ' + iAsText, 'Attachment Name ' + iAsText, 'Attachment Content ' + iAsText, EmailOutbox);
            EmailOutboxesIds.Add(EmailOutbox.Id);
            if (i mod 2) = 0 then begin
                EmailOutbox."User Security Id" := CreateGuid(); // some other user;
                EmailOutbox.Modify();
            end;
        end;

        Commit(); // Commit the Email Outbox entries so they can be loaded in the Email Editor later on.

        EmailOutboxes.Trap();
        Page.Run(Page::"Email Outbox");

        EmailOutboxes.GoToKey(EmailOutboxesIds.Get(2));
        Assert.AreEqual(Enum::"Email Status"::Draft.AsInteger(), EmailOutboxes.Status.AsInteger(), 'Wrong status on the email outbox');
        Assert.AreEqual('Subject 2', EmailOutboxes.Desc.Value(), 'Wrong description on the email outbox');
        Assert.AreEqual('', EmailOutboxes.Error.Value(), 'Error message field should be empty');
        asserterror EmailOutboxes.Desc.Drilldown();
        Assert.ExpectedError(EmailMessageOpenPermissionErr);

        EmailOutboxes.GoToKey(EmailOutboxesIds.Get(4));
        Assert.AreEqual(Enum::"Email Status"::Draft.AsInteger(), EmailOutboxes.Status.AsInteger(), 'Wrong status on the email outbox');
        Assert.AreEqual('Subject 4', EmailOutboxes.Desc.Value(), 'Wrong description on the email outbox');
        Assert.AreEqual('', EmailOutboxes.Error.Value(), 'Error message field should be empty');
        asserterror EmailOutboxes.Desc.Drilldown();
        Assert.ExpectedError(EmailMessageOpenPermissionErr);

        EmailOutboxes.GoToKey(EmailOutboxesIds.Get(1));
        Assert.AreEqual(Enum::"Email Status"::Draft.AsInteger(), EmailOutboxes.Status.AsInteger(), 'Wrong status on the email outbox');
        Assert.AreEqual('Subject 1', EmailOutboxes.Desc.Value(), 'Wrong description on the email outbox');
        Assert.AreEqual('', EmailOutboxes.Error.Value(), 'Error message field should be empty');

        EmailEditor.Trap();
        EmailOutboxes.Desc.Drilldown(); // opens the email editor

        Assert.AreEqual('Recipient 1', EmailEditor.ToField.Value(), 'Wrong recipient on the email outbox');
        Assert.AreEqual('Subject 1', EmailEditor.SubjectField.Value(), 'Wrong subject on email outbox in email editor');
        Assert.AreEqual('Body 1', EmailEditor.BodyField.Value(), 'Wrong body on email outbox in email editor');
        Assert.AreEqual('Attachment Name 1', EmailEditor.Attachments.FileName.Value(), 'Wrong attachment name on email outbox');

        Assert.IsTrue(EmailEditor.Next(), 'There should be next record');

        Assert.AreEqual('Recipient 3', EmailEditor.ToField.Value(), 'Wrong recipient on the email outbox');
        Assert.AreEqual('Subject 3', EmailEditor.SubjectField.Value(), 'Wrong subject on email outbox in email editor');
        Assert.AreEqual('Body 3', EmailEditor.BodyField.Value(), 'Wrong body on email outbox in email editor');
        Assert.AreEqual('Attachment Name 3', EmailEditor.Attachments.FileName.Value(), 'Wrong attachment name on email outbox');

        Assert.IsFalse(EmailEditor.Next(), 'There should not be next record');

        Assert.IsTrue(EmailEditor.Previous(), 'There should be previous record');

        Assert.AreEqual('Recipient 1', EmailEditor.ToField.Value(), 'Wrong recipient on the email outbox');
        Assert.AreEqual('Subject 1', EmailEditor.SubjectField.Value(), 'Wrong subject on email outbox in email editor');
        Assert.AreEqual('Body 1', EmailEditor.BodyField.Value(), 'Wrong body on email outbox in email editor');
        Assert.AreEqual('Attachment Name 1', EmailEditor.Attachments.FileName.Value(), 'Wrong attachment name on email outbox');

        Assert.IsFalse(EmailEditor.Previous(), 'There should not be previous record');
    end;

    local procedure CreateEmailOutbox(Recipient: Text; Subject: Text; Body: Text; AttachmentName: Text[250]; AttachmentContent: Text; var EmailOutbox: Record "Email Outbox")
    var
        EmailMessage: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Clear(EmailOutbox);
        EmailMessage.Create(Recipient, Subject, Body, false);
        EmailMessage.AddAttachment(AttachmentName, 'text/plain', Base64Convert.ToBase64(AttachmentContent));
        Email.SaveAsDraft(EmailMessage, EmailOutbox);
    end;

    [MessageHandler]
    procedure MessageQueued(Message: Text[1024])
    begin
        Assert.AreEqual(EmailWasQueuedForSendingMsg, Message, 'Wrong message when resending an email');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ChooseAccountHandler(var Page: TestPage "Email Accounts")
    begin
        Page.First();
        Page.OK().Invoke();
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure DiscardEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 2; // Discard email message
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure SaveAsDraftOnCloseHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;
    end;
}