% Copyright © Cyberismo Ltd and contributors 2025
%
% License: https://github.com/CyberismoCom/module-secure-development-essentials/blob/main/LICENSE
% The use of the Cyberismo trademark: https://cyberismo.com/trademark-policy/
% This content is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.

secdeva_calculateProgress(Phase) :-
    field(Phase, "cardType", "secdeva/cardTypes/page").

secdeva_calculateProgress(Project) :-
    field(Project, "cardType", "secdeva/cardTypes/project").

field(Card, "base/fieldTypes/progress", 100 * Closed / Total) :-
    secdeva_calculateProgress(Card),
    Total = #count {
        card(Task) :
        ancestor(Task, Card),
        base_recurringTask(Task),
        not hiddenInTreeView(Task)
    },
    Total > 0,
    Closed = #count {
        card(Task) :
        base_recurringTask(Task),
        ancestor(Task, Card),
        field(Task, "workflowStateCategory", "closed")
    }.

policyCheckFailure(
    Project,
    "Secure development",
    "Secure development tasks are not complete",
    @concatenate("Only ", Progress, "% of secure development tasks have been completed. Complete all tasks or close them as not applicable.")
    ) :-
        field(Project, "cardType", "secdeva/cardTypes/project"),
        field(Project, "base/fieldTypes/progress", Progress),
        Progress < 100.

policyCheckSuccess(
    Project,
    "Secure development",
    "Secure development tasks are complete"
    ) :-
        field(Project, "cardType", "secdeva/cardTypes/project"),
        field(Project, "base/fieldTypes/progress", 100).
