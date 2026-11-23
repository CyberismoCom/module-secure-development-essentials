%* Cryptography use cases

A cryptography review has one or more use cases (secdeva/cardTypes/cryptographyUseCase)
as its children. A use case is a checklist item of the review: it has the
Result and Comment fields of base checklist items, and fields for the details
of the use case. The review shows the use cases with the report
secdeva/reports/cryptographyUseCases, where the user can edit all the fields.

base_checklistItem is defined in base/calculations/checklist for the card type
base/cardTypes/checklistItem. The rule below adds the use cases, so that the
review rules of base apply to them: "Mark as passed" is denied until each use
case has a result and the comments that are required, the review shows the
policy check failures of the use cases, and the progress of the review counts
them. This calculation also denies "Mark as passed" while a use case with the
result OK or Deviation misses its details. If base gets a way to register other card types as checklist items,
use it here.
*%

base_checklistItem(Item, Checklist) :-
    base_projectCardType(Item, "secdeva/cardTypes/cryptographyUseCase"),
    not field(Item, "workflowState", "Archived"),
    parent(Item, Checklist).

% The review shows the use cases, so they are hidden in the navigation tree,
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

% The review passes only when each use case with the result OK or Deviation
% has its details. Without this rule, the review could pass with the failures
% above, and a passed review with failures counts as failed evidence.

secdeva_cryptographyDetailsMissing(Item) :-
    secdeva_cryptographyDetailsRequired(Item),
    secdeva_cryptographyRequiredField(Field, _),
    not field(Item, Field, _).

transitionDenied(
    Review,
    "Mark as passed",
    @concatenate(
        "Fill in the details of each use case with the result OK or Deviation before passing the review: ",
        Count, " use case(s) with missing details.")
    ) :-
        base_checklistReview(Review),
        Count = #count {
            Item : base_checklistItem(Item, Review),
                   secdeva_cryptographyDetailsMissing(Item)
        },
        Count > 0.
