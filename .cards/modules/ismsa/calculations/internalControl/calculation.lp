%
% Rules for calculating the Assessment and Assessment explanation
%

% Open

field(Control, "base/fieldTypes/assessment", "open") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "Open").

field(Control, "base/fieldTypes/assessmentExplanation", "The control has not been scoped yet") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "Open").

% Not applicable

field(Control, "base/fieldTypes/assessment", "notApplicable") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "Out of scope").

field(Control, "base/fieldTypes/assessmentExplanation", "The control has been marked out of scope") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "Out of scope").

% Not OK because of no evidence

field(Control, "base/fieldTypes/assessment", "notOk") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "In scope"),
  not link(_, Control, "ismsa/linkTypes/evidences").

field(Control, "base/fieldTypes/assessmentExplanation", "The control is in scope but evidence has not been linked") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "In scope"),
  not link(_, Control, "ismsa/linkTypes/evidences").

% Not OK because there is evidence that is not Approved or Passed

ismsa_evidenceStateReady("Approved").
ismsa_evidenceStateReady("Passed").

field(Control, "base/fieldTypes/assessment", "notOk") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "In scope"),
  link(Evidence, Control, "ismsa/linkTypes/evidences"),
  field(Evidence, "workflowState", EvidenceState),
  not ismsa_evidenceStateReady(EvidenceState).

field(Control, "base/fieldTypes/assessmentExplanation", "The control is in scope but the linked evidence is not ready") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "In scope"),
  link(Evidence, Control, "ismsa/linkTypes/evidences"),
  field(Evidence, "workflowState", EvidenceState),
  not ismsa_evidenceStateReady(EvidenceState).

% Not OK because there is evidence and all evidence is ready, but there are policy check failures

field(Control, "base/fieldTypes/assessment", "notOk") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "In scope"),
  link(Evidence, Control, "ismsa/linkTypes/evidences"),
  base_policyCheckFailure(Evidence, _, _, _),
  ismsa_evidenceStateReady(EvidenceState) :
  link(Evidence2, Control, "ismsa/linkTypes/evidences"),
  field(Evidence2, "workflowState", EvidenceState).

field(Control, "base/fieldTypes/assessmentExplanation", "The control is in scope but the linked evidence has failed policy checks") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "In scope"),
  link(Evidence, Control, "ismsa/linkTypes/evidences"),
  base_policyCheckFailure(Evidence, _, _, _),
  ismsa_evidenceStateReady(EvidenceState) :
  link(Evidence2, Control, "ismsa/linkTypes/evidences"),
  field(Evidence2, "workflowState", EvidenceState).

% OK because there is evidence and all linked evidence is Approved or Passed and have no policy check failures

ismsa_evidenceOk(Evidence) :- 
  field(Evidence, "workflowState", EvidenceState),
  ismsa_evidenceStateReady(EvidenceState), 
  not base_policyCheckFailure(Evidence, _, _, _).

field(Control, "base/fieldTypes/assessment", "ok") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "In scope"),
  link(_, Control, "ismsa/linkTypes/evidences"),
  ismsa_evidenceOk(Evidence) : 
  link(Evidence, Control, "ismsa/linkTypes/evidences").

field(Control, "base/fieldTypes/assessmentExplanation", "The control is in scope and there is valid evidence") :-
  field(Control, "cardType", "ismsa/cardTypes/internalControl"),
  field(Control, "workflowState", "In scope"),
  link(_, Control, "ismsa/linkTypes/evidences"),
  ismsa_evidenceOk(Evidence) :
  link(Evidence, Control, "ismsa/linkTypes/evidences").

%
% Justification is required if the control is out of scope
%

transitionDenied(
  Control,
  "Mark out of scope",
  "To mark this control as out of scope, you must first provide a justification. Fill in the scoping justification field."
) :-
    field(Control, "cardType", "ismsa/cardTypes/internalControl"),
    not field(Control, "base/fieldTypes/justification", _).

policyCheckFailure(
  Control,
  "Internal control",
  "Justification missing",
  "A scoping justification is mandatory for controls that have been marked out of scope. Set this field",
  "base/fieldTypes/justification"
) :-
    field(Control, "cardType", "ismsa/cardTypes/internalControl"),
    field(Control, "workflowState", "Out of scope"),
    not field(Control, "base/fieldTypes/justification", _).
