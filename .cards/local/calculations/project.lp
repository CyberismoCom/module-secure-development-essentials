ismsa_asset(Card, "Development project") :-
    field(Card, "cardType", "secdeva/cardTypes/project").

secdeva_closestProject(Project, Project) :-
    field(Project, "cardType", "secdeva/cardTypes/project").

secdeva_closestProject(Card, Project) :-
    field(Project, "cardType", "secdeva/cardTypes/project"),
    not field(Card, "cardType", "secdeva/cardTypes/project"),
    ancestor(Card, Project),
    not field(MiddleAncestor, "cardType", "secdeva/cardTypes/project") :
    ancestor(MiddleAncestor, Project),
    ancestor(Card, MiddleAncestor).

% Backups is a mandatory field for development projects

policyCheckFailure(Asset, "ISMS", "'Backup(s)' is a required field", "'Backup(s)' has not been defined for this asset. Set this field.") :-
    field(Asset, "cardType", "secdeva/cardTypes/project"),
    not field(Asset, "ismsa/fieldTypes/assetBackups", _).

% We are storing risks in a subcard, so we need a dedicated automated link
link(DevelopmentProject, Risk, "ismsa/linkTypes/presentsRisk") :-
    field(DevelopmentProject, "cardType", "secdeva/cardTypes/project"),
    field(Risk, "cardType", "ismsa/cardTypes/risk"),
    parent(Risk, Register),
    parent(Register, DevelopmentProject).