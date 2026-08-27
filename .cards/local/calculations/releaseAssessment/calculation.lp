% The assessment of a release rolls up the state of its children: the release review and
% the release notes. Those cards already carry their own assessment, calculated by
% ismsa/calculations/reviewAssessment and ismsa/calculations/documentAssessment, so this
% calculation composes those results rather than deriving them again.
%
% The assessment deliberately does not read the policy check failures of the release
% itself. The policy checks below are derived from the assessment, and reading them back
% would make the two depend on each other.

secdeva_release(Release) :- base_projectCardType(Release, "secdeva/cardTypes/release").

% The cards that the assessment is rolled up from. Any child that carries an assessment
% counts, so a project that adds further evidence under a release is covered as well.

secdeva_releaseItem(Release, Item) :-
    secdeva_release(Release),
    parent(Item, Release),
    field(Item, "base/fieldTypes/assessment", _).

% A release must have both a review and release notes. Which documents count as release
% notes is not fixed by title: any controlled document under the release qualifies, so
% that a project can keep internal and external notes, only one of them, or its own.

secdeva_releaseReview(Release, Review) :-
    secdeva_release(Release),
    parent(Review, Release),
    base_projectCardType(Review, "base/cardTypes/review").

secdeva_releaseNotes(Release, Notes) :-
    secdeva_release(Release),
    parent(Notes, Release),
    base_projectCardType(Notes, "base/cardTypes/controlledDocument").

secdeva_releaseMissingReview(Release) :-
    secdeva_release(Release),
    not secdeva_releaseReview(Release, _).

secdeva_releaseMissingNotes(Release) :-
    secdeva_release(Release),
    not secdeva_releaseNotes(Release, _).

secdeva_releaseMissingItem(Release) :- secdeva_releaseMissingReview(Release).
secdeva_releaseMissingItem(Release) :- secdeva_releaseMissingNotes(Release).

secdeva_releaseItemNotOk(Release) :-
    secdeva_releaseItem(Release, Item),
    field(Item, "base/fieldTypes/assessment", "notOk").

secdeva_releaseItemOpen(Release) :-
    secdeva_releaseItem(Release, Item),
    field(Item, "base/fieldTypes/assessment", "open").

secdeva_releaseArchived(Release) :-
    secdeva_release(Release),
    field(Release, "workflowState", "Archived").

%
% Not applicable: the release has been archived
%

fieldCalculated(Release, "base/fieldTypes/assessment", "notApplicable") :-
    secdeva_releaseArchived(Release).

fieldCalculated(Release, "base/fieldTypes/assessmentExplanation", "The release has been archived") :-
    secdeva_releaseArchived(Release).

%
% Not OK: the release review or the release notes are missing
%

fieldCalculated(Release, "base/fieldTypes/assessment", "notOk") :-
    secdeva_release(Release),
    not secdeva_releaseArchived(Release),
    secdeva_releaseMissingItem(Release).

fieldCalculated(Release, "base/fieldTypes/assessmentExplanation", "The release has neither a release review nor release notes") :-
    secdeva_release(Release),
    not secdeva_releaseArchived(Release),
    secdeva_releaseMissingReview(Release),
    secdeva_releaseMissingNotes(Release).

fieldCalculated(Release, "base/fieldTypes/assessmentExplanation", "The release does not have a release review") :-
    secdeva_release(Release),
    not secdeva_releaseArchived(Release),
    secdeva_releaseMissingReview(Release),
    not secdeva_releaseMissingNotes(Release).

fieldCalculated(Release, "base/fieldTypes/assessmentExplanation", "The release does not have release notes") :-
    secdeva_release(Release),
    not secdeva_releaseArchived(Release),
    not secdeva_releaseMissingReview(Release),
    secdeva_releaseMissingNotes(Release).

%
% Not OK: the release review or the release notes are not in an acceptable state
%

fieldCalculated(Release, "base/fieldTypes/assessment", "notOk") :-
    secdeva_release(Release),
    not secdeva_releaseArchived(Release),
    not secdeva_releaseMissingItem(Release),
    secdeva_releaseItemNotOk(Release).

fieldCalculated(Release, "base/fieldTypes/assessmentExplanation", "The release review or the release notes are not in an acceptable state") :-
    secdeva_release(Release),
    not secdeva_releaseArchived(Release),
    not secdeva_releaseMissingItem(Release),
    secdeva_releaseItemNotOk(Release).

%
% Open: the release review and the release notes are still being worked on
%

fieldCalculated(Release, "base/fieldTypes/assessment", "open") :-
    secdeva_release(Release),
    not secdeva_releaseArchived(Release),
    not secdeva_releaseMissingItem(Release),
    not secdeva_releaseItemNotOk(Release),
    secdeva_releaseItemOpen(Release).

fieldCalculated(Release, "base/fieldTypes/assessmentExplanation", "The release review or the release notes have not been completed yet") :-
    secdeva_release(Release),
    not secdeva_releaseArchived(Release),
    not secdeva_releaseMissingItem(Release),
    not secdeva_releaseItemNotOk(Release),
    secdeva_releaseItemOpen(Release).

%
% OK: the release review has passed and the release notes have been approved
%

fieldCalculated(Release, "base/fieldTypes/assessment", "ok") :-
    secdeva_release(Release),
    not secdeva_releaseArchived(Release),
    not secdeva_releaseMissingItem(Release),
    not secdeva_releaseItemNotOk(Release),
    not secdeva_releaseItemOpen(Release).

fieldCalculated(Release, "base/fieldTypes/assessmentExplanation", "The release review has passed and the release notes have been approved") :-
    secdeva_release(Release),
    not secdeva_releaseArchived(Release),
    not secdeva_releaseMissingItem(Release),
    not secdeva_releaseItemNotOk(Release),
    not secdeva_releaseItemOpen(Release).

%
% The security gate
%
% The assessment is overridable, so a release that the automatic checks reject can still
% be made once someone takes responsibility for it by hand. Overriding the assessment
% requires a written justification, which is what the second policy check below asks for.
%

transitionDenied(
    Release,
    "Release",
    "The release review and the release notes must be in an acceptable state before the release can be made. Complete them, or override the assessment field and justify the override in the assessment explanation field."
) :-
    secdeva_release(Release),
    not field(Release, "base/fieldTypes/assessment", "ok").

policyCheckFailure(
    Release,
    "Release",
    "The release has been made although it is not ready",
    @concatenate("The release is in the Released state, but the automatic assessment says: ", Explanation)
) :-
    secdeva_release(Release),
    field(Release, "workflowState", "Released"),
    not field(Release, "base/fieldTypes/assessment", "ok"),
    field(Release, "base/fieldTypes/assessmentExplanation", Explanation).

secdeva_releaseOverrideUnexplained(Release) :-
    secdeva_release(Release),
    fieldOverride(Release, "base/fieldTypes/assessment", _),
    not fieldOverride(Release, "base/fieldTypes/assessmentExplanation", _).

policyCheckFailure(
    Release,
    "Release",
    "Assessment explanation not given for overridden assessment",
    "The assessment field has been overridden, but the assessment explanation has not been updated. Explain the assessment by overriding the assessment explanation field.",
    "base/fieldTypes/assessmentExplanation"
) :-
    secdeva_releaseOverrideUnexplained(Release).

% An overridden assessment is reported as a success only once it has been explained.
% Until then the explanation still describes what the automatic checks found, which does
% not say why the release was accepted by hand.

policyCheckSuccess(
    Release,
    "Release",
    @concatenate("The release is ready: ", Explanation)
) :-
    secdeva_release(Release),
    field(Release, "base/fieldTypes/assessment", "ok"),
    not secdeva_releaseOverrideUnexplained(Release),
    field(Release, "base/fieldTypes/assessmentExplanation", Explanation).
