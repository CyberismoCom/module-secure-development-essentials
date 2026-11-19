%* Assertion tests for the review rules of threat models and technology
assessments (secdeva/calculations/threatModel and secdeva/calculations/technology)

Run from the project root:

    cyberismo calc run tests/document-review.lp

The tests pass when "results" is empty. Each result is one failed assertion.
The fixtures are under "Test content" > "Document review tests". A fixture
"secdeva_test_tm_X" is a threat model, and "secdeva_test_tech_X" is a
technology assessment. The fixtures use fixed dates and a review period of
36500 days, so that the results do not change over time.
*%

% Policy checks: secdeva_test_expectPolicy(Identifier, Title).
% A fixture must have each expected policy check, and no other one.
% Without a review task, only "Review task missing" fails. "Review has expired"
% and "Failing policy checks in all review tasks" need a review task.
secdeva_test_expectPolicy("secdeva_test_tm_approved_no_reviews", "Review task missing").
secdeva_test_expectPolicy("secdeva_test_tech_approved_no_reviews", "Review task missing").
% With only open reviews, "Review has expired" does not fail.
secdeva_test_expectPolicy("secdeva_test_tm_open_review", "The review subtasks of approved documents must be closed").
secdeva_test_expectPolicy("secdeva_test_tech_open_review", "The review subtasks of approved documents must be closed").
secdeva_test_expectPolicy("secdeva_test_tm_review_expired", "Review has expired").

% Fixtures without policy checks: secdeva_test_expectNoPolicy(Identifier).
secdeva_test_expectNoPolicy("secdeva_test_tm_no_reviews").
secdeva_test_expectNoPolicy("secdeva_test_tm_ready").
secdeva_test_expectNoPolicy("secdeva_test_tm_current").
secdeva_test_expectNoPolicy("secdeva_test_tech_no_reviews").
secdeva_test_expectNoPolicy("secdeva_test_tech_ready").
secdeva_test_expectNoPolicy("secdeva_test_tech_current").

% Denied transitions: secdeva_test_expectDenied(Identifier, Transition, Message),
% secdeva_test_expectNotDenied(Identifier, Transition, Message), and
% secdeva_test_expectAllowed(Identifier, Transition).
% A document without review tasks cannot be approved, and the message says why.
secdeva_test_expectDenied("secdeva_test_tm_no_reviews", "Approve", "Add a review task before approving").
secdeva_test_expectNotDenied("secdeva_test_tm_no_reviews", "Approve", "Fix policy failures in at least one of the review subtask(s) before approving").
secdeva_test_expectDenied("secdeva_test_tech_no_reviews", "Approve", "Add a review task before approving").
secdeva_test_expectNotDenied("secdeva_test_tech_no_reviews", "Approve", "Fix policy failures in at least one of the review subtask(s) before approving").
secdeva_test_expectAllowed("secdeva_test_tm_ready", "Approve").
secdeva_test_expectAllowed("secdeva_test_tech_ready", "Approve").

% Bind the expectations to the fixture cards

secdeva_test_page(Page) :-
    projectCard(Page),
    field(Page, "title", "Document review tests").

secdeva_test_fixture(Id, Card) :-
    secdeva_test_page(Page),
    ancestor(Card, Page),
    projectCard(Card),
    field(Card, "base/fieldTypes/identifier", Id).

secdeva_test_expected(Id) :- secdeva_test_expectPolicy(Id, _).
secdeva_test_expected(Id) :- secdeva_test_expectNoPolicy(Id).
secdeva_test_expected(Id) :- secdeva_test_expectDenied(Id, _, _).
secdeva_test_expected(Id) :- secdeva_test_expectNotDenied(Id, _, _).
secdeva_test_expected(Id) :- secdeva_test_expectAllowed(Id, _).

% Assertions

secdeva_test_failure(Id, "missing") :-
    secdeva_test_expected(Id),
    not secdeva_test_fixture(Id, _).

secdeva_test_failure(Id, @concatenate("policy check missing: ", Title)) :-
    secdeva_test_expectPolicy(Id, Title),
    secdeva_test_fixture(Id, Card),
    not base_policyCheckFailure(Card, _, Title, _).

secdeva_test_failure(Id, @concatenate("unexpected policy check: ", Title)) :-
    secdeva_test_fixture(Id, Card),
    base_policyCheckFailure(Card, _, Title, _),
    not secdeva_test_expectPolicy(Id, Title).

secdeva_test_failure(Id, @concatenate("not denied: ", Message)) :-
    secdeva_test_expectDenied(Id, Transition, Message),
    secdeva_test_fixture(Id, Card),
    not transitionDenied(Card, Transition, Message).

secdeva_test_failure(Id, @concatenate("denied: ", Message)) :-
    secdeva_test_expectNotDenied(Id, Transition, Message),
    secdeva_test_fixture(Id, Card),
    transitionDenied(Card, Transition, Message).

secdeva_test_failure(Id, @concatenate("denied: ", Message)) :-
    secdeva_test_expectAllowed(Id, Transition),
    secdeva_test_fixture(Id, Card),
    transitionDenied(Card, Transition, Message).

result((Subject, Reason)) :- secdeva_test_failure(Subject, Reason).
