selectAll.

result(Model) :- secdeva_modelOf({{cardKey}}, Model).

secdevaSkill_element(Element, Model) :- secdeva_modelOf({{cardKey}}, Model), secdeva_modelOf(Element, Model), Element != Model.
secdevaSkill_type(Element, Type) :- secdevaSkill_element(Element, _), base_projectCardType(Element, Type).
secdevaSkill_entity(Element) :- secdevaSkill_type(Element, "secdeva/cardTypes/process").
secdevaSkill_entity(Element) :- secdevaSkill_type(Element, "secdeva/cardTypes/dataStore").
secdevaSkill_entity(Element) :- secdevaSkill_type(Element, "secdeva/cardTypes/external").
secdevaSkill_entity(Element) :- secdevaSkill_type(Element, "secdeva/cardTypes/person").

resultField(Model, "boundaryCount", N) :- result(Model), N = #count { E : secdevaSkill_type(E, "secdeva/cardTypes/trustBoundary") }.
resultField(Model, "processCount", N) :- result(Model), N = #count { E : secdevaSkill_type(E, "secdeva/cardTypes/process") }.
resultField(Model, "dataStoreCount", N) :- result(Model), N = #count { E : secdevaSkill_type(E, "secdeva/cardTypes/dataStore") }.
resultField(Model, "outsidePartyCount", N) :- result(Model), N = #count { E : secdevaSkill_type(E, "secdeva/cardTypes/external") ; E : secdevaSkill_type(E, "secdeva/cardTypes/person") }.
resultField(Model, "interfaceCount", N) :- result(Model), N = #count { E : secdevaSkill_type(E, "secdeva/cardTypes/interface") }.
resultField(Model, "dataflowCount", N) :- result(Model), N = #count { S, D, T : link(S, D, "secdeva/linkTypes/dataflow", T), secdevaSkill_element(S, _) }.

% gaps in the model
secdevaSkill_hasDescription(E) :- field(E, "secdeva/fieldTypes/description", D), D != "".
childResult(Model, E, "missingDescription") :-
    result(Model), secdevaSkill_element(E, Model), secdevaSkill_entity(E), not secdevaSkill_hasDescription(E).

childResult(Model, E, "boundaryWithoutType") :-
    result(Model), secdevaSkill_type(E, "secdeva/cardTypes/trustBoundary"),
    not field(E, "secdeva/fieldTypes/trustBoundaryType", _).

childResult(Model, E, "outsidePartyInTechnicalBoundary") :-
    result(Model), secdevaSkill_element(E, Model), secdeva_externalEntity(E),
    secdeva_insideTechnicalBoundary(E, _).

secdevaSkill_dataflowEnd(E) :- link(E, _, "secdeva/linkTypes/dataflow", _), secdevaSkill_element(E, _).
secdevaSkill_dataflowEnd(O) :- link(_, D, "secdeva/linkTypes/dataflow", _), secdeva_dataflowOwner(D, O), secdevaSkill_element(O, _).
% a system has dataflows when its components have them
secdevaSkill_dataflowEnd(P) :- secdevaSkill_dataflowEnd(C), ancestor(C, P), secdevaSkill_element(P, _).
childResult(Model, E, "withoutDataflows") :-
    result(Model), secdevaSkill_element(E, Model), secdevaSkill_entity(E), not secdevaSkill_dataflowEnd(E).

childResult(Model, (S, D, T), "undescribedDataflows") :-
    result(Model), secdevaSkill_element(S, Model), link(S, D, "secdeva/linkTypes/dataflow"),
    not link(S, D, "secdeva/linkTypes/dataflow", _), T = "".
field((S, D, T), "sourceTitle", Title) :- childResult(_, (S, D, T), "undescribedDataflows"), field(S, "title", Title).
field((S, D, T), "destinationTitle", Title) :- childResult(_, (S, D, T), "undescribedDataflows"), field(D, "title", Title).
