hiddenInTreeView(Risk) :-
  ancestor(Risk, RiskRegister),
  field(RiskRegister, "base/fieldTypes/identifier", "secdeva_register_risks"),
  field(Risk, "workflowStateCategory", "closed").

% The acceptable risk level of the risk register of the project applies to the
% risks of the project. The ismsa rules read the level only from the ISMS risk
% register (ismsa/cardTypes/riskRegister), so secdeva applies the same checks
% to the risk register of a development project.

secdeva_acceptableRiskLevel(Risk, AcceptableRiskLevel) :-
  secdeva_registerMember(Risk, Register),
  base_projectCardType(Register, "secdeva/cardTypes/riskRegister"),
  field(Register, "ismsa/fieldTypes/acceptableRiskLevel", AcceptableRiskLevel).

% The titles and messages are the same as in ismsa/calculations/riskControl.

policyCheckFailure(Risk, "ISMS", "Controls must be identified unless risk level is acceptable",
    "Controls have not been identified, even though the initial risk level is not acceptable. Link this risk to control(s)/task(s) using the 'is mitigated by' link type.") :-
  secdeva_acceptableRiskLevel(Risk, AcceptableRiskLevel),
  field(Risk, "ismsa/fieldTypes/riskInitialRisk", InitialRisk),
  ismsa_riskLessThan(AcceptableRiskLevel, InitialRisk),
  not link(_, Risk, "ismsa/linkTypes/mitigates").

policyCheckFailure(Risk, "ISMS", "Risks can only be accepted if the risk level is acceptable",
    "This risk has been accepted, even though the residual risk is higher than the acceptable risk level. Implement more controls to lower the residual risk or change the risk to the status 'Needs monitoring'.") :-
  secdeva_acceptableRiskLevel(Risk, AcceptableRiskLevel),
  field(Risk, "workflowState", "Closed as accepted"),
  field(Risk, "ismsa/fieldTypes/riskResidualRisk", ResidualRisk),
  ismsa_riskLessThan(AcceptableRiskLevel, ResidualRisk).
