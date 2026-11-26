%
% Rules for calculating the Stage, the Assessment, and the Assessment explanation
% of an assessed security requirement.
%
% An assessed security requirement is a technical requirement for a product,
% solution, or service. It is in scope by default, as an assessed compliance
% requirement is. Its status is calculated from its reviews, its implementation
% work, and its verifications, not set by moving it in a workflow.
%
% The stage is the position of the requirement in its life cycle. It is decided in
% this order:
%    1. Out of scope: not applicable.
%    2. Failed policy checks: not OK.
%    3. A review asks for changes: not OK.
%    4. No review role has answered: not started.
%    5. Some review roles have answered, but not all: review in progress.
%    6. A verification is failing: not OK.
%    7. Implementation work is open: implementation in progress.
%    8. Verified: OK.
%    9. A verification is not ready: verification in progress.
%   10. The implementation work is done: to be verified.
%   11. Nothing implements or verifies the requirement, or everything that
%       verifies it is not applicable: content ready.
%
% Open implementation work comes before the verifications. A requirement is not OK
% while work that implements it is still open, even when its tests pass.
%
% The stage is the only status that a person overrides. The assessment follows
% from it through ismsa_stageAssessment, so an overridden stage moves the
% assessment, the status indicator, and everything that reads the assessment.
% "Not started" and "In progress" are the assessment values of internal controls
% and compliance requirements. "Not OK" is for failures only.
%
% ismsa_securityRequirementStage(Requirement, Stage, Explanation) pairs a stage
% with its explanation. The bodies of the rules are mutually exclusive, so that
% each requirement gets exactly one stage.
%
% Extension points for other modules:
%
%   ismsa_securityRequirementVerification(Requirement, Card)
%     Card verifies Requirement, for example a detailed requirement that refines it
%     or a test review. The assessment and the workflow state of Card count in the
%     same way as for the implementations of an assessed compliance requirement.
%     This module adds the documents and reviews linked with "evidences".
%
%   ismsa_securityRequirementImplementation(Requirement, Item)
%     Item is work that implements Requirement, for example a task or an issue in
%     an issue tracker. This module adds the cards linked with "implements".
%     ismsa_securityRequirementImplementationDone(Requirement, Item) says that the
%     work is finished, and Item is open until then.
%
%   ismsa_implementationWork(Scope, Identifier, Item, State)
%     Implementation work from a connector, keyed by the scope and the identifier
%     of the requirement. See "Scope" below. State is "open" or "done". Item is the key of the external item,
%     for example ("cyberismo-jira", "ISSUE-123"), so that a report can show its
%     title and its link. A connector that cannot tell whether the work is finished
%     emits nothing: a commit alone does not say that a requirement is implemented.
%
%   ismsa_testEvidence(Scope, Identifier, Run, Result, Date, Version)
%     A test result, for example from a connector that reads the test runs of CI.
%     Scope and Identifier say which requirement the result is for. See "Scope"
%     below. Result is "passed" or "failed". Only the results of the latest Date
%     of a requirement count.
%
%     These rules compare Date as a string. They do not parse it. Date therefore
%     has a strict format, and all the facts for one requirement must use the
%     same one:
%
%       - a date, "YYYY-MM-DD", for example "2026-11-20", or
%       - a time in UTC to the second, "YYYY-MM-DDThh:mm:ssZ", for example
%         "2026-11-20T11:00:00Z".
%
%     A local offset such as "+02:00" and fractional seconds such as ".500" are
%     not allowed, and neither is a mixture of the two formats. Such values sort
%     in the wrong order, and an older passing result then hides a newer failing
%     one. Convert the timestamps in the connector.
%
% Scope
%
%   An identifier does not name one card. Each product, solution, or service can
%   have its own copy of the same requirement, with the same identifier. Scope is
%   the card key of the requirement, or of a card above it in the card tree, for
%   example the project of one product. It is a constant such as ismsa_abc123, as
%   in all other facts, and not a string. A fact applies to the requirements that
%   have the identifier and that are the scope card or are below it. Work and
%   test results of one product then do not count for the same requirement of
%   another product.
%

ismsa_securityRequirement(Requirement) :-
  base_projectCardType(Requirement, "ismsa/cardTypes/assessedSecurityRequirement").

ismsa_securityRequirementInScope(Requirement) :-
  ismsa_securityRequirement(Requirement),
  field(Requirement, "workflowState", "In scope").

ismsa_securityRequirementOutOfScope(Requirement) :-
  ismsa_securityRequirement(Requirement),
  field(Requirement, "workflowState", "Out of scope").

%
% The scope of connector facts: the requirement itself and the cards above it
%

ismsa_securityRequirementUnder(Requirement, Requirement) :-
  ismsa_securityRequirement(Requirement).

ismsa_securityRequirementUnder(Requirement, Scope) :-
  ismsa_securityRequirement(Requirement),
  ancestor(Requirement, Scope).

%
% Reviews: one result field for each review role
%

% ismsa_securityRequirementReview(Order, Role, ResultField, ReviewerField, DateField, CommentField)
% These fields are not in the metadata of the card. The report
% ismsa/reports/securityRequirementReviews shows them as a table in the content.

ismsa_securityRequirementReview(1, "Architecture",
  "ismsa/fieldTypes/architectureReview", "ismsa/fieldTypes/architectureReviewer",
  "ismsa/fieldTypes/architectureReviewDate", "ismsa/fieldTypes/architectureReviewComment").
ismsa_securityRequirementReview(2, "Testing",
  "ismsa/fieldTypes/testReview", "ismsa/fieldTypes/testReviewer",
  "ismsa/fieldTypes/testReviewDate", "ismsa/fieldTypes/testReviewComment").
ismsa_securityRequirementReview(3, "Security",
  "ismsa/fieldTypes/securityReview", "ismsa/fieldTypes/securityReviewer",
  "ismsa/fieldTypes/securityReviewDate", "ismsa/fieldTypes/securityReviewComment").
ismsa_securityRequirementReview(4, "Product owner",
  "ismsa/fieldTypes/productOwnerReview", "ismsa/fieldTypes/productOwnerReviewer",
  "ismsa/fieldTypes/productOwnerReviewDate", "ismsa/fieldTypes/productOwnerReviewComment").

ismsa_securityRequirementReviewField(Field) :-
  ismsa_securityRequirementReview(_, _, Field, _, _, _).

ismsa_securityRequirementReviewDone(Requirement, Field) :-
  ismsa_securityRequirement(Requirement),
  ismsa_securityRequirementReviewField(Field),
  field(Requirement, Field, Result),
  Result != "open".

ismsa_securityRequirementReviewOpen(Requirement) :-
  ismsa_securityRequirement(Requirement),
  ismsa_securityRequirementReviewField(Field),
  not ismsa_securityRequirementReviewDone(Requirement, Field).

% A requirement that at least one review role has answered is under review, even
% when the other roles have not answered yet.

ismsa_securityRequirementReviewStarted(Requirement) :-
  ismsa_securityRequirementReviewDone(Requirement, _).

ismsa_securityRequirementReviewChangesNeeded(Requirement) :-
  ismsa_securityRequirement(Requirement),
  ismsa_securityRequirementReviewField(Field),
  field(Requirement, Field, "deviation").

%
% Implementation work: the cards and the external items that implement the
% requirement
%
% A security requirement that is linked to another one with "implements" is not
% implementation work, and these rules ignore the link. A detailed requirement
% verifies a general one instead. The module that has the detailed requirements
% says so with ismsa_securityRequirementVerification, see above.

ismsa_securityRequirementImplementation(Requirement, Card) :-
  ismsa_securityRequirement(Requirement),
  link(Card, Requirement, "ismsa/linkTypes/implements"),
  not ismsa_securityRequirement(Card).

ismsa_securityRequirementImplementationDone(Requirement, Card) :-
  ismsa_securityRequirementImplementation(Requirement, Card),
  field(Card, "base/fieldTypes/assessment", "ok").

ismsa_securityRequirementImplementationDone(Requirement, Card) :-
  ismsa_securityRequirementImplementation(Requirement, Card),
  not field(Card, "base/fieldTypes/assessment", _),
  field(Card, "workflowStateCategory", "closed").

ismsa_securityRequirementImplementationExcluded(Requirement, Card) :-
  ismsa_securityRequirementImplementation(Requirement, Card),
  field(Card, "base/fieldTypes/assessment", "notApplicable").

ismsa_securityRequirementImplementation(Requirement, Item) :-
  ismsa_securityRequirementUnder(Requirement, Scope),
  field(Requirement, "base/fieldTypes/identifier", Identifier),
  ismsa_implementationWork(Scope, Identifier, Item, _).

ismsa_securityRequirementImplementationDone(Requirement, Item) :-
  ismsa_securityRequirementUnder(Requirement, Scope),
  field(Requirement, "base/fieldTypes/identifier", Identifier),
  ismsa_implementationWork(Scope, Identifier, Item, "done").

ismsa_securityRequirementImplementationOpen(Requirement, Item) :-
  ismsa_securityRequirementImplementation(Requirement, Item),
  not ismsa_securityRequirementImplementationDone(Requirement, Item),
  not ismsa_securityRequirementImplementationExcluded(Requirement, Item).

%
% Verifications: cards that verify the requirement
%

ismsa_securityRequirementVerification(Requirement, Card) :-
  ismsa_securityRequirement(Requirement),
  link(Card, Requirement, "ismsa/linkTypes/evidences").

ismsa_securityRequirementVerificationComplete(Requirement, Card) :-
  ismsa_securityRequirementVerification(Requirement, Card),
  field(Card, "base/fieldTypes/assessment", "ok").

ismsa_securityRequirementVerificationComplete(Requirement, Card) :-
  ismsa_securityRequirementVerification(Requirement, Card),
  not field(Card, "base/fieldTypes/assessment", _),
  field(Card, "workflowStateCategory", "closed").

ismsa_securityRequirementVerificationExcluded(Requirement, Card) :-
  ismsa_securityRequirementVerification(Requirement, Card),
  field(Card, "base/fieldTypes/assessment", "notApplicable").

ismsa_securityRequirementVerificationFailing(Requirement, Card) :-
  ismsa_securityRequirementVerification(Requirement, Card),
  field(Card, "base/fieldTypes/assessment", "notOk").

ismsa_securityRequirementVerificationFailing(Requirement, Card) :-
  ismsa_securityRequirementVerification(Requirement, Card),
  base_policyCheckFailure(Card, _, _, _).

ismsa_securityRequirementVerificationPending(Requirement, Card) :-
  ismsa_securityRequirementVerification(Requirement, Card),
  not ismsa_securityRequirementVerificationComplete(Requirement, Card),
  not ismsa_securityRequirementVerificationExcluded(Requirement, Card),
  not ismsa_securityRequirementVerificationFailing(Requirement, Card).

%
% Test evidence keyed by the scope and the identifier of the requirement
%

ismsa_securityRequirementTest(Requirement, Result, Date) :-
  ismsa_securityRequirementUnder(Requirement, Scope),
  field(Requirement, "base/fieldTypes/identifier", Identifier),
  ismsa_testEvidence(Scope, Identifier, _, Result, Date, _).

ismsa_securityRequirementTestLater(Requirement, Date) :-
  ismsa_securityRequirementTest(Requirement, _, Date),
  ismsa_securityRequirementTest(Requirement, _, LaterDate),
  LaterDate > Date.

ismsa_securityRequirementLatestTest(Requirement, Result) :-
  ismsa_securityRequirementTest(Requirement, Result, Date),
  not ismsa_securityRequirementTestLater(Requirement, Date).

ismsa_securityRequirementTestFailing(Requirement) :-
  ismsa_securityRequirementLatestTest(Requirement, "failed").

ismsa_securityRequirementTestPassing(Requirement) :-
  ismsa_securityRequirementLatestTest(Requirement, "passed"),
  not ismsa_securityRequirementTestFailing(Requirement).

%
% Summary predicates
%

ismsa_securityRequirementFailing(Requirement) :-
  ismsa_securityRequirementVerificationFailing(Requirement, _).

ismsa_securityRequirementFailing(Requirement) :-
  ismsa_securityRequirementTestFailing(Requirement).

ismsa_securityRequirementVerified(Requirement) :-
  ismsa_securityRequirementVerificationComplete(Requirement, _).

ismsa_securityRequirementVerified(Requirement) :-
  ismsa_securityRequirementTestPassing(Requirement).

ismsa_securityRequirementHasVerification(Requirement) :-
  ismsa_securityRequirementVerification(Requirement, _).

ismsa_securityRequirementHasVerification(Requirement) :-
  ismsa_securityRequirementLatestTest(Requirement, _).

ismsa_securityRequirementHasImplementation(Requirement) :-
  ismsa_securityRequirementImplementation(Requirement, Item),
  not ismsa_securityRequirementImplementationExcluded(Requirement, Item).

ismsa_securityRequirementImplementationPending(Requirement) :-
  ismsa_securityRequirementImplementationOpen(Requirement, _).

% The requirement is in scope, has no policy check failures, and its reviews are
% done without requests for changes. Only then do the implementation work and the
% verifications decide.

ismsa_securityRequirementReviewed(Requirement) :-
  ismsa_securityRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  not ismsa_securityRequirementReviewChangesNeeded(Requirement),
  not ismsa_securityRequirementReviewOpen(Requirement).

%
% The stage
%

ismsa_securityRequirementStage(Requirement, "notApplicable", "The requirement has been marked out of scope") :-
  ismsa_securityRequirementOutOfScope(Requirement).

ismsa_securityRequirementStage(Requirement, "notOk", "The requirement has failed policy checks") :-
  ismsa_securityRequirementInScope(Requirement),
  base_policyCheckFailure(Requirement, _, _, _).

ismsa_securityRequirementStage(Requirement, "notOk", "A review of the requirement asks for changes") :-
  ismsa_securityRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  ismsa_securityRequirementReviewChangesNeeded(Requirement).

ismsa_securityRequirementStage(Requirement, "notStarted", "The requirement is in scope, but no review role has answered yet") :-
  ismsa_securityRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  not ismsa_securityRequirementReviewChangesNeeded(Requirement),
  ismsa_securityRequirementReviewOpen(Requirement),
  not ismsa_securityRequirementReviewStarted(Requirement).

ismsa_securityRequirementStage(Requirement, "reviewInProgress", "The requirement is under review, but the review roles have not all answered yet") :-
  ismsa_securityRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  not ismsa_securityRequirementReviewChangesNeeded(Requirement),
  ismsa_securityRequirementReviewOpen(Requirement),
  ismsa_securityRequirementReviewStarted(Requirement).

ismsa_securityRequirementStage(Requirement, "notOk", "The requirement has been reviewed, but a verification is failing") :-
  ismsa_securityRequirementReviewed(Requirement),
  ismsa_securityRequirementFailing(Requirement).

ismsa_securityRequirementStage(Requirement, "implementationInProgress", "The requirement has been reviewed, and the implementation work is under way") :-
  ismsa_securityRequirementReviewed(Requirement),
  not ismsa_securityRequirementFailing(Requirement),
  ismsa_securityRequirementImplementationPending(Requirement).

ismsa_securityRequirementStage(Requirement, "ok", "The requirement has been reviewed and verified") :-
  ismsa_securityRequirementReviewed(Requirement),
  not ismsa_securityRequirementFailing(Requirement),
  not ismsa_securityRequirementImplementationPending(Requirement),
  not ismsa_securityRequirementVerificationPending(Requirement, _),
  ismsa_securityRequirementVerified(Requirement).

ismsa_securityRequirementStage(Requirement, "verificationInProgress", "The requirement has been reviewed, but a verification is not ready yet") :-
  ismsa_securityRequirementReviewed(Requirement),
  not ismsa_securityRequirementFailing(Requirement),
  not ismsa_securityRequirementImplementationPending(Requirement),
  ismsa_securityRequirementVerificationPending(Requirement, _).

ismsa_securityRequirementStage(Requirement, "toBeVerified", "The implementation work is done, but nothing verifies the requirement yet") :-
  ismsa_securityRequirementReviewed(Requirement),
  not ismsa_securityRequirementFailing(Requirement),
  not ismsa_securityRequirementVerificationPending(Requirement, _),
  not ismsa_securityRequirementVerified(Requirement),
  ismsa_securityRequirementHasImplementation(Requirement),
  not ismsa_securityRequirementImplementationPending(Requirement).

ismsa_securityRequirementStage(Requirement, "contentReady", "The requirement has been reviewed, but everything that verifies it is not applicable") :-
  ismsa_securityRequirementReviewed(Requirement),
  not ismsa_securityRequirementFailing(Requirement),
  not ismsa_securityRequirementVerificationPending(Requirement, _),
  not ismsa_securityRequirementVerified(Requirement),
  not ismsa_securityRequirementHasImplementation(Requirement),
  ismsa_securityRequirementHasVerification(Requirement).

ismsa_securityRequirementStage(Requirement, "contentReady", "The requirement has been reviewed, but nothing implements or verifies it yet") :-
  ismsa_securityRequirementReviewed(Requirement),
  not ismsa_securityRequirementFailing(Requirement),
  not ismsa_securityRequirementVerificationPending(Requirement, _),
  not ismsa_securityRequirementVerified(Requirement),
  not ismsa_securityRequirementHasImplementation(Requirement),
  not ismsa_securityRequirementHasVerification(Requirement).

%
% The assessment follows from the stage
%

ismsa_stageAssessment("notStarted", "notStarted").
ismsa_stageAssessment("reviewInProgress", "inProgress").
ismsa_stageAssessment("contentReady", "inProgress").
ismsa_stageAssessment("implementationInProgress", "inProgress").
ismsa_stageAssessment("toBeVerified", "inProgress").
ismsa_stageAssessment("verificationInProgress", "inProgress").
ismsa_stageAssessment("ok", "ok").
ismsa_stageAssessment("notOk", "notOk").
ismsa_stageAssessment("notApplicable", "notApplicable").

%
% The calculated fields
%

fieldCalculated(Requirement, "ismsa/fieldTypes/securityRequirementStage", Stage) :-
  ismsa_securityRequirementStage(Requirement, Stage, _).

% The body reads the field and not the calculated value, so that an overridden
% stage moves the assessment with it.

fieldCalculated(Requirement, "base/fieldTypes/assessment", Assessment) :-
  ismsa_securityRequirement(Requirement),
  field(Requirement, "ismsa/fieldTypes/securityRequirementStage", Stage),
  ismsa_stageAssessment(Stage, Assessment).

% An overridden stage has no calculated explanation. Overriding is how a team
% without a connector tracks the stage by hand, and how a requirement that was
% verified before these rules existed is attested. The policy check below asks for
% the explanation. On this card type the field is displayed as "Stage explanation",
% because it explains the stage, and the assessment follows from the stage.

fieldCalculated(Requirement, "base/fieldTypes/assessmentExplanation", Explanation) :-
  ismsa_securityRequirementStage(Requirement, _, Explanation),
  not fieldOverride(Requirement, "ismsa/fieldTypes/securityRequirementStage", _).

policyCheckSuccess(Requirement, "Security requirement assessment", @concatenate("Requirement is acceptable: ", Explanation)) :-
  ismsa_securityRequirement(Requirement),
  field(Requirement, "base/fieldTypes/assessment", "ok"),
  field(Requirement, "base/fieldTypes/assessmentExplanation", Explanation).

policyCheckSuccess(Requirement, "Security requirement assessment", @concatenate("Requirement is acceptable: ", Explanation)) :-
  ismsa_securityRequirement(Requirement),
  field(Requirement, "base/fieldTypes/assessment", "notApplicable"),
  field(Requirement, "base/fieldTypes/assessmentExplanation", Explanation).

% An overridden stage hides what the rules calculate, so the reader is told what
% the rules say. An override without an explanation fails the policy check below
% instead, and that failure is itself what the rules would calculate, so the
% notification waits until the person has explained the override.

notification(
  Requirement,
  "Security requirement",
  "The stage has been overridden",
  @concatenate("The rules calculate a different stage. ", Explanation)
) :-
  ismsa_securityRequirement(Requirement),
  fieldOverride(Requirement, "ismsa/fieldTypes/securityRequirementStage", Override),
  fieldOverride(Requirement, "base/fieldTypes/assessmentExplanation", _),
  ismsa_securityRequirementStage(Requirement, Calculated, Explanation),
  Calculated != Override.

%
% The record of a review: who reviewed, when, and a comment
%
% A review that has a result needs a reviewer and a date. "Changes needed" and
% "Not applicable" also need a comment, as the checklist of base does.

ismsa_securityRequirementReviewAnswered(Requirement, Order, Result) :-
  ismsa_securityRequirementInScope(Requirement),
  ismsa_securityRequirementReview(Order, _, ResultField, _, _, _),
  field(Requirement, ResultField, Result),
  Result != "open".

policyCheckFailure(
  Requirement,
  "Security requirement",
  "Reviewer missing",
  @concatenate("The review has a result, but no reviewer. Role: ", Role),
  ReviewerField
) :-
  ismsa_securityRequirementReviewAnswered(Requirement, Order, _),
  ismsa_securityRequirementReview(Order, Role, _, ReviewerField, _, _),
  not field(Requirement, ReviewerField, _).

policyCheckFailure(
  Requirement,
  "Security requirement",
  "Review date missing",
  @concatenate("The review has a result, but no date. Role: ", Role),
  DateField
) :-
  ismsa_securityRequirementReviewAnswered(Requirement, Order, _),
  ismsa_securityRequirementReview(Order, Role, _, _, DateField, _),
  not field(Requirement, DateField, _).

policyCheckFailure(
  Requirement,
  "Security requirement",
  "Review comment missing",
  @concatenate("A review that asks for changes or is not applicable needs a comment. Role: ", Role),
  CommentField
) :-
  ismsa_securityRequirementReviewAnswered(Requirement, Order, Result),
  Result = ("deviation"; "notApplicable"),
  ismsa_securityRequirementReview(Order, Role, _, _, _, CommentField),
  not field(Requirement, CommentField, _).

% "Reopen reviews" starts a new review round, for example after the text of the
% requirement has changed. It sets each result back to "Not reviewed". The
% reviewers, dates, and comments of the earlier round stay until the reviewers
% answer again.

onTransitionSetField(Requirement, "Reopen reviews", Requirement, ResultField, "open") :-
  ismsa_securityRequirement(Requirement),
  ismsa_securityRequirementReviewField(ResultField).

%
% A justification is required to mark the requirement out of scope
%

transitionDenied(
  Requirement,
  "Mark out of scope",
  "To mark this requirement as out of scope, you must first provide a justification. Fill in the scoping justification field."
) :-
  ismsa_securityRequirement(Requirement),
  not field(Requirement, "base/fieldTypes/justification", _).

policyCheckFailure(
  Requirement,
  "Security requirement",
  "Justification missing",
  "A scoping justification is mandatory for requirements that have been marked out of scope. Set this field",
  "base/fieldTypes/justification"
) :-
  ismsa_securityRequirementOutOfScope(Requirement),
  not field(Requirement, "base/fieldTypes/justification", _).

policyCheckFailure(
  Requirement,
  "Security requirement",
  "Explanation not given for overridden stage",
  "The stage field has been overridden, but the stage explanation has not been updated. Explain the stage by overriding the stage explanation field.",
  "base/fieldTypes/assessmentExplanation"
) :-
  ismsa_securityRequirement(Requirement),
  fieldOverride(Requirement, "ismsa/fieldTypes/securityRequirementStage", _),
  not fieldOverride(Requirement, "base/fieldTypes/assessmentExplanation", _).
