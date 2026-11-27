%* Cryptography use cases

The document about the use of cryptography (secdeva/templates/useOfCryptography,
card type base/cardTypes/controlledDocument) has one or more use cases
(secdeva/cardTypes/cryptographyUseCase) as its children. A use case is a
checklist item of the document: it has the Result and Comment fields of base
checklist items, and fields for the details of the use case. The document shows
the use cases with the report secdeva/reports/cryptographyUseCases, where the
user can edit all the fields.

base_checklistItem is defined in base/calculations/checklist for the card type
base/cardTypes/checklistItem. The rule below adds the use cases, so that the
checklist predicates of base apply to them. If base gets a way to register
other card types as checklist items, use it here.

The review rules of base apply only to reviews. For the document, this
calculation:
- denies "Approve" until each use case has a result, the required comments,
  and its details,
- shows the policy check failures of the use cases on the document, because
  the use cases are hidden in the navigation tree,
- shows a policy check failure if an approved document has use cases that are
  not complete.
*%

base_checklistItem(Item, Checklist) :-
    base_projectCardType(Item, "secdeva/cardTypes/cryptographyUseCase"),
    not field(Item, "workflowState", "Archived"),
    parent(Item, Checklist).

% The document shows the use cases, so they are hidden in the navigation tree,
% like the other checklist items.
hiddenInTreeView(Item) :-
    base_projectCardType(Item, "secdeva/cardTypes/cryptographyUseCase").

% A use case that has the result OK or Deviation needs its details. A use case
% that is Not applicable or Open does not.

secdeva_cryptographyRequiredField("secdeva/fieldTypes/cryptographyUseCase", "Use case").
secdeva_cryptographyRequiredField("secdeva/fieldTypes/cryptographyUsagePeriod", "Expected usage period").
secdeva_cryptographyRequiredField("secdeva/fieldTypes/cryptographyAlgorithms", "Algorithms").
secdeva_cryptographyRequiredField("secdeva/fieldTypes/cryptographyKeyLength", "Key length").
secdeva_cryptographyRequiredField("secdeva/fieldTypes/cryptographyKeyManagement", "Key management").

secdeva_cryptographyDetailsRequired(Item) :-
    base_projectCardType(Item, "secdeva/cardTypes/cryptographyUseCase"),
    field(Item, "base/fieldTypes/checklistResult", "ok").

secdeva_cryptographyDetailsRequired(Item) :-
    base_projectCardType(Item, "secdeva/cardTypes/cryptographyUseCase"),
    field(Item, "base/fieldTypes/checklistResult", "deviation").

policyCheckFailure(
    Item,
    "Cryptography",
    @concatenate(Name, " is a required field"),
    @concatenate("A use case with the result OK or Deviation needs its details. Fill in the field ", Name, "."),
    Field
    ) :-
        secdeva_cryptographyDetailsRequired(Item),
        secdeva_cryptographyRequiredField(Field, Name),
        not field(Item, Field, _).

secdeva_cryptographyDetailsMissing(Item) :-
    secdeva_cryptographyDetailsRequired(Item),
    secdeva_cryptographyRequiredField(Field, _),
    not field(Item, Field, _).

% A document with use cases. Reviews are left out: base already has rules for
% reviews with checklist items.

secdeva_cryptographyDocument(Document) :-
    base_checklistItem(Item, Document),
    base_projectCardType(Item, "secdeva/cardTypes/cryptographyUseCase"),
    not base_checklistReview(Document).

secdeva_cryptographyDetailsMissingCount(Document, Count) :-
    secdeva_cryptographyDocument(Document),
    Count = #count {
        Item : base_checklistItem(Item, Document),
               secdeva_cryptographyDetailsMissing(Item)
    }.

secdeva_cryptographyUseCasesComplete(Document) :-
    secdeva_cryptographyDocument(Document),
    base_checklistComplete(Document),
    secdeva_cryptographyDetailsMissingCount(Document, 0).

% Approve waits for complete use cases. Deviations do not block approval: the
% approver accepts them.

transitionDenied(
    Document,
    "Approve",
    @concatenate(
        "Complete the use cases before approving: ",
        Open, " open, ", Missing, " comment(s) missing, ",
        Details, " use case(s) with missing details.")
    ) :-
        secdeva_cryptographyDocument(Document),
        not secdeva_cryptographyUseCasesComplete(Document),
        base_checklistItemCount(Document, "open", Open),
        base_checklistCommentMissingCount(Document, Missing),
        secdeva_cryptographyDetailsMissingCount(Document, Details).

% The use cases are hidden, so the document shows their policy check failures.
% The message names the use case.

policyCheckFailure(
    Document,
    "Cryptography",
    Title,
    @concatenate("Use case \"", ItemTitle, "\": ", Message)
    ) :-
        secdeva_cryptographyDocument(Document),
        base_checklistItem(Item, Document),
        base_policyCheckFailure(Item, _, Title, Message),
        field(Item, "title", ItemTitle).

policyCheckFailure(
    Document,
    "Cryptography",
    "Incomplete use cases in an approved document",
    "Some use cases have no result, a Deviation or Not applicable result without a comment, or missing details. Complete the use cases, or reopen the document."
    ) :-
        secdeva_cryptographyDocument(Document),
        field(Document, "workflowState", "Approved"),
        not secdeva_cryptographyUseCasesComplete(Document).
