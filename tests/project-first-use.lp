%* Assertion tests for the first use of a development project
(secdeva/calculations/projectSteps)

Run from the project root:

    cyberismo calc run tests/project-first-use.lp

The tests pass when "results" is empty. Each result is one failed assertion.

The fixtures are facts in this file: four development projects, each with
two phases, the phase registers, and a few internal controls with a given
assessment.

* secdeva_test_new: a new project. It is not set up, and it has only the
  evidence that every project has (a risk register). Its children are
  hidden in the tree.
* secdeva_test_started: an older project that is not set up, but has a
  review as evidence. Its children are not hidden.
* secdeva_test_ready: a project that is set up. It has the controls for
  the next steps, the phase progress, and the tile targets.
* secdeva_test_noLevel: a project with every field except the adoption step.
  It is not set up and has no evidence, so its children are hidden too.
*%

% The projects

secdeva_test_project(secdeva_test_new, "Untitled development project").
secdeva_test_project(secdeva_test_started, "Untitled development project").
secdeva_test_project(secdeva_test_ready, "Acme gateway").
secdeva_test_project(secdeva_test_noLevel, "Acme sensor").

secdeva_test_card(P, "secdeva/cardTypes/project2") :- secdeva_test_project(P, _).
field(P, "title", T) :- secdeva_test_project(P, T).
field(P, "base/fieldTypes/adoptionStep", "step1") :-
  secdeva_test_project(P, _), P != secdeva_test_noLevel.

field(secdeva_test_ready, "secdeva/fieldTypes/description", "A gateway for building automation devices.").
field(secdeva_test_ready, "base/fieldTypes/owner", "owner@example.com").
field(secdeva_test_noLevel, "secdeva/fieldTypes/description", "A sensor.").
field(secdeva_test_noLevel, "base/fieldTypes/owner", "owner@example.com").

% Two phases and their registers in each project

secdeva_test_phase(foundation, "0|b", "secdeva_phase_foundation", "secdeva_register_foundation-controls").
secdeva_test_phase(design, "0|c", "secdeva_phase_design", "secdeva_register_design-controls").

secdeva_test_phaseCard(P, Name, (P, phase, Name)) :- secdeva_test_project(P, _), secdeva_test_phase(Name, _, _, _).
secdeva_test_registerCard(P, Name, (P, register, Name)) :- secdeva_test_project(P, _), secdeva_test_phase(Name, _, _, _).

secdeva_test_card(Phase, "secdeva/cardTypes/phase") :- secdeva_test_phaseCard(_, _, Phase).
parent(Phase, P) :- secdeva_test_phaseCard(P, _, Phase).
field(Phase, "rank", R) :- secdeva_test_phaseCard(_, N, Phase), secdeva_test_phase(N, R, _, _).
field(Phase, "base/fieldTypes/identifier", I) :- secdeva_test_phaseCard(_, N, Phase), secdeva_test_phase(N, _, I, _).

secdeva_test_card(Register, "ismsa/cardTypes/register") :- secdeva_test_registerCard(_, _, Register).
parent(Register, P) :- secdeva_test_registerCard(P, _, Register).
field(Register, "rank", R) :- secdeva_test_registerCard(_, N, Register), secdeva_test_phase(N, R, _, _).
field(Register, "base/fieldTypes/identifier", I) :- secdeva_test_registerCard(_, N, Register), secdeva_test_phase(N, _, _, I).

% The controls: secdeva_test_control(Project, Control, Phase, Rank, Identifier, Assessment)

secdeva_test_control(secdeva_test_ready, ready_roles, foundation, "0|a", "secdeva_control_assign-people-to-project-roles", "ok").
secdeva_test_control(secdeva_test_ready, ready_other, foundation, "0|b", "secdeva_test_control_other", "notStarted").
secdeva_test_control(secdeva_test_ready, ready_threats, design, "0|a", "secdeva_control_threat-models", "notStarted").
secdeva_test_control(secdeva_test_ready, ready_design, design, "0|b", "secdeva_test_control_design", "inProgress").
secdeva_test_control(secdeva_test_ready, ready_notNeeded, design, "0|c", "secdeva_test_control_not-needed", "notApplicable").
secdeva_test_control(secdeva_test_new, new_roles, foundation, "0|a", "secdeva_control_assign-people-to-project-roles", "notStarted").
secdeva_test_control(secdeva_test_new, new_risks, design, "0|a", "secdeva_control_high-level-risks", "notStarted").
secdeva_test_control(secdeva_test_started, started_roles, foundation, "0|a", "secdeva_control_assign-people-to-project-roles", "inProgress").

secdeva_test_card(C, "ismsa/cardTypes/internalControl") :- secdeva_test_control(_, C, _, _, _, _).
parent(C, Register) :- secdeva_test_control(P, C, Phase, _, _, _), secdeva_test_registerCard(P, Phase, Register).
field(C, "rank", R) :- secdeva_test_control(_, C, _, R, _, _).
field(C, "title", I) :- secdeva_test_control(_, C, _, _, I, _).
field(C, "base/fieldTypes/identifier", I) :- secdeva_test_control(_, C, _, _, I, _).
field(C, "base/fieldTypes/assessment", A) :- secdeva_test_control(_, C, _, _, _, A).

% Evidence: a risk register in the new project (every project has one), and a
% review in the started project

secdeva_test_card(new_riskRegister, "secdeva/cardTypes/riskRegister").
parent(new_riskRegister, secdeva_test_new).
link(new_riskRegister, new_risks, "ismsa/linkTypes/evidences").

secdeva_test_card(started_review, "base/cardTypes/review").
parent(started_review, (secdeva_test_started, phase, foundation)).
link(started_review, started_roles, "ismsa/linkTypes/evidences").

projectCard(Card) :- secdeva_test_card(Card, _).
field(Card, "cardType", Type) :- secdeva_test_card(Card, Type).

%
% Assertions
%

secdeva_test_failure(Subject, Reason) :- secdeva_test_failure_(Subject, Reason).

% Set-up

secdeva_test_expectSetUp(secdeva_test_ready).

secdeva_test_failure_(P, "is set up, but should not be") :-
  secdeva_test_project(P, _), secdeva_projectSetUp(P), not secdeva_test_expectSetUp(P).
secdeva_test_failure_(P, "is not set up, but should be") :-
  secdeva_test_expectSetUp(P), not secdeva_projectSetUp(P).

secdeva_test_expectSetUpStepDone(secdeva_test_new, 4).
secdeva_test_expectSetUpStepDone(secdeva_test_noLevel, 1).
secdeva_test_expectSetUpStepDone(secdeva_test_noLevel, 2).
secdeva_test_expectSetUpStepDone(secdeva_test_noLevel, 3).

secdeva_test_failure_((P, N), "set-up step should be done") :-
  secdeva_test_expectSetUpStepDone(P, N), not secdeva_projectSetUpStepDone(P, N).
secdeva_test_failure_((P, N), "set-up step should not be done") :-
  secdeva_projectSetUpStepDone(P, N),
  P != secdeva_test_ready, P != secdeva_test_started,
  secdeva_test_project(P, _),
  not secdeva_test_expectSetUpStepDone(P, N).

% The tree

secdeva_test_expectHidden(secdeva_test_new).
secdeva_test_expectHidden(secdeva_test_noLevel).

secdeva_test_failure_(P, "the children should be hidden") :-
  secdeva_test_expectHidden(P),
  parent(C, P), not hiddenInTreeView(C).
secdeva_test_failure_(P, "the children should not be hidden") :-
  secdeva_test_project(P, _), not secdeva_test_expectHidden(P),
  parent(C, P), hiddenInTreeView(C).

% Next steps of the ready project: the open first step first, then the other
% open controls in the order of the phase registers and their ranks. Done and
% not needed controls are not steps.

secdeva_test_expectNext(1, ready_threats).
secdeva_test_expectNext(2, ready_other).
secdeva_test_expectNext(3, ready_design).

secdeva_test_failure_((I, C), "should be next step number I") :-
  secdeva_test_expectNext(I, C), not secdeva_projectNextStep(secdeva_test_ready, I, C).
secdeva_test_failure_((I, C), "is a next step, but should not be") :-
  secdeva_projectNextStep(secdeva_test_ready, I, C), not secdeva_test_expectNext(I, C).

secdeva_test_failure_(secdeva_test_ready, "open step count should be 3") :-
  not secdeva_projectOpenStepCount(secdeva_test_ready, 3).

secdeva_test_failure_(ready_threats, "the label of a first step should be its short label") :-
  not secdeva_projectStepLabel(secdeva_test_ready, ready_threats, "Model the threats").

secdeva_test_failure_(secdeva_test_ready, "the first steps are not done") :-
  secdeva_projectFirstStepsDone(secdeva_test_ready).

% Phase progress and tile targets

secdeva_test_expectPhase(foundation, 50, ready_other).
secdeva_test_expectPhase(design, 33, ready_threats).

secdeva_test_failure_(Name, "phase progress") :-
  secdeva_test_expectPhase(Name, V, _),
  secdeva_test_phaseCard(secdeva_test_ready, Name, Phase),
  not secdeva_projectPhaseProgress(secdeva_test_ready, Phase, V).

secdeva_test_failure_(Name, "tile target") :-
  secdeva_test_expectPhase(Name, _, Target),
  secdeva_test_phaseCard(secdeva_test_ready, Name, Phase),
  not secdeva_projectPhaseTarget(secdeva_test_ready, Phase, Target).

result((Subject, Reason)) :- secdeva_test_failure(Subject, Reason).
