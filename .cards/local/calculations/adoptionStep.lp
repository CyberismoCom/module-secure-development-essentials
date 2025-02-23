hiddenInTreeView(Card) :-
    card(Card),
    secdeva_closestProject(Card, Project),
    base_greaterAdoptionStep(Card, Project).
