secdeva_externalEntity(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/external").

secdeva_externalEntity(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/person").

secdeva_interfaceOrPhysicalConnection(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/interface").

secdeva_interfaceOrPhysicalConnection(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/physicalConnection").

field(Card, "secdeva/fieldTypes/isExternal", "yes") :-
    secdeva_interfaceOrPhysicalConnection(Card),
    link(Source, Card, "secdeva/linkTypes/dataflow", _),
    secdeva_externalEntity(Source).

field(Card, "secdeva/fieldTypes/isExternal", "no") :-
    secdeva_interfaceOrPhysicalConnection(Card),
    not secdeva_externalEntity(Source) :
    link(Source, Card, "secdeva/linkTypes/dataflow", _).

field(Card, "secdeva/fieldTypes/isExternal", "noInfo") :-
    secdeva_interfaceOrPhysicalConnection(Card),
    not link(_, Card, "secdeva/linkTypes/dataflow", _).

field(Card, "secdeva/fieldTypes/crossesTrustBoundary", "noInfo") :-
    secdeva_interfaceOrPhysicalConnection(Card),
    not link(_, Card, "secdeva/linkTypes/dataflow", _).

field(Card, "secdeva/fieldTypes/crossesTrustBoundary", "yes") :-
    secdeva_interfaceOrPhysicalConnection(Card),
    link(Source, Card, "secdeva/linkTypes/dataflow", _),
    field(TrustBoundary, "cardType", "secdeva/cardTypes/trustBoundary"),
    ancestor(Card, TrustBoundary),
    not ancestor(Source, TrustBoundary).

field(Card, "secdeva/fieldTypes/crossesTrustBoundary", "no") :-
    secdeva_interfaceOrPhysicalConnection(Card),
    link(_, Card, "secdeva/linkTypes/dataflow", _),
    ancestor(Source, TrustBoundary) :
    link(Source, Card, "secdeva/linkTypes/dataflow", _),
    field(TrustBoundary, "cardType", "secdeva/cardTypes/trustBoundary"),
    ancestor(Card, TrustBoundary).
