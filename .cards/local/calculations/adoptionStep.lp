% Copyright © Cyberismo Ltd and contributors 2025
%
% License: https://github.com/CyberismoCom/module-secure-development-essentials/blob/main/LICENSE
% The use of the Cyberismo trademark: https://cyberismo.com/trademark-policy/
% This content is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.

hiddenInTreeView(Card) :-
    card(Card),
    secdeva_closestProject(Card, Project),
    base_greaterAdoptionStep(Card, Project).

policyCheckFailure(
    Project,
    "Secure development",
    "Adoption step justification missing",
    "The target adoption step has been set to None, which indicates that secure development is not applicable. Enter a justification in the Adoption step justification field.") :-
        field(Project, "cardType", "secdeva/cardTypes/project"),
        not field(Project, "base/fieldTypes/adoptionStep", _),
        not field(Project, "secdeva/fieldTypes/adoptionStepJustification", _).

