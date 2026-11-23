%* Assertion tests for the checklists of secdeva

Run from the project root:

    cyberismo calc run tests/checklists.lp

The tests pass when "results" is empty. Each result is one failed assertion.
The fixtures are under "Test content" > "Checklist tests". The tests find them
by title.

The tests cover:
- the identifiers of the checklist items in the templates,
- the rule that a technology assessment needs an answered checklist before
  approval (secdeva/calculations/technology),
- the cryptography use cases, which are checklist items of the document about
  the use of cryptography, and the rules that deny "Approve" until the use
  cases are complete (secdeva/calculations/cryptography).
*%

secdeva_test_card(Title, Card) :-
    field(Card, "title", Title),
    projectCard(Card).

% Identifiers of the checklist items in the templates
%
% Each checklist item of a review or technology template has an identifier, and
% the identifiers of the items of one card are different.

secdeva_test_templateItem(Item, Parent) :-
    field(Item, "cardType", "base/cardTypes/checklistItem"),
    not projectCard(Item),
    parent(Item, Parent),
    field(Parent, "cardType", "base/cardTypes/review").

secdeva_test_templateItem(Item, Parent) :-
    field(Item, "cardType", "base/cardTypes/checklistItem"),
    not projectCard(Item),
    parent(Item, Parent),
    field(Parent, "cardType", "secdeva/cardTypes/technology").

secdeva_test_failure(Item, "template checklist item without an identifier") :-
    secdeva_test_templateItem(Item, _),
    not field(Item, "base/fieldTypes/identifier", _).

secdeva_test_failure(Item, "two checklist items of one card have the same identifier") :-
    secdeva_test_templateItem(Item, Parent),
    secdeva_test_templateItem(Other, Parent),
    Item != Other,
    field(Item, "base/fieldTypes/identifier", Id),
    field(Other, "base/fieldTypes/identifier", Id).

secdeva_test_failure("templates", "no template checklist items found") :-
    not secdeva_test_templateItem(_, _).

% Technology assessments
%
% secdeva_test_expectApproveDenied(Title, Expected): whether "Approve" is denied
% because the checklist is not answered.
% secdeva_test_expectUnanswered(Title, Expected): whether the card has the
% policy check failure "Unanswered checks in an approved technology assessment".

secdeva_test_expectApproveDenied("CHK1 Technology with open checks", "yes").
secdeva_test_expectApproveDenied("CHK2 Technology with all checks answered and a deviation", "no").
secdeva_test_expectApproveDenied("CHK3 Approved technology with an open check", "yes").

secdeva_test_expectUnanswered("CHK1 Technology with open checks", "no").
secdeva_test_expectUnanswered("CHK2 Technology with all checks answered and a deviation", "no").
secdeva_test_expectUnanswered("CHK3 Approved technology with an open check", "yes").

secdeva_test_approveDenied(Card) :-
    base_projectCardType(Card, "secdeva/cardTypes/technology"),
    base_checklistItemCount(Card, "open", Open),
    base_checklistCommentMissingCount(Card, Missing),
    transitionDenied(Card, "Approve", Message),
    Message = @concatenate(
        "Answer all checks of the checklist before approving: ",
        Open, " open, ", Missing, " comment(s) missing.").

secdeva_test_unanswered(Card) :-
    base_policyCheckFailure(Card, _, "Unanswered checks in an approved technology assessment", _).

secdeva_test_failure(Title, "fixture not found") :-
    secdeva_test_expectApproveDenied(Title, _),
    not secdeva_test_card(Title, _).

secdeva_test_failure(Title, "Approve is not denied") :-
    secdeva_test_expectApproveDenied(Title, "yes"),
    secdeva_test_card(Title, Card),
    not secdeva_test_approveDenied(Card).

secdeva_test_failure(Title, "Approve is denied") :-
    secdeva_test_expectApproveDenied(Title, "no"),
    secdeva_test_card(Title, Card),
    secdeva_test_approveDenied(Card).

secdeva_test_failure(Title, "unanswered checks failure missing") :-
    secdeva_test_expectUnanswered(Title, "yes"),
    secdeva_test_card(Title, Card),
    not secdeva_test_unanswered(Card).

secdeva_test_failure(Title, "unexpected unanswered checks failure") :-
    secdeva_test_expectUnanswered(Title, "no"),
    secdeva_test_card(Title, Card),
    secdeva_test_unanswered(Card).

% Cryptography use cases
%
% The document about the use of cryptography (a controlled document) has the
% use cases as checklist items.
% secdeva_test_expectDocument(Title, Complete, ApproveDenied, ApprovedFailure):
% whether the checklist of the document is complete, whether "Approve" is
% denied, and whether the document has the failure "Incomplete use cases in an
% approved document".

secdeva_test_expectDocument("CHK4 Cryptography document with an open use case", "no", "yes", "no").
secdeva_test_expectDocument("CHK5 Cryptography document with a use case that is OK without details", "yes", "yes", "no").
secdeva_test_expectDocument("CHK6 Cryptography document with a use case that is OK with details", "yes", "no", "no").
secdeva_test_expectDocument("CHK7 Approved cryptography document with an open use case", "no", "yes", "yes").

secdeva_test_useCase(Document, Item) :-
    secdeva_test_expectDocument(Title, _, _, _),
    secdeva_test_card(Title, Document),
    parent(Item, Document),
    base_projectCardType(Item, "secdeva/cardTypes/cryptographyUseCase").

secdeva_test_useCaseApproveDenied(Document) :-
    transitionDenied(Document, "Approve", Message),
    Message = @concatenate("Complete the use cases before approving: ",
        Open, " open, ", Missing, " comment(s) missing, ",
        Details, " use case(s) with missing details."),
    base_checklistItemCount(Document, "open", Open),
    base_checklistCommentMissingCount(Document, Missing),
    secdeva_cryptographyDetailsMissingCount(Document, Details).

secdeva_test_failure(Title, "fixture not found") :-
    secdeva_test_expectDocument(Title, _, _, _),
    not secdeva_test_card(Title, _).

secdeva_test_failure(Title, "the document has no use case") :-
    secdeva_test_expectDocument(Title, _, _, _),
    secdeva_test_card(Title, Document),
    not secdeva_test_useCase(Document, _).

secdeva_test_failure(Title, "use case is not a checklist item of the document") :-
    secdeva_test_expectDocument(Title, _, _, _),
    secdeva_test_card(Title, Document),
    secdeva_test_useCase(Document, Item),
    not base_checklistItem(Item, Document).

secdeva_test_failure(Title, "use case is not hidden in the tree") :-
    secdeva_test_expectDocument(Title, _, _, _),
    secdeva_test_card(Title, Document),
    secdeva_test_useCase(Document, Item),
    not hiddenInTreeView(Item).

secdeva_test_failure(Title, "checklist is not complete") :-
    secdeva_test_expectDocument(Title, "yes", _, _),
    secdeva_test_card(Title, Document),
    not base_checklistComplete(Document).

secdeva_test_failure(Title, "checklist is complete") :-
    secdeva_test_expectDocument(Title, "no", _, _),
    secdeva_test_card(Title, Document),
    base_checklistComplete(Document).

secdeva_test_failure(Title, "Approve is not denied for the use cases") :-
    secdeva_test_expectDocument(Title, _, "yes", _),
    secdeva_test_card(Title, Document),
    not secdeva_test_useCaseApproveDenied(Document).

secdeva_test_failure(Title, "Approve is denied for the use cases") :-
    secdeva_test_expectDocument(Title, _, "no", _),
    secdeva_test_card(Title, Document),
    secdeva_test_useCaseApproveDenied(Document).

secdeva_test_failure(Title, "approved document failure missing") :-
    secdeva_test_expectDocument(Title, _, _, "yes"),
    secdeva_test_card(Title, Document),
    not base_policyCheckFailure(Document, "Cryptography", "Incomplete use cases in an approved document", _).

secdeva_test_failure(Title, "unexpected approved document failure") :-
    secdeva_test_expectDocument(Title, _, _, "no"),
    secdeva_test_card(Title, Document),
    base_policyCheckFailure(Document, "Cryptography", "Incomplete use cases in an approved document", _).

% Details of a use case with the result OK: five required fields are missing in
% CHK5, and none in CHK6. The document shows the failures of its use cases.

secdeva_test_detailFailure(Item, Title) :-
    base_policyCheckFailure(Item, "Cryptography", Title, _),
    base_projectCardType(Item, "secdeva/cardTypes/cryptographyUseCase").

secdeva_test_failure("CHK5", "expected 5 missing details on the use case") :-
    secdeva_test_card("CHK5 Cryptography document with a use case that is OK without details", Document),
    secdeva_test_useCase(Document, Item),
    not 5 #count { Title : secdeva_test_detailFailure(Item, Title) } 5.

secdeva_test_failure("CHK5", "the document does not show the failures of the use case") :-
    secdeva_test_card("CHK5 Cryptography document with a use case that is OK without details", Document),
    not base_policyCheckFailure(Document, "Cryptography", "Key length is a required field", _).

secdeva_test_failure("CHK6", "unexpected failures on the use case") :-
    secdeva_test_card("CHK6 Cryptography document with a use case that is OK with details", Document),
    secdeva_test_useCase(Document, Item),
    base_policyCheckFailure(Item, _, _, _).

% Results

result((Subject, Reason)) :- secdeva_test_failure(Subject, Reason).
