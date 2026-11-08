selectAll.

result(Model) :- secdeva_modelOf({{cardKey}}, Model).

secdevaSkill_element(Element, Model) :- secdeva_modelOf({{cardKey}}, Model), secdeva_modelOf(Element, Model), Element != Model.
secdevaSkill_receiver(E) :- secdevaSkill_element(E, _), base_projectCardType(E, "secdeva/cardTypes/process").
secdevaSkill_receiver(E) :- secdevaSkill_element(E, _), base_projectCardType(E, "secdeva/cardTypes/dataStore").
secdevaSkill_interface(I) :- secdevaSkill_element(I, _), base_projectCardType(I, "secdeva/cardTypes/interface").
secdevaSkill_hasInterface(E) :- secdevaSkill_receiver(E), parent(I, E), secdevaSkill_interface(I).

% elements that receive dataflows across a trust boundary, directly and not through an interface
childResult(Model, E, "needInterfaces") :-
    result(Model), secdevaSkill_receiver(E), not secdevaSkill_hasInterface(E),
    secdeva_crossingDataflow(_, E, _).

% elements that have interfaces but still receive dataflows directly
childResult(Model, (S, E, T), "bypassingDataflows") :-
    result(Model), secdevaSkill_receiver(E), secdevaSkill_hasInterface(E),
    link(S, E, "secdeva/linkTypes/dataflow", T).
field((S, E, T), "sourceTitle", Title) :- childResult(_, (S, E, T), "bypassingDataflows"), field(S, "title", Title).
field((S, E, T), "destinationTitle", Title) :- childResult(_, (S, E, T), "bypassingDataflows"), field(E, "title", Title).
field((S, E, T), "dataflow", T) :- childResult(_, (S, E, T), "bypassingDataflows").

% interfaces with missing security details
secdevaSkill_complete(I) :-
    secdevaSkill_interface(I),
    field(I, "secdeva/fieldTypes/interfaceAuthentication", _),
    field(I, "secdeva/fieldTypes/transportSecurity", _),
    field(I, "secdeva/fieldTypes/interfacePurpose", _).
% transport security does not apply to physical interfaces, such as a touch screen
secdevaSkill_complete(I) :-
    secdevaSkill_interface(I),
    field(I, "secdeva/fieldTypes/interfaceType", "physical"),
    field(I, "secdeva/fieldTypes/interfaceAuthentication", _),
    field(I, "secdeva/fieldTypes/interfacePurpose", _).
childResult(Model, I, "incompleteInterfaces") :-
    result(Model), secdevaSkill_interface(I), not secdevaSkill_complete(I).
field(I, "ownerTitle", Title) :- childResult(_, I, "incompleteInterfaces"), parent(I, O), field(O, "title", Title).

resultField(Model, "interfaceCount", N) :- result(Model), N = #count { I : secdevaSkill_interface(I) }.
