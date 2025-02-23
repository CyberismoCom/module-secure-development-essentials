secdeva_calculateProgress(Phase) :-
    field(Phase, "cardType", "secdeva/cardTypes/phase").

secdeva_calculateProgress(Project) :-
    field(Project, "cardType", "secdeva/cardTypes/project").

field(Card, "base/fieldTypes/progress", 100 * Closed / Total) :-
    secdeva_calculateProgress(Card),
    Total = #count {
        base_recurringTask(Task):
        ancestor(Task, Card),
        not hiddenInTreeView(Task)
    },
    Total > 0,
    Closed = #count {
        base_recurringTask(Task):
        ancestor(Task, Card),
        field(Task, "workflowStateCategory", "closed")
    }.