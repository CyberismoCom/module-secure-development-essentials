field(X, "base/fieldTypes/progress", (100 * (Ok + NotRequired) + 95 * ToBeVerified + 50 * Adopting + 25 * Planned ) / Total) :-
    field(X, "ismsa/fieldTypes/progress", "compliance-progress"),
    Total = #count {
        card(Requirement):
        base_projectCardType(Requirement, "ismsa/cardTypes/complianceRequirement"),
        ancestor(Requirement, X),
        not hiddenInTreeView(Requirement)
    },
    Total > 0,
    Ok = #count {
        card(Requirement):
        base_projectCardType(Requirement, "ismsa/cardTypes/complianceRequirement"),
        ancestor(Requirement, X),
        field(Requirement, "workflowState", "Closed as compliant"),
        not hiddenInTreeView(Requirement)
    },
    Planned = #count {
        card(Requirement):
        base_projectCardType(Requirement, "ismsa/cardTypes/complianceRequirement"),
        ancestor(Requirement, X),
        field(Requirement, "workflowState", "Planned"),
        not hiddenInTreeView(Requirement)
    },
    Adopting = #count {
        card(Requirement):
        base_projectCardType(Requirement, "ismsa/cardTypes/complianceRequirement"),
        ancestor(Requirement, X),
        field(Requirement, "workflowState", "Adopting"),
        not hiddenInTreeView(Requirement)
    },
    ToBeVerified = #count {
        card(Requirement):
        base_projectCardType(Requirement, "ismsa/cardTypes/complianceRequirement"),
        ancestor(Requirement, X),
        field(Requirement, "workflowState", "To be verified"),
        not hiddenInTreeView(Requirement)
    },
    NotRequired = #count {
        card(Requirement):
        base_projectCardType(Requirement, "ismsa/cardTypes/complianceRequirement"),
        ancestor(Requirement, X),
        field(Requirement, "workflowState", "Closed as not applicable"),
        not hiddenInTreeView(Requirement)
    }.

%
% The compliance score of a card whose progress label is "compliance-score" is the
% share of the assessed compliance requirements below it that have been assessed as OK.
%
% Requirements that have been marked out of scope are left out of the calculation
% altogether, rather than counted as compliant: descoping a requirement must not raise
% the score. Requirements that are still open are counted in the denominator only.
%

field(X, "base/fieldTypes/progress", 100 * Ok / InScope) :-
    field(X, "ismsa/fieldTypes/progress", "compliance-score"),
    InScope = #count {
        card(Requirement):
        ismsa_assessedRequirementInScope(Requirement),
        ancestor(Requirement, X),
        not hiddenInTreeView(Requirement)
    },
    InScope > 0,
    Ok = #count {
        card(Requirement):
        ismsa_assessedRequirementInScope(Requirement),
        ancestor(Requirement, X),
        field(Requirement, "base/fieldTypes/assessment", "ok"),
        not hiddenInTreeView(Requirement)
    }.
