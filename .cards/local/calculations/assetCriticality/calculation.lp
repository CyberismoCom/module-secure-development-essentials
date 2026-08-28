% Assets of a development project that are assessed for criticality.
%
% The rules are limited to cards under a development project, so that they do not
% leak to cards of the same type elsewhere in a project tree.

secdeva_criticalityAssetCardType("secdeva/cardTypes/process").
secdeva_criticalityAssetCardType("secdeva/cardTypes/dataStore").
secdeva_criticalityAssetCardType("secdeva/cardTypes/interface").
secdeva_criticalityAssetCardType("secdeva/cardTypes/product").

secdeva_criticalityAsset(Card) :-
    secdeva_criticalityAssetCardType(CardType),
    base_projectCardType(Card, CardType),
    secdeva_closestProject(Card, Project),
    base_projectCardType(Project, "secdeva/cardTypes/project2").

% The asset cards of the ISMS essentials module follow the same model. They already
% carry the criticality fields, and the asset control of the ISMS essentials module
% has been switched off for them in the assets calculation.

secdeva_criticalityAsset(Card) :- secdeva_ismsAsset(Card).

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

% Mandatory criticality fields
%
% The asset register of a development project defines which criticality fields are
% required for the assets of that project. When the field has not been set on the
% asset register, setting the criticality of an asset is not required.
%
% Products are left out on purpose: the solution structure register can hold a long
% tail of third-party components, and assessing each of them separately would not
% pay for itself.

secdeva_criticalityRequirement(Project, Requirement) :-
    base_projectCardType(Project, "secdeva/cardTypes/project2"),
    secdeva_closestProject(Register, Project),
    field(Register, "base/fieldTypes/identifier", "secdeva_register_assets"),
    field(Register, "secdeva/fieldTypes/assetCriticalityRequirement", Requirement).

% The overall criticality is required both when only the overall criticality is
% required and when all of the criticality fields are required.

secdeva_criticalityOverallRequired(Asset) :-
    secdeva_criticalityAsset(Asset),
    not base_projectCardType(Asset, "secdeva/cardTypes/product"),
    secdeva_closestProject(Asset, Project),
    secdeva_criticalityRequirement(Project, "overallRequired").

secdeva_criticalityOverallRequired(Asset) :-
    secdeva_criticalityAsset(Asset),
    not base_projectCardType(Asset, "secdeva/cardTypes/product"),
    secdeva_closestProject(Asset, Project),
    secdeva_criticalityRequirement(Project, "allRequired").

% All of the criticality dimensions are required only when the asset register asks
% for all of the criticality fields. "Not applicable" is an accepted answer, so a
% dimension that is not relevant for the asset can be recorded as such.

secdeva_criticalityAllRequired(Asset) :-
    secdeva_criticalityAsset(Asset),
    not base_projectCardType(Asset, "secdeva/cardTypes/product"),
    secdeva_closestProject(Asset, Project),
    secdeva_criticalityRequirement(Project, "allRequired").

policyCheckFailure(Asset, "Assets", "'Overall asset criticality' is a required field", "The overall criticality has not been defined for this asset. Set this field, or set the criticality of confidentiality, integrity, availability or health, safety and the environment to have the overall criticality derived from them.", "ismsa/fieldTypes/assetCriticalityForOperations") :-
    secdeva_criticalityOverallRequired(Asset),
    not field(Asset, "ismsa/fieldTypes/assetCriticalityForOperations", _).

policyCheckFailure(Asset, "Assets", "'Criticality of confidentiality' is a required field", "The criticality of confidentiality has not been defined for this asset. Set this field, or set it to 'Not applicable' if confidentiality is not relevant for this asset.", "ismsa/fieldTypes/assetConfidentiality") :-
    secdeva_criticalityAllRequired(Asset),
    not field(Asset, "ismsa/fieldTypes/assetConfidentiality", _).

policyCheckFailure(Asset, "Assets", "'Criticality of integrity' is a required field", "The criticality of integrity has not been defined for this asset. Set this field, or set it to 'Not applicable' if integrity is not relevant for this asset.", "ismsa/fieldTypes/assetIntegrity") :-
    secdeva_criticalityAllRequired(Asset),
    not field(Asset, "ismsa/fieldTypes/assetIntegrity", _).

policyCheckFailure(Asset, "Assets", "'Criticality of availability' is a required field", "The criticality of availability has not been defined for this asset. Set this field, or set it to 'Not applicable' if availability is not relevant for this asset.", "ismsa/fieldTypes/assetAvailability") :-
    secdeva_criticalityAllRequired(Asset),
    not field(Asset, "ismsa/fieldTypes/assetAvailability", _).

policyCheckFailure(Asset, "Assets", "'Criticality for health, safety and environment (HSE)' is a required field", "The criticality for health, safety and the environment has not been defined for this asset. Set this field, or set it to 'Not applicable' if this asset has no health, safety or environmental relevance.", "ismsa/fieldTypes/assetHse") :-
    secdeva_criticalityAllRequired(Asset),
    not field(Asset, "ismsa/fieldTypes/assetHse", _).
