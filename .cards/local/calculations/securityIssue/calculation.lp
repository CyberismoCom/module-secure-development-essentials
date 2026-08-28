hiddenInTreeView(Issue) :-
  ancestor(Issue, SecurityIssueRegister),
  field(SecurityIssueRegister, "base/fieldTypes/identifier", "secdeva_register_security-issues").  

transitionDenied(
    Issue,
    "Analyse",
    "Set severity before analysing the issue"
    ) :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        not field(Issue, "secdeva/fieldTypes/severity", _).

policyCheckFailure(Issue, "Secure development", "Severity is required", "Severity is a required field.") :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        not field(Issue, "workflowStateCategory", "initial"),
        not field(Issue, "workflowState", "Closed as duplicate"),
        not field(Issue, "workflowState", "Closed as not applicable"),
        not field(Issue, "secdeva/fieldTypes/severity", _).

transitionDenied(
    Issue,
    "Analyse",
    "Set root cause category before analysing the issue"
    ) :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        not field(Issue, "secdeva/fieldTypes/rootCauseCategory", _).

policyCheckFailure(Issue, "Secure development", "Root cause category is required", "Root cause category is a required field.") :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        not field(Issue, "workflowStateCategory", "initial"),
        not field(Issue, "workflowState", "Closed as duplicate"),
        not field(Issue, "workflowState", "Closed as not applicable"),
        not field(Issue, "secdeva/fieldTypes/rootCauseCategory", _).

transitionDenied(
    Issue,
    "Analyse",
    "Set the Reporting field before analysing the issue"
    ) :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        not field(Issue, "secdeva/fieldTypes/reporting", _).

policyCheckFailure(Issue, "Secure development", "Reporting is required", "Reporting is a required field.") :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        not field(Issue, "workflowStateCategory", "initial"),
        not field(Issue, "workflowState", "Closed as duplicate"),
        not field(Issue, "workflowState", "Closed as not applicable"),
        not field(Issue, "secdeva/fieldTypes/reporting", _).

transitionDenied(
    Issue,
    "Fix required",
    "Set the Strategy field before transitioning to 'Fix required'"
    ) :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        not field(Issue, "secdeva/fieldTypes/strategy", _).

policyCheckFailure(Issue, "Secure development", "Strategy is required", "Strategy is a required field.") :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        field(Issue, "workflowState", "Fix required"),
        not field(Issue, "secdeva/fieldTypes/strategy", _).

policyCheckFailure(Issue, "Secure development", "Strategy is required", "Strategy is a required field.") :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        field(Issue, "workflowState", "Fix deferred"),
        not field(Issue, "secdeva/fieldTypes/strategy", _).

policyCheckFailure(Issue, "Secure development", "Strategy is required", "Strategy is a required field.") :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        field(Issue, "workflowState", "In progress"),
        not field(Issue, "secdeva/fieldTypes/strategy", _).

policyCheckFailure(Issue, "Secure development", "Strategy is required", "Strategy is a required field.") :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        field(Issue, "workflowState", "To be verified"),
        not field(Issue, "secdeva/fieldTypes/strategy", _).

policyCheckFailure(Issue, "Secure development", "Strategy is required", "Strategy is a required field.") :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        field(Issue, "workflowState", "Closed as verified"),
        not field(Issue, "secdeva/fieldTypes/strategy", _).

secdeva_severityLessThan("none", "low").
secdeva_severityLessThan("none", "medium").
secdeva_severityLessThan("none", "high").
secdeva_severityLessThan("none", "critical").
secdeva_severityLessThan("low", "medium").
secdeva_severityLessThan("low", "high").
secdeva_severityLessThan("low", "critical").
secdeva_severityLessThan("medium", "high").
secdeva_severityLessThan("medium", "critical").
secdeva_severityLessThan("high", "critical").

% Thresholds for deferring a fix and for accepting the risk.
% In the current project structure the thresholds are defined on the security
% issue register; in the deprecated structure they are defined on the project card.

secdeva_deferrableSeverity(Issue, DeferrableSeverity) :-
        secdeva_registerMember(Issue, Register),
        base_projectCardType(Register, "secdeva/cardTypes/securityIssueRegister"),
        field(Register, "secdeva/fieldTypes/deferrableSeverity", DeferrableSeverity).

secdeva_deferrableSeverity(Issue, DeferrableSeverity) :-
        secdeva_closestProject(Issue, Project),
        base_projectCardType(Project, "secdeva/cardTypes/project"),
        field(Project, "secdeva/fieldTypes/deferrableSeverity", DeferrableSeverity).

secdeva_acceptableSeverity(Issue, AcceptableSeverity) :-
        secdeva_registerMember(Issue, Register),
        base_projectCardType(Register, "secdeva/cardTypes/securityIssueRegister"),
        field(Register, "secdeva/fieldTypes/acceptableSeverity", AcceptableSeverity).

secdeva_acceptableSeverity(Issue, AcceptableSeverity) :-
        secdeva_closestProject(Issue, Project),
        base_projectCardType(Project, "secdeva/cardTypes/project"),
        field(Project, "secdeva/fieldTypes/acceptableSeverity", AcceptableSeverity).

% The severity of the issue exceeds the threshold for deferring the fix

secdeva_severityExceedsDeferrable(Issue, DeferrableSeverityDisplayValue) :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        field(Issue, "secdeva/fieldTypes/severity", Severity),
        secdeva_deferrableSeverity(Issue, DeferrableSeverity),
        field(("secdeva/fieldTypes/deferrableSeverity", DeferrableSeverity), "enumDisplayValue", DeferrableSeverityDisplayValue),
        secdeva_severityLessThan(DeferrableSeverity, Severity).

% The severity of the issue exceeds the threshold for accepting the risk

secdeva_severityExceedsAcceptable(Issue, AcceptableSeverityDisplayValue) :-
        base_projectCardType(Issue, "secdeva/cardTypes/securityIssue"),
        field(Issue, "secdeva/fieldTypes/severity", Severity),
        secdeva_acceptableSeverity(Issue, AcceptableSeverity),
        field(("secdeva/fieldTypes/acceptableSeverity", AcceptableSeverity), "enumDisplayValue", AcceptableSeverityDisplayValue),
        secdeva_severityLessThan(AcceptableSeverity, Severity).

transitionDenied(
    Issue,
    "Defer fix",
    @concatenate("Cannot defer fix, because severity is not ", DeferrableSeverityDisplayValue, " or lower.")
    ) :-
        secdeva_severityExceedsDeferrable(Issue, DeferrableSeverityDisplayValue).

transitionDenied(
    Issue,
    "Accept risk",
    @concatenate("Cannot close as accepted, because severity is not ", AcceptableSeverityDisplayValue, " or lower." )
    ) :-
        secdeva_severityExceedsAcceptable(Issue, AcceptableSeverityDisplayValue).

policyCheckFailure(
    Issue,
    "Secure development",
    "Fix cannot be deferred",
    @concatenate("The fix of this issue has been deferred, but the severity is not ", DeferrableSeverityDisplayValue, " or lower. Either fix the issue or raise the deferrable severity threshold.")
    ) :-
        field(Issue, "workflowState", "Fix deferred"),
        secdeva_severityExceedsDeferrable(Issue, DeferrableSeverityDisplayValue).

policyCheckFailure(
    Issue,
    "Secure development",
    "Risk cannot be accepted",
    @concatenate("The risk of this issue has been accepted, but the severity is not ", AcceptableSeverityDisplayValue, " or lower. Either reopen and fix the issue or raise the acceptable severity threshold.")
    ) :-
        field(Issue, "workflowState", "Closed as risk accepted"),
        secdeva_severityExceedsAcceptable(Issue, AcceptableSeverityDisplayValue).
