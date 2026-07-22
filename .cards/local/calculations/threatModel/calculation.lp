% Threat model components are assets that may be affected by security issues

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/process").

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/dataStore").

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/person").

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/trustBoundary").

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/external").

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/interface").

link(Asset, SecurityIssue, "ismsa/linkTypes/presentsRisk") :-
    parent(SecurityIssue, Asset),
    field(SecurityIssue, "cardType", "secdeva/cardTypes/securityIssue"),
    secdeva_threatModelComponent(Asset).

% Defining ismsa_asset for threat model components makes them work correctly in assets-risks-controls diagrams

ismsa_asset(Card, "Process") :-
    field(Card, "cardType", "secdeva/cardTypes/process").

ismsa_asset(Card, "Data store") :-
    field(Card, "cardType", "secdeva/cardTypes/dataStore").

ismsa_asset(Card, "Person") :-
    field(Card, "cardType", "secdeva/cardTypes/person").

ismsa_asset(Card, "Trust boundary") :-
    field(Card, "cardType", "secdeva/cardTypes/trustBoundary").

ismsa_asset(Card, "External entity") :-
    field(Card, "cardType", "secdeva/cardTypes/external").

ismsa_asset(Card, "Interface") :-
    field(Card, "cardType", "secdeva/cardTypes/interface").

% Threat model is similar to a controlled document, but it is a separate card type,
% so we need to include similar rules for it as there are for controlled documents in the base module:

transitionDenied(Document, "Approve", "Fix policy failures before approving") :-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    policyCheckFailure(Document, _, _, _).

transitionDenied(Document, "Approve", "Fix policy failures in at least one of the review subtask(s) before approving" ):-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    policyCheckFailure(ReviewTask, _, _, _) :
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    parent(ReviewTask, Document).

transitionDenied(Document, "Approve", "Fill in the owner field before approving") :-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    not field(Document, "base/fieldTypes/owner", _).

transitionDenied(Document, "Approve", "Fill in the approver field before approving") :-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    not field(Document, "base/fieldTypes/approver", _).

transitionDenied(Document, "Approve", "Fill in the information classification field before approving") :-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    not field(Document, "base/fieldTypes/informationClassification", _).

transitionDenied(Document, "Approve", "Fill in the approval date field before approving") :-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    not field(Document, "base/fieldTypes/approvalDate", _).

transitionDenied(Document, "Approve", "Complete the review task(s) before approving") :-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    parent(ReviewTask, Document),
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    not field(ReviewTask, "workflowState", "Closed as done").

policyCheckFailure(Document, "Document control", "Failing policy checks in all review tasks", "Fix policy failures in at least one of the review subtask(s)" ):-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    field(Document, "workflowState", "Approved"),
    policyCheckFailure(ReviewTask, _, _, _) :
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    parent(ReviewTask, Document).

editingContentDenied(Document, "You cannot edit approved threat models" ):-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    field(Document, "workflowState", "Approved").

editingContentDenied(Document, "You cannot edit archived threat models" ):-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    field(Document, "workflowState", "Archived").

policyCheckFailure(Document, "Threat model control", "Owner is a required field", "Fill in the owner field." ):-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/owner", _).

policyCheckFailure(Document, "Threat model control", "Approver is a required field", "Fill in the approver field." ):-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/approver", _).

policyCheckFailure(Document, "Threat model control", "Approval date is a mandatory field", "Fill in the approval date field." ):-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/approvalDate", _).

policyCheckFailure(Document, "Threat model control", "The review subtasks of approved documents must be closed", "Complete review task(s)" ):-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    parent(ReviewTask, Document),
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    field(Document, "workflowState", "Approved"),
    not field(ReviewTask, "workflowState", "Closed as done").

policyCheckFailure(Document, "Threat model control", "Reviewer cannot be the same as document owner", "The owner of a review task is also the owner of this threat model. Change the owner of the review task.") :-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    parent(ReviewTask, Document),
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    field(Document, "base/fieldTypes/owner", DocumentOwner),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentOwner = Reviewer.

policyCheckFailure(ReviewTask, "Threat model control", "Reviewer cannot be the same as threat model owner", "The owner of a review task is also the owner of this threat model. Change the owner of the review task.") :-
    field(Document, "cardType", "secdeva/cardTypes/threatModel"),
    parent(ReviewTask, Document),
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    field(Document, "base/fieldTypes/owner", DocumentOwner),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentOwner = Reviewer.

