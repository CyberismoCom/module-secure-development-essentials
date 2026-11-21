% The review tasks of a controlled document, and the documents that have one.
% The rules over "all review tasks" below need at least one review task, or
% they would be true for a document without review tasks.
base_documentReview(Document, ReviewTask) :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask").

base_documentHasReview(Document) :-
    base_documentReview(Document, _).

% A document that has a closed review with a review date.
base_documentReviewed(Document) :-
    base_documentReview(Document, ReviewTask),
    field(ReviewTask, "workflowState", "Closed as done"),
    field(ReviewTask, "base/fieldTypes/lastReviewed", _).

transitionDenied(Document, "Approve", "Add a review task before approving") :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    not base_documentHasReview(Document).

transitionDenied(Document, "Approve", "Fix policy failures before approving") :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    policyCheckFailure(Document, _, _, _).

transitionDenied(Document, "Approve", "Fix policy failures in at least one of the review subtask(s) before approving" ):-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    base_documentHasReview(Document),
    policyCheckFailure(ReviewTask, _, _, _) :
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    parent(ReviewTask, Document).

transitionDenied(Document, "Approve", "Fill in the owner field before approving") :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    not field(Document, "base/fieldTypes/owner", _).

transitionDenied(Document, "Approve", "Fill in the approver field before approving") :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    not field(Document, "base/fieldTypes/approver", _).

transitionDenied(Document, "Approve", "Fill in the information classification field before approving") :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    not field(Document, "base/fieldTypes/informationClassification", _).

onTransitionSetField(Document, "Approve", Document, "base/fieldTypes/approvalDate", @today) :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument").

transitionDenied(Document, "Approve", "Complete the review task(s) before approving") :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    not field(ReviewTask, "workflowState", "Closed as done").

policyCheckFailure(Document, "Document control", "Failing policy checks in all review tasks", "Fix policy failures in at least one of the review subtask(s)" ):-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    field(Document, "workflowState", "Approved"),
    base_documentHasReview(Document),
    policyCheckFailure(ReviewTask, _, _, _) :
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    parent(ReviewTask, Document).

editingContentDenied(Document, "You cannot edit approved documents" ):-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    field(Document, "workflowState", "Approved").

editingContentDenied(Document, "You cannot edit archived documents" ):-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    field(Document, "workflowState", "Archived").

transitionDenied(ReviewTask, "Start progress", "Fill in the owner field before starting progress" ):-
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    not field(ReviewTask, "base/fieldTypes/owner", _).

transitionDenied(ReviewTask, "Done", "Fill in the owner field before completing the task" ):-
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    not field(ReviewTask, "base/fieldTypes/owner", _).

policyCheckFailure(Document, "Document control", "Owner is a required field", "Fill in the owner field.", "base/fieldTypes/owner"):-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/owner", _).

policyCheckFailure(Document, "Document control", "Approver is a required field", "Fill in the approver field.", "base/fieldTypes/approver"):-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/approver", _).

policyCheckFailure(Document, "Document control", "Approval date is a mandatory field", "Fill in the approval date field.", "base/fieldTypes/approvalDate"):-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/approvalDate", _).

policyCheckFailure(Document, "Document control", "Review period is a required field", "Fill in the Review period field.", "base/fieldTypes/reviewPeriod"):-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/reviewPeriod", _).

policyCheckFailure(Document, "Document control", "The review subtasks of approved documents must be closed", "Complete review task(s)" ):-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    field(Document, "workflowState", "Approved"),
    not field(ReviewTask, "workflowState", "Closed as done").

policyCheckFailure(Document, "Document control", "Reviewer cannot be the same as document owner", "The owner of a review task is also the owner of this document. Change the owner of the review task.") :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    field(Document, "base/fieldTypes/owner", DocumentOwner),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentOwner = Reviewer.

policyCheckFailure(ReviewTask, "Document control", "Reviewer cannot be the same as document owner", "The owner of a review task is also the owner of this document. Change the owner of the review task.") :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    field(Document, "base/fieldTypes/owner", DocumentOwner),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentOwner = Reviewer.

policyCheckFailure(Document, "Document control", "Review task missing", "Add a review task and complete it.") :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    field(Document, "workflowState", "Approved"),
    not base_documentHasReview(Document).

% Expired when all closed reviews are older than the review period. A document
% without a closed review fails other checks instead.
policyCheckFailure(Document, "Document control", "Review has expired", "Complete a new review of this document.") :-
    base_projectCardType(Document, "base/cardTypes/controlledDocument"),
    field(Document, "workflowState", "Approved"),
    base_documentReviewed(Document),
    field(Document, "base/fieldTypes/reviewPeriod", ReviewPeriod),
    @daysSince(LastReviewed) > ReviewPeriod :
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    field(ReviewTask, "workflowState", "Closed as done"),
    field(ReviewTask, "base/fieldTypes/lastReviewed", LastReviewed).
