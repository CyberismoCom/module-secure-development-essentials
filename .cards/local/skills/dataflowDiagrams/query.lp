selectAll.

result(Model) :- secdeva_modelOf({{cardKey}}, Model).

secdevaSkill_element(Element, Model) :- secdeva_modelOf({{cardKey}}, Model), secdeva_modelOf(Element, Model), Element != Model.
secdevaSkill_entity(E) :- secdevaSkill_element(E, _), base_projectCardType(E, "secdeva/cardTypes/process").
secdevaSkill_entity(E) :- secdevaSkill_element(E, _), base_projectCardType(E, "secdeva/cardTypes/dataStore").
secdevaSkill_entity(E) :- secdevaSkill_element(E, _), base_projectCardType(E, "secdeva/cardTypes/external").
secdevaSkill_entity(E) :- secdevaSkill_element(E, _), base_projectCardType(E, "secdeva/cardTypes/person").

resultField(Model, "layered", "yes") :- result(Model), field(Model, "secdeva/fieldTypes/diagramLayout", "zoneLayers").

secdevaSkill_label(E, L) :- secdevaSkill_entity(E), label(E, L).
childResult(Model, (Model, L), "labels") :- result(Model), secdevaSkill_label(_, L).
field((Model, L), "label", L) :- childResult(Model, (Model, L), "labels").
field((Model, L), "count", N) :- childResult(Model, (Model, L), "labels"), N = #count { E : secdevaSkill_label(E, L) }.

secdevaSkill_labelled(E) :- secdevaSkill_label(E, _).
% a system (a process with components) is shown through its labelled components
secdevaSkill_system(E) :- secdevaSkill_entity(E), parent(C, E), secdevaSkill_entity(C).
childResult(Model, E, "unlabelled") :-
    result(Model), secdevaSkill_entity(E), not secdevaSkill_labelled(E), not secdevaSkill_system(E).

childResult(Model, Page, "pages") :-
    result(Model), parent(Page, Model), base_projectCardType(Page, "base/cardTypes/page").
