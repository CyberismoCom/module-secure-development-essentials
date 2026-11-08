selectAll.

result(Model) :- secdeva_modelOf({{cardKey}}, Model).

secdevaSkill_element(Element, Model) :- secdeva_modelOf({{cardKey}}, Model), secdeva_modelOf(Element, Model), Element != Model.

% the registers of the project that the threat model is in
childObject(Model, Project, "project") :- result(Model), secdeva_closestProject(Model, Project).
secdevaSkill_register(Model, Card, Identifier) :-
    result(Model), secdeva_closestProject(Model, Project),
    field(Card, "base/fieldTypes/identifier", Identifier), secdeva_closestProject(Card, Project).
childObject(Model, R, "riskRegister") :- secdevaSkill_register(Model, R, "secdeva_register_risks").
childObject(Model, R, "securityIssueRegister") :- secdevaSkill_register(Model, R, "secdeva_register_security-issues").
childObject(Model, R, "requirementRegister") :- secdevaSkill_register(Model, R, "secdeva_register_security-requirements").
childObject(Model, R, "ownProducts") :- secdevaSkill_register(Model, R, "secdeva_group_own-products").
childObject(Model, R, "thirdPartyProducts") :- secdevaSkill_register(Model, R, "secdeva_group_third-party-products").
childObject(Model, R, "decisionRegister") :- secdevaSkill_register(Model, R, "secdeva_register_decisions").
childObject(Model, R, "technologyAssessments") :- secdevaSkill_register(Model, R, "secdeva_register_technology-assessments").

% dataflows that cross a trust boundary
childResult(Model, (S, D, T), "crossingDataflows") :-
    result(Model), secdevaSkill_element(S, Model), secdeva_crossingDataflow(S, D, T).
field((S, D, T), "dataflow", T) :- childResult(_, (S, D, T), "crossingDataflows").
field((S, D, T), "sourceKey", S) :- childResult(_, (S, D, T), "crossingDataflows").
field((S, D, T), "sourceTitle", Title) :- childResult(_, (S, D, T), "crossingDataflows"), field(S, "title", Title).
field((S, D, T), "destinationKey", O) :- childResult(_, (S, D, T), "crossingDataflows"), secdeva_dataflowOwner(D, O).
field((S, D, T), "destinationTitle", Title) :-
    childResult(_, (S, D, T), "crossingDataflows"), secdeva_dataflowOwner(D, O), field(O, "title", Title).
field((S, D, T), "interfaceKey", D) :-
    childResult(_, (S, D, T), "crossingDataflows"), base_projectCardType(D, "secdeva/cardTypes/interface").
field((S, D, T), "interfaceTitle", Title) :-
    childResult(_, (S, D, T), "crossingDataflows"), base_projectCardType(D, "secdeva/cardTypes/interface"), field(D, "title", Title).
field((S, D, T), "port", Port) :-
    childResult(_, (S, D, T), "crossingDataflows"), field(D, "secdeva/fieldTypes/port", Port).
order(2, "crossingDataflows", 1, "destinationTitle", "ASC").

% what has been recorded for the elements of the model
childResult(Model, R, "risks") :-
    result(Model), secdevaSkill_element(E, Model), link(E, R, "ismsa/linkTypes/presentsRisk"),
    base_projectCardType(R, "ismsa/cardTypes/risk").
childResult(Model, I, "issues") :-
    result(Model), secdevaSkill_element(E, Model), link(E, I, "ismsa/linkTypes/presentsRisk"),
    base_projectCardType(I, "secdeva/cardTypes/securityIssue").
childResult(Model, Q, "requirements") :-
    result(Model), secdevaSkill_element(E, Model), link(Q, E, "secdeva/linkTypes/appliesTo").
childResult(Model, P, "products") :-
    result(Model), secdevaSkill_element(E, Model), link(E, P, "secdeva/linkTypes/implementedBy").
