% A technology assessment is similar to a controlled document, but it is a separate card type,
% so we need to include similar rules for it as there are for controlled documents in the base module:

% The review tasks of a technology assessment, and the technology assessments that have one.
% The rules over "all review tasks" below need at least one review task, or
% they would be true for a technology assessment without review tasks.
secdeva_technologyReview(Document, ReviewTask) :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask").

secdeva_technologyHasReview(Document) :-
    secdeva_technologyReview(Document, _).

% A technology assessment that has a closed review with a review date.
secdeva_technologyReviewed(Document) :-
    secdeva_technologyReview(Document, ReviewTask),
    field(ReviewTask, "workflowState", "Closed as done"),
    field(ReviewTask, "base/fieldTypes/lastReviewed", _).

transitionDenied(Document, "Approve", "Add a review task before approving") :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    not secdeva_technologyHasReview(Document).

transitionDenied(Document, "Approve", "Fix policy failures before approving") :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    policyCheckFailure(Document, _, _, _).

transitionDenied(Document, "Approve", "Fix policy failures in at least one of the review subtask(s) before approving" ):-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    secdeva_technologyHasReview(Document),
    policyCheckFailure(ReviewTask, _, _, _) :
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    parent(ReviewTask, Document).

transitionDenied(Document, "Approve", "Fill in the owner field before approving") :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    not field(Document, "base/fieldTypes/owner", _).

transitionDenied(Document, "Approve", "Fill in the approver field before approving") :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    not field(Document, "base/fieldTypes/approver", _).

transitionDenied(Document, "Approve", "Fill in the information classification field before approving") :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    not field(Document, "base/fieldTypes/informationClassification", _).

onTransitionSetField(Document, "Approve", Document, "base/fieldTypes/approvalDate", @today) :-
    base_projectCardType(Document, "secdeva/cardTypes/technology").

transitionDenied(Document, "Approve", "Complete the review task(s) before approving") :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    not field(ReviewTask, "workflowState", "Closed as done").

policyCheckFailure(Document, "Document control", "Failing policy checks in all review tasks", "Fix policy failures in at least one of the review subtask(s)" ):-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    field(Document, "workflowState", "Approved"),
    secdeva_technologyHasReview(Document),
    policyCheckFailure(ReviewTask, _, _, _) :
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    parent(ReviewTask, Document).

editingContentDenied(Document, "You cannot edit approved technology assessments" ):-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    field(Document, "workflowState", "Approved").

editingContentDenied(Document, "You cannot edit archived technology assessments" ):-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    field(Document, "workflowState", "Archived").

policyCheckFailure(Document, "Document control", "Owner is a required field", "Fill in the owner field." ):-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/owner", _).

policyCheckFailure(Document, "Document control", "Approver is a required field", "Fill in the approver field." ):-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/approver", _).

policyCheckFailure(Document, "Document control", "Approval date is a mandatory field", "Fill in the approval date field." ):-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/approvalDate", _).

policyCheckFailure(Document, "Document control", "The review subtasks of approved documents must be closed", "Complete review task(s)" ):-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    field(Document, "workflowState", "Approved"),
    not field(ReviewTask, "workflowState", "Closed as done").

policyCheckFailure(Document, "Document control", "Reviewer cannot be the same as document owner", "The owner of a review task is also the owner of this document. Change the owner of the review task.") :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    field(Document, "base/fieldTypes/owner", DocumentOwner),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentOwner = Reviewer.

policyCheckFailure(ReviewTask, "Document control", "Reviewer cannot be the same as document owner", "The owner of a review task is also the owner of this document. Change the owner of the review task.") :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    field(Document, "base/fieldTypes/owner", DocumentOwner),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentOwner = Reviewer.

policyCheckFailure(Document, "Document control", "Review task missing", "Add a review task and complete it.") :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    field(Document, "workflowState", "Approved"),
    not secdeva_technologyHasReview(Document).

% Expired when all closed reviews are older than the review period. A technology assessment
% without a closed review fails other checks instead.
policyCheckFailure(Document, "Document control", "Review has expired", "Complete a new review of this document.") :-
    base_projectCardType(Document, "secdeva/cardTypes/technology"),
    field(Document, "workflowState", "Approved"),
    secdeva_technologyReviewed(Document),
    field(Document, "base/fieldTypes/reviewPeriod", ReviewPeriod),
    @daysSince(LastReviewed) > ReviewPeriod :
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    field(ReviewTask, "workflowState", "Closed as done"),
    field(ReviewTask, "base/fieldTypes/lastReviewed", LastReviewed).

% The checklist of a technology assessment must be answered before approval.
% Each check needs a result, and a Deviation or Not applicable result needs a
% comment. Deviations do not block approval: the approver accepts them.

transitionDenied(
    Document,
    "Approve",
    @concatenate(
        "Answer all checks of the checklist before approving: ",
        Open, " open, ", Missing, " comment(s) missing.")
    ) :-
        base_projectCardType(Document, "secdeva/cardTypes/technology"),
        base_checklist(Document),
        not base_checklistComplete(Document),
        base_checklistItemCount(Document, "open", Open),
        base_checklistCommentMissingCount(Document, Missing).

policyCheckFailure(
    Document,
    "Document control",
    "Unanswered checks in an approved technology assessment",
    "Some checks of the checklist have no result, or a Deviation or Not applicable result has no comment. Answer the checks, or reopen the assessment."
    ) :-
        base_projectCardType(Document, "secdeva/cardTypes/technology"),
        field(Document, "workflowState", "Approved"),
        base_checklist(Document),
        not base_checklistComplete(Document).
