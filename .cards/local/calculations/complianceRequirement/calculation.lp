% secdeva_complianceRequirement(Requirement) means that Requirement is an external
% compliance requirement from a regulation, a standard or a contract.
%
% Two card types are compliance requirements. ismsa/cardTypes/complianceRequirement
% tracks adoption through its own workflow, while
% ismsa/cardTypes/assessedComplianceRequirement is scoped in or out and then assessed
% automatically from the cards that implement it. Rules that reason about compliance
% requirements as such should bind through this predicate so that they cover both.
%
% This reads field/3 rather than base_projectCardType/2 on purpose. Requirements are
% shipped in the templates of framework modules, and the process diagram and the
% requirements summary are rendered on those template cards as well as on the project
% cards created from them, so the predicate has to hold for template cards too. Rules
% that must only see project cards, such as register membership, bind the project
% separately.

secdeva_complianceRequirement(Requirement) :-
    field(Requirement, "cardType", "ismsa/cardTypes/complianceRequirement").

secdeva_complianceRequirement(Requirement) :-
    field(Requirement, "cardType", "ismsa/cardTypes/assessedComplianceRequirement").
