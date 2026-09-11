%
% Rules for calculating the Assessment and the Assessment explanation of an
% assessed compliance requirement.
%
% Unlike an internal control, an assessed compliance requirement is in scope by
% default: the compliance scoping workflow starts in the "In scope" state, so a
% compliance score can be calculated as soon as the requirements have been created.
% Marking a requirement out of scope is the exception, and it requires a justification.
%
% ismsa_assessedRequirementAssessment(Requirement, Assessment, Explanation) pairs an
% assessment value with the explanation that belongs to it, so that the two can never
% drift apart. The bodies of these rules are mutually exclusive, so that each
% requirement gets exactly one assessment. The two fields are derived from this
% predicate at the end of this section.
%

ismsa_assessedRequirement(Requirement) :-
  base_projectCardType(Requirement, "ismsa/cardTypes/assessedComplianceRequirement").

ismsa_assessedRequirementInScope(Requirement) :-
  ismsa_assessedRequirement(Requirement),
  field(Requirement, "workflowState", "In scope").

ismsa_assessedRequirementOutOfScope(Requirement) :-
  ismsa_assessedRequirement(Requirement),
  field(Requirement, "workflowState", "Out of scope").

%
% The cards that a requirement is assessed against: the cards that implement it and
% the evidence that has been linked to it directly.
%

ismsa_requirementImplementation(Requirement, Card) :-
  ismsa_assessedRequirement(Requirement),
  link(Card, Requirement, "ismsa/linkTypes/implements").

ismsa_requirementImplementation(Requirement, Card) :-
  ismsa_assessedRequirement(Requirement),
  link(Card, Requirement, "ismsa/linkTypes/evidences").

% An implementation is complete when it has been assessed as OK. Cards that do not
% carry an assessment of their own, such as tasks, are complete when they are closed.

ismsa_requirementImplementationComplete(Requirement, Card) :-
  ismsa_requirementImplementation(Requirement, Card),
  field(Card, "base/fieldTypes/assessment", "ok").

ismsa_requirementImplementationComplete(Requirement, Card) :-
  ismsa_requirementImplementation(Requirement, Card),
  not field(Card, "base/fieldTypes/assessment", _),
  field(Card, "workflowStateCategory", "closed").

% An implementation is excluded when it has been assessed as not applicable. An excluded
% implementation neither raises nor lowers the assessment of the requirement.

ismsa_requirementImplementationExcluded(Requirement, Card) :-
  ismsa_requirementImplementation(Requirement, Card),
  field(Card, "base/fieldTypes/assessment", "notApplicable").

% An implementation is failing when it has been assessed as not OK, or when it has
% policy check failures of its own.

ismsa_requirementImplementationFailing(Requirement, Card) :-
  ismsa_requirementImplementation(Requirement, Card),
  field(Card, "base/fieldTypes/assessment", "notOk").

ismsa_requirementImplementationFailing(Requirement, Card) :-
  ismsa_requirementImplementation(Requirement, Card),
  base_policyCheckFailure(Card, _, _, _).

% Everything else is still pending: the work has been linked but it is not ready yet.

ismsa_requirementImplementationPending(Requirement, Card) :-
  ismsa_requirementImplementation(Requirement, Card),
  not ismsa_requirementImplementationComplete(Requirement, Card),
  not ismsa_requirementImplementationExcluded(Requirement, Card),
  not ismsa_requirementImplementationFailing(Requirement, Card).

% Not applicable, because the requirement has been marked out of scope

ismsa_assessedRequirementAssessment(Requirement, "notApplicable", "The requirement has been marked out of scope") :-
  ismsa_assessedRequirementOutOfScope(Requirement).

% Not OK, because the requirement itself has failed policy checks

ismsa_assessedRequirementAssessment(Requirement, "notOk", "The requirement has failed policy checks") :-
  ismsa_assessedRequirementInScope(Requirement),
  base_policyCheckFailure(Requirement, _, _, _).

% Not OK, because something that implements the requirement is failing

ismsa_assessedRequirementAssessment(Requirement, "notOk", "The requirement is in scope but the linked implementation is not acceptable") :-
  ismsa_assessedRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  ismsa_requirementImplementationFailing(Requirement, _).

% Open, because nothing has been linked to the requirement yet

ismsa_assessedRequirementAssessment(Requirement, "open", "The requirement is in scope but nothing has been linked to implement it") :-
  ismsa_assessedRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  not ismsa_requirementImplementation(Requirement, _).

% Open, because the linked implementation is still in progress

ismsa_assessedRequirementAssessment(Requirement, "open", "The requirement is in scope but the linked implementation is not ready") :-
  ismsa_assessedRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  not ismsa_requirementImplementationFailing(Requirement, _),
  ismsa_requirementImplementationPending(Requirement, _).

% Open, because everything that was linked to the requirement is out of scope itself

ismsa_assessedRequirementAssessment(Requirement, "open", "The requirement is in scope but everything that was linked to it is out of scope") :-
  ismsa_assessedRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  not ismsa_requirementImplementationFailing(Requirement, _),
  not ismsa_requirementImplementationPending(Requirement, _),
  not ismsa_requirementImplementationComplete(Requirement, _),
  ismsa_requirementImplementation(Requirement, _).

% OK, because the requirement is in scope and everything that implements it is ready

ismsa_assessedRequirementAssessment(Requirement, "ok", "The requirement is in scope and the linked implementation is acceptable") :-
  ismsa_assessedRequirementInScope(Requirement),
  not base_policyCheckFailure(Requirement, _, _, _),
  not ismsa_requirementImplementationFailing(Requirement, _),
  not ismsa_requirementImplementationPending(Requirement, _),
  ismsa_requirementImplementationComplete(Requirement, _).

%
% The calculated fields
%

fieldCalculated(Requirement, "base/fieldTypes/assessment", Assessment) :-
  ismsa_assessedRequirementAssessment(Requirement, Assessment, _).

% The calculated explanation explains the calculated assessment. Once the assessment has
% been overridden, no calculated explanation applies: explaining an overridden assessment
% is the author's job, and the policy check below asks for it. This matters here because
% overriding the assessment is how a requirement that cannot be evidenced automatically
% is attested manually. Without this condition the card would show the overridden
% assessment next to an explanation of a different one.

fieldCalculated(Requirement, "base/fieldTypes/assessmentExplanation", Explanation) :-
  ismsa_assessedRequirementAssessment(Requirement, _, Explanation),
  not fieldOverride(Requirement, "base/fieldTypes/assessment", _).

policyCheckSuccess(Requirement, "Compliance requirement assessment", @concatenate("Requirement is acceptable: ", Explanation)) :-
  ismsa_assessedRequirement(Requirement),
  field(Requirement, "base/fieldTypes/assessment", "ok"),
  field(Requirement, "base/fieldTypes/assessmentExplanation", Explanation).

policyCheckSuccess(Requirement, "Compliance requirement assessment", @concatenate("Requirement is acceptable: ", Explanation)) :-
  ismsa_assessedRequirement(Requirement),
  field(Requirement, "base/fieldTypes/assessment", "notApplicable"),
  field(Requirement, "base/fieldTypes/assessmentExplanation", Explanation).

%
% Justification is required if the requirement is out of scope
%

transitionDenied(
  Requirement,
  "Mark out of scope",
  "To mark this requirement as out of scope, you must first provide a justification. Fill in the scoping justification field."
) :-
    ismsa_assessedRequirement(Requirement),
    not field(Requirement, "base/fieldTypes/justification", _).

policyCheckFailure(
  Requirement,
  "Compliance requirement",
  "Justification missing",
  "A scoping justification is mandatory for requirements that have been marked out of scope. Set this field",
  "base/fieldTypes/justification"
) :-
    ismsa_assessedRequirementOutOfScope(Requirement),
    not field(Requirement, "base/fieldTypes/justification", _).

%
% Policy check: Assessment has been overridden but the explanation has not been updated
%
% Overriding the assessment is how a requirement that cannot be evidenced automatically
% is attested manually, so the explanation is what makes the attestation auditable.
%

policyCheckFailure(
  Requirement,
  "Compliance requirement",
  "Assessment explanation not given for overridden assessment",
  "The assessment field has been overridden, but the assessment explanation has not been updated. Explain the assessment by overriding the assessment explanation field.",
  "base/fieldTypes/assessmentExplanation"
) :-
  ismsa_assessedRequirement(Requirement),
  fieldOverride(Requirement, "base/fieldTypes/assessment", _),
  not fieldOverride(Requirement, "base/fieldTypes/assessmentExplanation", _).
