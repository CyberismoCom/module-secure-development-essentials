% Threat model components are assets that may be affected by security issues

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/process").

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/dataStore").

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/person").

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/trustBoundary").

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/external").

secdeva_threatModelComponent(Card) :-
    field(Card, "cardType", "secdeva/cardTypes/interface").

link(Asset, SecurityIssue, "ismsa/linkTypes/presentsRisk") :-
    parent(SecurityIssue, Asset),
    field(SecurityIssue, "cardType", "secdeva/cardTypes/securityIssue"),
    secdeva_threatModelComponent(Asset).

% Defining ismsa_asset for threat model components makes them work correctly in assets-risks-controls diagrams

ismsa_asset(Card, "Process") :-
    field(Card, "cardType", "secdeva/cardTypes/process").

ismsa_asset(Card, "Data store") :-
    field(Card, "cardType", "secdeva/cardTypes/dataStore").

ismsa_asset(Card, "Person") :-
    field(Card, "cardType", "secdeva/cardTypes/person").

ismsa_asset(Card, "Trust boundary") :-
    field(Card, "cardType", "secdeva/cardTypes/trustBoundary").

ismsa_asset(Card, "External entity") :-
    field(Card, "cardType", "secdeva/cardTypes/external").

ismsa_asset(Card, "Interface") :-
    field(Card, "cardType", "secdeva/cardTypes/interface").
