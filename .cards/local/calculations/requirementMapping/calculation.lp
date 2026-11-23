%
% Mapping facts for security requirements, compliance requirements, and controls.
%
% Extension modules (for example eucra, enisasbd, or a PBRA module) give facts
% by identifier. These rules turn the facts into links inside the development
% project, so that the cards of one project are linked to each other and not to
% the cards of another project.
%
% secdeva_refines(RefinementIdentifier, RequirementIdentifier)
%   A detailed security requirement refines a more general one, for example an own
%   component capability refines an essential security requirement.
%
% secdeva_implements(ImplementationIdentifier, RequirementIdentifier, Description)
%   A control or a security requirement implements a compliance requirement, for
%   example an essential security requirement implements an ENISA playbook.
%   Description says which part of the requirement it implements. It can be "".
%

%
% Refinements
%

link(Refinement, Requirement, "secdeva/linkTypes/refines") :-
  secdeva_refines(RefinementIdentifier, RequirementIdentifier),
  field(Refinement, "base/fieldTypes/identifier", RefinementIdentifier),
  field(Requirement, "base/fieldTypes/identifier", RequirementIdentifier),
  secdeva_closestProject(Refinement, Project),
  secdeva_closestProject(Requirement, Project).

% A refinement verifies the requirement that it refines. The assessed security
% requirement of ismsa is then OK only when its refinements are OK or not
% applicable, and at least one of them, or another verification, is OK.

ismsa_securityRequirementVerification(Requirement, Refinement) :-
  ismsa_securityRequirement(Requirement),
  link(Refinement, Requirement, "secdeva/linkTypes/refines").

%
% Implementations
%

% Inside one development project

link(Implementation, Requirement, "ismsa/linkTypes/implements") :-
  secdeva_implements(ImplementationIdentifier, RequirementIdentifier, _),
  field(Implementation, "base/fieldTypes/identifier", ImplementationIdentifier),
  field(Requirement, "base/fieldTypes/identifier", RequirementIdentifier),
  secdeva_closestProject(Implementation, Project),
  secdeva_closestProject(Requirement, Project).

% A central control is not in the project, but in the ISMS home that contains
% the project. If the project has no card with the identifier, the control of
% the closest home implements the requirement.

secdeva_implementationInProject(ImplementationIdentifier, Project) :-
  secdeva_implements(ImplementationIdentifier, _, _),
  field(Card, "base/fieldTypes/identifier", ImplementationIdentifier),
  secdeva_closestProject(Card, Project).

link(Implementation, Requirement, "ismsa/linkTypes/implements") :-
  secdeva_implements(ImplementationIdentifier, RequirementIdentifier, _),
  field(Requirement, "base/fieldTypes/identifier", RequirementIdentifier),
  secdeva_closestProject(Requirement, Project),
  not secdeva_implementationInProject(ImplementationIdentifier, Project),
  ismsa_closestHome(Requirement, Home),
  field(Implementation, "base/fieldTypes/identifier", ImplementationIdentifier),
  ismsa_closestHome(Implementation, Home),
  not secdeva_closestProject(Implementation, _).
