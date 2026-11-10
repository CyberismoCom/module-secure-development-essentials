% Threat modelling skills

% The overview skill is available everywhere. The other skills are enabled for
% each threat model and dataflow model, and for each element of their dataflow
% diagrams, so that an assistant gets instructions for the model it works on.

enableSkill("secdeva/skills/threatModelling").

secdeva_modelSkill("secdeva/skills/dataflowModel").
secdeva_modelSkill("secdeva/skills/interfaces").
secdeva_modelSkill("secdeva/skills/dataflowDiagrams").
secdeva_modelSkill("secdeva/skills/threatIdentification").

enableSkill(Skill, Card) :- secdeva_modelSkill(Skill), secdeva_modelOf(Card, _).

% Dataflow models and their elements

secdeva_dataflowModel(Model) :- base_projectCardType(Model, "secdeva/cardTypes/threatModel").
secdeva_dataflowModel(Model) :- base_projectCardType(Model, "secdeva/cardTypes/dataflowModel").

secdeva_dataflowElementType("secdeva/cardTypes/process").
secdeva_dataflowElementType("secdeva/cardTypes/dataStore").
secdeva_dataflowElementType("secdeva/cardTypes/trustBoundary").
secdeva_dataflowElementType("secdeva/cardTypes/external").
secdeva_dataflowElementType("secdeva/cardTypes/person").
secdeva_dataflowElementType("secdeva/cardTypes/interface").
secdeva_dataflowElementType("secdeva/cardTypes/group").
secdeva_dataflowElement(Card) :- secdeva_dataflowElementType(Type), base_projectCardType(Card, Type).

% secdeva_modelOf(Card, Model): Model is the nearest dataflow model that contains
% Card. A model is its own model.
secdeva_modelOf(Model, Model) :- secdeva_dataflowModel(Model).
secdeva_modelOf(Card, Model) :-
    secdeva_dataflowElement(Card), ancestor(Card, Model), secdeva_dataflowModel(Model),
    not secdeva_modelBetween(Card, Model).
secdeva_modelBetween(Card, Model) :-
    secdeva_dataflowElement(Card), ancestor(Card, Middle), ancestor(Middle, Model),
    secdeva_dataflowModel(Middle), secdeva_dataflowModel(Model).

% Trust boundary crossings

% secdeva_technicalBoundary and secdeva_insideTechnicalBoundary are defined in
% the calculation secdeva/calculations/dataflows.

secdeva_outsideParty(Card) :- base_projectCardType(Card, "secdeva/cardTypes/person").
secdeva_outsideParty(Card) :- base_projectCardType(Card, "secdeva/cardTypes/external").

% secdeva_dataflowOwner(Card, Element): a dataflow to Card is a dataflow to
% Element. An interface belongs to the element above it.
secdeva_dataflowOwner(Card, Card) :-
    secdeva_dataflowElement(Card), not base_projectCardType(Card, "secdeva/cardTypes/interface").
secdeva_dataflowOwner(Interface, Owner) :-
    base_projectCardType(Interface, "secdeva/cardTypes/interface"),
    parent(Interface, Parent), secdeva_dataflowOwner(Parent, Owner).

% secdeva_crossingDataflow(Source, Destination, Title): the dataflow crosses a
% trust boundary. It does, when either end is a person or an external entity,
% or when the ends are not inside the same technical trust boundaries.
secdeva_crossingDataflow(Source, Destination, Title) :-
    link(Source, Destination, "secdeva/linkTypes/dataflow", Title),
    secdeva_outsideParty(Source).
secdeva_crossingDataflow(Source, Destination, Title) :-
    link(Source, Destination, "secdeva/linkTypes/dataflow", Title),
    secdeva_dataflowOwner(Destination, Owner), secdeva_outsideParty(Owner).
secdeva_crossingDataflow(Source, Destination, Title) :-
    link(Source, Destination, "secdeva/linkTypes/dataflow", Title),
    secdeva_insideTechnicalBoundary(Source, Boundary),
    not secdeva_insideTechnicalBoundary(Destination, Boundary).
secdeva_crossingDataflow(Source, Destination, Title) :-
    link(Source, Destination, "secdeva/linkTypes/dataflow", Title),
    secdeva_insideTechnicalBoundary(Destination, Boundary),
    not secdeva_insideTechnicalBoundary(Source, Boundary).
