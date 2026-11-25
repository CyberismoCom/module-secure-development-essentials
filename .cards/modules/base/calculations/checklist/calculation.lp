%* Checklists

A checklist is a card that has checklist items as its children. The base
documentation describes the rules of this calculation, under "Using the base
module" > "Checklists".

Shared predicates: base_checklistItem/2, base_checklist/1,
base_checklistItemResult/2, base_checklistItemComplete/1,
base_checklistComplete/1, base_checklistResult/2, base_checklistItemCount/3,
and base_checklistReview/1. Each one has a predicate card in the base
documentation, under "For module authors" > "Shared predicates".
*%

base_checklistResultValue("open"; "ok"; "deviation"; "notApplicable").
base_checklistCommentRequired("deviation"; "notApplicable").

base_checklistItem(Item, Checklist) :-
    base_projectCardType(Item, "base/cardTypes/checklistItem"),
    not field(Item, "workflowState", "Archived"),
    parent(Item, Checklist).

base_checklist(Checklist) :-
    base_checklistItem(_, Checklist).

base_checklistItemResult(Item, Result) :-
    base_checklistItem(Item, _),
    field(Item, "base/fieldTypes/checklistResult", Result).

base_checklistItemResult(Item, "open") :-
    base_checklistItem(Item, _),
    not field(Item, "base/fieldTypes/checklistResult", _).

base_checklistCommentMissing(Item) :-
    base_checklistItemResult(Item, Result),
    base_checklistCommentRequired(Result),
    not field(Item, "base/fieldTypes/comment", _).

base_checklistItemComplete(Item) :-
    base_checklistItemResult(Item, Result),
    Result != "open",
    not base_checklistCommentMissing(Item).

base_checklistComplete(Checklist) :-
    base_checklist(Checklist),
    base_checklistItemComplete(Item) : base_checklistItem(Item, Checklist).

base_checklistHasDeviation(Checklist) :-
    base_checklistItem(Item, Checklist),
    base_checklistItemResult(Item, "deviation").

base_checklistAllNotApplicable(Checklist) :-
    base_checklistComplete(Checklist),
    base_checklistItemResult(Item, "notApplicable") :
        base_checklistItem(Item, Checklist).

base_checklistResult(Checklist, "deviation") :-
    base_checklistHasDeviation(Checklist).

base_checklistResult(Checklist, "open") :-
    base_checklist(Checklist),
    not base_checklistHasDeviation(Checklist),
    not base_checklistComplete(Checklist).

base_checklistResult(Checklist, "notApplicable") :-
    base_checklistAllNotApplicable(Checklist),
    not base_checklistHasDeviation(Checklist).

base_checklistResult(Checklist, "ok") :-
    base_checklistComplete(Checklist),
    not base_checklistHasDeviation(Checklist),
    not base_checklistAllNotApplicable(Checklist).

base_checklistItemCount(Checklist, Result, Count) :-
    base_checklist(Checklist),
    base_checklistResultValue(Result),
    Count = #count {
        Item : base_checklistItem(Item, Checklist),
               base_checklistItemResult(Item, Result)
    }.

% A Deviation or Not applicable result needs a comment

policyCheckFailure(
    Item,
    "Checklist",
    "Comment missing",
    "A Deviation or Not applicable result needs a comment. Explain the result in the Comment field.",
    "base/fieldTypes/comment"
    ) :-
        base_checklistCommentMissing(Item).

% Checklist items are hidden in the navigation tree. The checklist report
% shows the items as a table, and links to each item.

hiddenInTreeView(Item) :-
    base_projectCardType(Item, "base/cardTypes/checklistItem").

% A review that is a checklist

base_checklistReview(Checklist) :-
    base_checklist(Checklist),
    base_projectCardType(Checklist, "base/cardTypes/review").

% The items are hidden, so the review shows the policy check failures of its
% items. The message names the item.
policyCheckFailure(
    Checklist,
    "Checklist",
    Title,
    @concatenate("Checklist item \"", ItemTitle, "\": ", Message)
    ) :-
        base_checklistReview(Checklist),
        base_checklistItem(Item, Checklist),
        base_policyCheckFailure(Item, _, Title, Message),
        field(Item, "title", ItemTitle).

% The progress of a review is the percentage of complete items
field(Checklist, "progress", 100 * Complete / Total) :-
    base_checklistReview(Checklist),
    Total = #count { Item : base_checklistItem(Item, Checklist) },
    Complete = #count {
        Item : base_checklistItem(Item, Checklist),
               base_checklistItemComplete(Item)
    }.

% A review passes only when its checklist is complete

base_checklistCommentMissingCount(Checklist, Count) :-
    base_checklist(Checklist),
    Count = #count {
        Item : base_checklistItem(Item, Checklist),
               base_checklistCommentMissing(Item)
    }.

transitionDenied(
    Review,
    "Mark as passed",
    @concatenate(
        "Complete the checklist before passing the review: ",
        Open, " open, ", Missing, " comment(s) missing.")
    ) :-
        base_checklistReview(Review),
        not base_checklistComplete(Review),
        base_checklistItemCount(Review, "open", Open),
        base_checklistCommentMissingCount(Review, Missing).

% A review that passed with deviations shows them as a notification, not as a
% policy check failure. A policy check failure would make the review count as
% failed evidence (see the reviewAssessment calculation of ismsa).

notification(
    Review,
    "Checklist",
    "Passed with deviations",
    @concatenate(
        "The review passed with ", Count,
        " deviation(s). The checklist shows them with their comments.")
    ) :-
        base_checklistReview(Review),
        field(Review, "workflowState", "Passed"),
        base_checklistItemCount(Review, "deviation", Count),
        Count > 0.

% A passed review whose checklist has open items again. Comments that are
% missing already show as failures of the items.

policyCheckFailure(
    Review,
    "Checklist",
    "Open checklist items after the review passed",
    @concatenate(
        Count, " checklist item(s) are open. Set their results, or reopen the review.")
    ) :-
        base_checklistReview(Review),
        field(Review, "workflowState", "Passed"),
        base_checklistItemCount(Review, "open", Count),
        Count > 0.

% The status indicator of a checklist item follows its result

base_disableDefaultStatusIndicator(Item) :-
    base_checklistItem(Item, _).

field(Item, "statusIndicator", "error") :-
    base_checklistItem(Item, _),
    base_policyCheckFailure(Item, _, _, _).

field(Item, "statusIndicator", "initial") :-
    base_checklistItemResult(Item, "open"),
    not base_policyCheckFailure(Item, _, _, _).

field(Item, "statusIndicator", "active") :-
    base_checklistItemResult(Item, "deviation"),
    not base_policyCheckFailure(Item, _, _, _).

field(Item, "statusIndicator", "closed") :-
    base_checklistItemResult(Item, "ok"),
    not base_policyCheckFailure(Item, _, _, _).

field(Item, "statusIndicator", "closed") :-
    base_checklistItemResult(Item, "notApplicable"),
    not base_policyCheckFailure(Item, _, _, _).
