% Shared predicate: base_projectCardType/2, the card type of a card in the
% project. Use it and not field(Card, "cardType", CardType) in rules about the
% cards of a project, because template cards do not get it. The predicate card
% in the base documentation, under "For module authors" > "Shared predicates",
% says more.
base_projectCardType(Card, CardType) :-
    projectCard(Card),
    field(Card, "cardType", CardType).
