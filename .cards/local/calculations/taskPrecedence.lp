
link(First, Second, "secdeva/linkTypes/precedes") :-
    not hiddenInTreeView(First),
    not hiddenInTreeView(Second),
    secdeva_closestProject(First, Project),
    secdeva_closestProject(Second, Project),
    field(First, "base/fieldTypes/identifier", FirstIdentifier),
    field(Second, "base/fieldTypes/identifier", SecondIdentifier),
    secdeva_precedingTask(FirstIdentifier, SecondIdentifier).

secdeva_precedingTask(
    "secdeva_control_assign-people-to-project-roles",
    "secdeva_control_ensure-competence").

secdeva_precedingTask(
    "secdeva_control_business-context-analysis",
    "secdeva_control_high-level-risks").

secdeva_precedingTask(
    "secdeva_control_product-security-context",
    "secdeva_control_threat-models").

secdeva_precedingTask(
    "secdeva_control_product-security-context",
    "secdeva_control_threat-models").

secdeva_precedingTask(
    "secdeva_control_threat-models",
    "secdeva_control_threat-mitigation-testing").

secdeva_precedingTask(
    "secdeva_control_threat-models",
    "secdeva_control_security-requirements").

secdeva_precedingTask(
    "secdeva_control_high-level-risks",
    "secdeva_control_security-requirements").

secdeva_precedingTask(
    "secdeva_control_security-requirements",
    "secdeva_control_security-requirement-testing").

secdeva_precedingTask(
    "secdeva_control_3rd-party-technologies",
    "secdeva_control_vulnerability-management").

secdeva_precedingTask(
    "secdeva_control_3rd-party-technologies",
    "secdeva_control_software-update-management").

