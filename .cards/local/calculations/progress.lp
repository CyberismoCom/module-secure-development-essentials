secdeva_calculateProgress(Phase) :-
    field(Phase, "cardType", "secdeva/cardTypes/phase").

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