%
% Rules for calculating the Assessment and the Assessment explanation of an
% assessed security requirement.
%
% An assessed security requirement is a technical requirement for a product,
% solution, or service. It is in scope by default, as an assessed compliance
% requirement is. Its status is calculated from its reviews and its verifications,
% not set by moving it in a workflow.
%
% The assessment is decided in this order:
%   1. Out of scope: not applicable.
%   2. Failed policy checks: not OK.
%   3. A review asks for changes: not OK.
%   4. A review has not been done: open.
%   5. A verification is failing: not OK.
%   6. There is no verification yet, or a verification is not ready: open.
%   7. All verifications are OK or not applicable, and at least one is OK: OK.
%
% ismsa_securityRequirementAssessment(Requirement, Assessment, Explanation) pairs an
% assessment value with its explanation. The bodies of the rules are mutually
% exclusive, so that each requirement gets exactly one assessment.
%
% Extension points for other modules:
%
%   ismsa_securityRequirementVerification(Requirement, Card)
%     Card verifies Requirement, for example a detailed requirement that refines it
%     or a test review. The assessment and the workflow state of Card count in the
%     same way as for the implementations of an assessed compliance requirement.
%     This module adds the documents and reviews linked with "evidences".
%
%   ismsa_testEvidence(Identifier, Run, Result, Date, Version)
%     A test result, for example from a connector that reads the test runs of CI.
%     Identifier is the identifier of the requirement. Result is "passed" or
%     "failed". Date is an ISO 8601 date or time, so that later results sort after
%     earlier ones. Only the results of the latest date count.
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
% Reviews: one result field for each review role
%

ismsa_securityRequirementReviewField("ismsa/fieldTypes/architectureReview").
ismsa_securityRequirementReviewField("ismsa/fieldTypes/testReview").
ismsa_securityRequirementReviewField("ismsa/fieldTypes/securityReview").
ismsa_securityRequirementReviewField("ismsa/fieldTypes/productOwnerReview").

ismsa_securityRequirementReviewDone(Requirement, Field) :-
  ismsa_securityRequirement(Requirement),
  ismsa_securityRequirementReviewField(Field),
  field(Requirement, Field, Result),
  Result != "open".

ismsa_securityRequirementReviewOpen(Requirement) :-
  ismsa_securityRequirement(Requirement),
  ismsa_securityRequirementReviewField(Field),
  not ismsa_securityRequirementReviewDone(Requirement, Field).

ismsa_securityRequirementReviewChangesNeeded(Requirement) :-
  ismsa_securityRequirement(Requirement),
  ismsa_securityRequirementReviewField(Field),
  field(Requirement, Field, "deviation").

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
% Test evidence keyed by the identifier of the requirement
%

ismsa_testEvidenceLater(Identifier, Date) :-
  ismsa_testEvidence(Identifier, _, _, Date, _),
  ismsa_testEvidence(Identifier, _, _, LaterDate, _),
  LaterDate > Date.

ismsa_securityRequirementLatestTest(Requirement, Result) :-
  ismsa_securityRequirement(Requirement),
  field(Requirement, "base/fieldTypes/identifier", Identifier),
  ismsa_testEvidence(Identifier, _, Result, Date, _),
  not ismsa_testEvidenceLater(Identifier, Date).

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

% The requirement is in scope, has no policy check failures, and its reviews are
% done without requests for changes. Only then do the verifications decide.

ismsa_securityRequirementReviewed(Requirement) :-
  ismsa_securityRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  not ismsa_securityRequirementReviewChangesNeeded(Requirement),
  not ismsa_securityRequirementReviewOpen(Requirement).

%
% The assessment
%

ismsa_securityRequirementAssessment(Requirement, "notApplicable", "The requirement has been marked out of scope") :-
  ismsa_securityRequirementOutOfScope(Requirement).

ismsa_securityRequirementAssessment(Requirement, "notOk", "The requirement has failed policy checks") :-
  ismsa_securityRequirementInScope(Requirement),
  base_policyCheckFailure(Requirement, _, _, _).

ismsa_securityRequirementAssessment(Requirement, "notOk", "A review of the requirement asks for changes") :-
  ismsa_securityRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  ismsa_securityRequirementReviewChangesNeeded(Requirement).

ismsa_securityRequirementAssessment(Requirement, "open", "The requirement has not been reviewed by all review roles") :-
  ismsa_securityRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  not ismsa_securityRequirementReviewChangesNeeded(Requirement),
  ismsa_securityRequirementReviewOpen(Requirement).

ismsa_securityRequirementAssessment(Requirement, "notOk", "The requirement has been reviewed but a verification is failing") :-
  ismsa_securityRequirementReviewed(Requirement),
  ismsa_securityRequirementFailing(Requirement).

ismsa_securityRequirementAssessment(Requirement, "open", "The requirement has been reviewed but it has not been verified yet") :-
  ismsa_securityRequirementReviewed(Requirement),
  not ismsa_securityRequirementFailing(Requirement),
  not ismsa_securityRequirementHasVerification(Requirement).

ismsa_securityRequirementAssessment(Requirement, "open", "The requirement has been reviewed but a verification is not ready") :-
  ismsa_securityRequirementReviewed(Requirement),
  not ismsa_securityRequirementFailing(Requirement),
  ismsa_securityRequirementVerificationPending(Requirement, _).

ismsa_securityRequirementAssessment(Requirement, "open", "The requirement has been reviewed but all its verifications are out of scope") :-
  ismsa_securityRequirementReviewed(Requirement),
  not ismsa_securityRequirementFailing(Requirement),
  not ismsa_securityRequirementVerificationPending(Requirement, _),
  not ismsa_securityRequirementVerified(Requirement),
  ismsa_securityRequirementHasVerification(Requirement).

ismsa_securityRequirementAssessment(Requirement, "ok", "The requirement has been reviewed and verified") :-
  ismsa_securityRequirementReviewed(Requirement),
  not ismsa_securityRequirementFailing(Requirement),
  not ismsa_securityRequirementVerificationPending(Requirement, _),
  ismsa_securityRequirementVerified(Requirement).

%
% The calculated fields
%

fieldCalculated(Requirement, "base/fieldTypes/assessment", Assessment) :-
  ismsa_securityRequirementAssessment(Requirement, Assessment, _).

% An overridden assessment has no calculated explanation. Overriding is how a
% requirement that was verified before these rules existed is attested, and the
% author explains it. The policy check below asks for the explanation.

fieldCalculated(Requirement, "base/fieldTypes/assessmentExplanation", Explanation) :-
  ismsa_securityRequirementAssessment(Requirement, _, Explanation),
  not fieldOverride(Requirement, "base/fieldTypes/assessment", _).

policyCheckSuccess(Requirement, "Security requirement assessment", @concatenate("Requirement is acceptable: ", Explanation)) :-
  ismsa_securityRequirement(Requirement),
  field(Requirement, "base/fieldTypes/assessment", "ok"),
  field(Requirement, "base/fieldTypes/assessmentExplanation", Explanation).

policyCheckSuccess(Requirement, "Security requirement assessment", @concatenate("Requirement is acceptable: ", Explanation)) :-
  ismsa_securityRequirement(Requirement),
  field(Requirement, "base/fieldTypes/assessment", "notApplicable"),
  field(Requirement, "base/fieldTypes/assessmentExplanation", Explanation).

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
  "Assessment explanation not given for overridden assessment",
  "The assessment field has been overridden, but the assessment explanation has not been updated. Explain the assessment by overriding the assessment explanation field.",
  "base/fieldTypes/assessmentExplanation"
) :-
  ismsa_securityRequirement(Requirement),
  fieldOverride(Requirement, "base/fieldTypes/assessment", _),
  not fieldOverride(Requirement, "base/fieldTypes/assessmentExplanation", _).
