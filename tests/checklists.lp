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
- the cryptography use cases, which are checklist items of the cryptography
  review, and the rule that a review cannot pass while a use case misses its
  details (secdeva/calculations/cryptography).
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
% secdeva_test_expectReview(Title, Complete, Progress): whether the checklist of
% the review is complete, and the progress of the review.

secdeva_test_expectReview("CHK4 Cryptography review with an open use case", "no", 0).
secdeva_test_expectReview("CHK5 Cryptography review with a use case that is OK without details", "yes", 100).
secdeva_test_expectReview("CHK6 Cryptography review with a use case that is OK with details", "yes", 100).

secdeva_test_useCase(Review, Item) :-
    secdeva_test_expectReview(Title, _, _),
    secdeva_test_card(Title, Review),
    parent(Item, Review),
    base_projectCardType(Item, "secdeva/cardTypes/cryptographyUseCase").

secdeva_test_failure(Title, "fixture not found") :-
    secdeva_test_expectReview(Title, _, _),
    not secdeva_test_card(Title, _).

secdeva_test_failure(Title, "use case is not a checklist item of the review") :-
    secdeva_test_expectReview(Title, _, _),
    secdeva_test_card(Title, Review),
    secdeva_test_useCase(Review, Item),
    not base_checklistItem(Item, Review).

secdeva_test_failure(Title, "use case is not hidden in the tree") :-
    secdeva_test_expectReview(Title, _, _),
    secdeva_test_card(Title, Review),
    secdeva_test_useCase(Review, Item),
    not hiddenInTreeView(Item).

secdeva_test_failure(Title, "checklist is not complete") :-
    secdeva_test_expectReview(Title, "yes", _),
    secdeva_test_card(Title, Review),
    not base_checklistComplete(Review).

secdeva_test_failure(Title, "checklist is complete") :-
    secdeva_test_expectReview(Title, "no", _),
    secdeva_test_card(Title, Review),
    base_checklistComplete(Review).

secdeva_test_failure(Title, "progress") :-
    secdeva_test_expectReview(Title, _, Progress),
    secdeva_test_card(Title, Review),
    not field(Review, "progress", Progress).

secdeva_test_failure(Title, "Mark as passed is not denied") :-
    secdeva_test_expectReview(Title, "no", _),
    secdeva_test_card(Title, Review),
    not transitionDenied(Review, "Mark as passed", _).

% Details of a use case with the result OK: five required fields are missing in
% CHK5, and none in CHK6. The review shows the failures of its use cases.

secdeva_test_detailFailure(Item, Title) :-
    base_policyCheckFailure(Item, "Cryptography", Title, _),
    base_projectCardType(Item, "secdeva/cardTypes/cryptographyUseCase").

secdeva_test_failure("CHK5", "expected 5 missing details on the use case") :-
    secdeva_test_card("CHK5 Cryptography review with a use case that is OK without details", Review),
    secdeva_test_useCase(Review, Item),
    not 5 #count { Title : secdeva_test_detailFailure(Item, Title) } 5.

secdeva_test_failure("CHK5", "the review does not show the failures of the use case") :-
    secdeva_test_card("CHK5 Cryptography review with a use case that is OK without details", Review),
    not base_policyCheckFailure(Review, "Checklist", "Key length is a required field", _).

% A review with a use case that misses its details cannot pass. CHK5 has the
% result OK and no details, and CHK6 has the details.

secdeva_test_detailsDenied(Review) :-
    transitionDenied(Review, "Mark as passed", Message),
    Message = @concatenate(
        "Fill in the details of each use case with the result OK or Deviation before passing the review: ",
        1, " use case(s) with missing details.").

secdeva_test_failure("CHK5", "Mark as passed is not denied for the missing details") :-
    secdeva_test_card("CHK5 Cryptography review with a use case that is OK without details", Review),
    not secdeva_test_detailsDenied(Review).

secdeva_test_failure("CHK6", "Mark as passed is denied") :-
    secdeva_test_card("CHK6 Cryptography review with a use case that is OK with details", Review),
    transitionDenied(Review, "Mark as passed", _).

secdeva_test_failure("CHK6", "unexpected failures on the use case") :-
    secdeva_test_card("CHK6 Cryptography review with a use case that is OK with details", Review),
    secdeva_test_useCase(Review, Item),
    base_policyCheckFailure(Item, _, _, _).

% Results

result((Subject, Reason)) :- secdeva_test_failure(Subject, Reason).
