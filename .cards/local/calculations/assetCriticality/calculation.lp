% Assets of a development project that are assessed for criticality.
%
% The rules are limited to cards under a development project, so that they do not
% leak to cards of the same type elsewhere in a project tree. The asset card types
% of the ISMS essentials module already carry the criticality fields and their own
% controls, so they are not included here.

secdeva_criticalityAssetCardType("secdeva/cardTypes/process").
secdeva_criticalityAssetCardType("secdeva/cardTypes/dataStore").
secdeva_criticalityAssetCardType("secdeva/cardTypes/interface").
secdeva_criticalityAssetCardType("secdeva/cardTypes/product").

secdeva_criticalityAsset(Card) :-
    secdeva_criticalityAssetCardType(CardType),
    base_projectCardType(Card, CardType),
    secdeva_closestProject(Card, Project),
    base_projectCardType(Project, "secdeva/cardTypes/project2").

% Overall criticality
%
% The overall criticality is the highest criticality of the individual dimensions.
% The dimensions are optional helpers for arriving at the overall criticality, and
% "Not applicable" does not contribute. The field stays overridable, so that a team
% can record the overall criticality directly, or record a different one when the
% dimensions do not tell the whole story.

secdeva_criticalityDimension(Asset, Value) :-
    secdeva_criticalityAsset(Asset),
    field(Asset, "ismsa/fieldTypes/assetConfidentiality", Value).

secdeva_criticalityDimension(Asset, Value) :-
    secdeva_criticalityAsset(Asset),
    field(Asset, "ismsa/fieldTypes/assetIntegrity", Value).

secdeva_criticalityDimension(Asset, Value) :-
    secdeva_criticalityAsset(Asset),
    field(Asset, "ismsa/fieldTypes/assetAvailability", Value).

secdeva_criticalityDimension(Asset, Value) :-
    secdeva_criticalityAsset(Asset),
    field(Asset, "ismsa/fieldTypes/assetHse", Value).

fieldCalculated(Asset, "ismsa/fieldTypes/assetCriticalityForOperations", "high") :-
    secdeva_criticalityDimension(Asset, "high"),
    base_projectCardType(Asset, CardType),
    calculatedField(CardType, "ismsa/fieldTypes/assetCriticalityForOperations").

fieldCalculated(Asset, "ismsa/fieldTypes/assetCriticalityForOperations", "medium") :-
    secdeva_criticalityDimension(Asset, "medium"),
    not secdeva_criticalityDimension(Asset, "high"),
    base_projectCardType(Asset, CardType),
    calculatedField(CardType, "ismsa/fieldTypes/assetCriticalityForOperations").

fieldCalculated(Asset, "ismsa/fieldTypes/assetCriticalityForOperations", "low") :-
    secdeva_criticalityDimension(Asset, "low"),
    not secdeva_criticalityDimension(Asset, "high"),
    not secdeva_criticalityDimension(Asset, "medium"),
    base_projectCardType(Asset, CardType),
    calculatedField(CardType, "ismsa/fieldTypes/assetCriticalityForOperations").

% Mandatory field from adoption step 2 onwards
%
% Only the overall criticality is required. The individual dimensions are optional:
% setting any of them satisfies the requirement, because the overall criticality is
% derived from them.
%
% Products are left out on purpose: the solution structure register can hold a long
% tail of third-party components, and assessing each of them separately would not
% pay for itself.

secdeva_criticalityRequired(Asset) :-
    secdeva_criticalityAsset(Asset),
    not base_projectCardType(Asset, "secdeva/cardTypes/product"),
    secdeva_closestProject(Asset, Project),
    field(Project, "base/fieldTypes/adoptionStep", "step2").

secdeva_criticalityRequired(Asset) :-
    secdeva_criticalityAsset(Asset),
    not base_projectCardType(Asset, "secdeva/cardTypes/product"),
    secdeva_closestProject(Asset, Project),
    field(Project, "base/fieldTypes/adoptionStep", "step3").

policyCheckFailure(Asset, "Assets", "'Overall asset criticality' is a required field", "The overall criticality has not been defined for this asset. Set this field, or set the criticality of confidentiality, integrity, availability or health, safety and the environment to have the overall criticality derived from them.", "ismsa/fieldTypes/assetCriticalityForOperations") :-
    secdeva_criticalityRequired(Asset),
    not field(Asset, "ismsa/fieldTypes/assetCriticalityForOperations", _).
