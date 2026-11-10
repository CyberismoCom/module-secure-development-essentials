% Dataflows and trust boundaries

% Physical and organisational trust boundaries, such as a site, may contain
% persons and external entities. Only the other, technical trust boundaries,
% such as network zones, separate the system from the outside.
secdeva_technicalBoundary(Boundary) :-
    base_projectCardType(Boundary, "secdeva/cardTypes/trustBoundary"),
    not field(Boundary, "secdeva/fieldTypes/trustBoundaryType", "physical"),
    not field(Boundary, "secdeva/fieldTypes/trustBoundaryType", "organisational").
secdeva_insideTechnicalBoundary(Card, Boundary) :-
    ancestor(Card, Boundary), secdeva_technicalBoundary(Boundary).
secdeva_insideSystem(Card) :- secdeva_insideTechnicalBoundary(Card, _).
secdeva_insideAnyBoundary(Card) :-
    ancestor(Card, Boundary), base_projectCardType(Boundary, "secdeva/cardTypes/trustBoundary").

% secdeva_dataflow(Dataflow): Dataflow is (Source, Destination, Title)
secdeva_dataflow((Source, Destination, Title)) :-
    link(Source, Destination, "secdeva/linkTypes/dataflow", Title).

% secdeva_externalDataflow(Dataflow, Direction, Inside, Outside): the dataflow
% connects an element inside a technical trust boundary with an element outside
% all of them. Direction is "Inbound" or "Outbound" as seen from the system.
secdeva_externalDataflow((A, B, Title), "Outbound", A, B) :-
    secdeva_dataflow((A, B, Title)), secdeva_insideSystem(A), not secdeva_insideSystem(B).
secdeva_externalDataflow((A, B, Title), "Inbound", B, A) :-
    secdeva_dataflow((A, B, Title)), not secdeva_insideSystem(A), secdeva_insideSystem(B).

% secdeva_internalDataflow(Dataflow): the other dataflows whose ends are both
% inside a trust boundary of any type, such as the dataflows between two zones,
% or between two elements that are only inside a site.
secdeva_internalDataflow((A, B, Title)) :-
    secdeva_dataflow((A, B, Title)), secdeva_insideAnyBoundary(A), secdeva_insideAnyBoundary(B),
    not secdeva_externalDataflow((A, B, Title), _, _, _).
