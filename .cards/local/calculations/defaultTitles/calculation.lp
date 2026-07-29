% secdeva_defaultTitle(Identifier, Prefix) defines the beginning of the title
% when creating a card with a certain base/fieldTypes/identifier.
% The title is formed by appending the name of the project to the prefix

% secdeva_defaultTitleWithDate(Identifier, Prefix) defines the beginning of the title
% when creating a card with a certain base/fieldTypes/identifier.
% The title is formed by the prefix to today's date and then appending the name of the project


secdeva_defaultTitle("secdeva_test_basic-input-validation", "Basic input validation test for ").
secdeva_defaultTitle("secdeva_document_business-context-analysis", "Business context analysis for ").
secdeva_defaultTitleWithDate("secdeva_review_use-of-cryptography", "Review of the use of cryptography - ").
secdeva_defaultTitleWithDate("secdeva_review_manage-defects", "Review of defect management - ").
secdeva_defaultTitle("secdeva_document_design-specification", "Design specification - ").
secdeva_defaultTitleWithDate("secdeva_review_protect-environments", "Review of environment protection for ").
secdeva_defaultTitle("secdeva_test_error-handling", "Error handling test for ").
secdeva_defaultTitleWithDate("secdeva_test_known-vulnerability", "Known vulnerability scanning of ").
secdeva_defaultTitle("secdeva_document_configuration-management-plan", "Configuration management plan for ").
secdeva_defaultTitleWithDate("secdeva_review_manual-code-review", "Review of manual code review practices - ").
secdeva_defaultTitleWithDate("secdeva_review_static-code-analysis", "Review of static code analysis - ").
secdeva_defaultTitle("secdeva_document_security-context", "Security context for ").
secdeva_defaultTitleWithDate("secdeva_review_requirement-management", "Review of security requirement management for ").
secdeva_defaultTitle("secdeva_test_security-requirements", "Security requirement test for ").
secdeva_defaultTitleWithDate("secdeva_review_vulnerability-management", "Vulnerability management for ").
secdeva_defaultTitle("secdeva_test_threat-mitigation", "Threat mitigation test for ").
secdeva_defaultTitle("secdeva_document_threat-model", "Threat model for ").
secdeva_defaultTitle("secdeva_document_dataflow-model", "Dataflow model for ").
secdeva_defaultTitleWithDate("secdeva_review_software-update-management", "Review of software update management for ").
secdeva_defaultTitle("secdeva_review_project-role-assignments", "Role assignments - ").
secdeva_defaultTitleWithDate("secdeva_review_project-structure", "Project structure review - ").
secdeva_defaultTitleWithDate("secdeva_review_competence", "Competence review - ").
secdeva_defaultTitleWithDate("secdeva_review_periodic", "Periodic review for ").
secdeva_defaultTitleWithDate("secdeva_review_3rd-party-technologies", "Review of 3rd party technologies - ").
secdeva_defaultTitleWithDate("secdeva_review_risk-management", "Review of risk management - ").
secdeva_defaultTitleWithDate("secdeva_review_interfaces", "Review of interfaces - ").

onTransitionSetField(
    Card,
    "Create",
    Card,
    "title", @concatenate(Prefix, ProjectName)
) :-
    field(Card, "base/fieldTypes/identifier", Identifier),
    secdeva_defaultTitle(Identifier, Prefix),
    secdeva_closestProject(Card, Project),
    field(Project, "title", ProjectName).

onTransitionSetField(
    Card,
    "Create",
    Card,
    "title", @concatenate(@today, " ", Prefix, ProjectName)
) :-
    field(Card, "base/fieldTypes/identifier", Identifier),
    secdeva_defaultTitleWithDate(Identifier, Prefix),
    secdeva_closestProject(Card, Project),
    field(Project, "title", ProjectName).
