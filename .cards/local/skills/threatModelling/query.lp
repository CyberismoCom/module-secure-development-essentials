selectAll.

result(threatModelling).

childResult(threatModelling, Project, "projects") :-
    base_projectCardType(Project, "secdeva/cardTypes/project2").

childObject(Project, Phase, "designPhase") :-
    base_projectCardType(Project, "secdeva/cardTypes/project2"),
    field(Phase, "base/fieldTypes/identifier", "secdeva_phase_design"),
    secdeva_closestProject(Phase, Project).

childResult(Project, Model, "threatModels") :-
    base_projectCardType(Project, "secdeva/cardTypes/project2"),
    secdeva_dataflowModel(Model),
    secdeva_closestProject(Model, Project).

childResult(threatModelling, Model, "modelsOutsideProjects") :-
    secdeva_dataflowModel(Model),
    not secdeva_closestProject(Model, _).

order(2, "projects", 1, "rank", "ASC").
