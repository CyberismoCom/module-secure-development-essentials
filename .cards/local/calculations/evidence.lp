% secdeva_evidence declares that a certain identifier is evidence of a certain task:
% secdeva_evidence(TaskIdentifier, EvidenceIdentifier, EvidenceTitle)

link(Evidence, Task, "secdeva/linkTypes/evidences") :-
    secdeva_closestProject(Task, Project),
    secdeva_closestProject(Evidence, Project),
    secdeva_evidence(TaskIdentifier, EvidenceIdentifier, _),
    field(Task, "base/fieldTypes/identifier", TaskIdentifier),
    field(Evidence, "base/fieldTypes/identifier", EvidenceIdentifier).

secdeva_evidence("secdeva_control_threat-models", "secdeva_document_threat-model", "Threat model").
secdeva_evidence("secdeva_control_assign-people-to-project-roles", "secdeva_document_project-role-assignments", "Project role assignments").
secdeva_evidence("secdeva_control_analyse-business-context", "secdeva_document_business-context-analysis", "Business context analysis").
secdeva_evidence("secdeva_control_product-security-context", "", "Product security context").
secdeva_evidence("secdeva_control_interface-specifications", "secdeva_document_interface", "Interface description").
secdeva_evidence("secdeva_control_threat-mitigation-testing", "secdeva_test_threat-mitigation", "Review of \nthreat mitigation testing").
secdeva_evidence("secdeva_control_security-requirements", "secdeva_document_security-requirement-specification", "Security requirements specification").
secdeva_evidence("secdeva_control_security-requirement-testing", "secdeva_test_security-requirements", "Review of \nsecurity requirement testing").
secdeva_evidence("secdeva_control_3rd-party-technologies", "secdeva_document_technology", "Technology description").
secdeva_evidence("secdeva_control_vulnerability-management", "secdeva_review_vulnerability-management", "Review of 3rd party \nvulnerability management").
secdeva_evidence("secdeva_control_software-update-management", "secdeva_review_software-update-management", "Review of 3rd party \nsoftware update management").
