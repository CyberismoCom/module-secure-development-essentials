%* Assertion tests for the first use of a development project
(secdeva/calculations/projectSteps)

Run from the project root:

    cyberismo calc run tests/project-first-use.lp

The tests pass when "results" is empty. Each result is one failed assertion.

The fixtures are facts in this file: four development projects, each with
two phases, the phase registers, and a few internal controls with a given
assessment.

* secdeva_test_new: a new project with the field "Guided set-up". It is not
  set up, so its children are hidden in the tree.
* secdeva_test_old: an older project without the field. It is not set up
  either, but its tree does not change.
* secdeva_test_ready: a guided project that is set up. It has the controls
  for the next steps, the phase progress, and the tile targets.
* secdeva_test_noLevel: a guided project with every field except the
  adoption step. It is not set up, so its children are hidden too.
* secdeva_test_yes: a guided project with every field and the answer "yes"
  to the software question, but without the secure development library. It
  is not set up, because the library is missing.
* secdeva_test_lib: like secdeva_test_yes, with one control from each part of
  the library (the template card keys of secdeva/templates/secureDevelopment*).
  It is set up.
* secdeva_test_ready and secdeva_test_noLevel answer "no".
*%

% The projects

secdeva_test_project(secdeva_test_new, "Untitled development project").
secdeva_test_project(secdeva_test_old, "Untitled development project").
secdeva_test_project(secdeva_test_ready, "Acme gateway").
secdeva_test_project(secdeva_test_noLevel, "Acme sensor").
secdeva_test_project(secdeva_test_yes, "Acme controller").
secdeva_test_project(secdeva_test_lib, "Acme hub").

secdeva_test_card(P, "secdeva/cardTypes/project2") :- secdeva_test_project(P, _).
field(P, "title", T) :- secdeva_test_project(P, T).
field(P, "base/fieldTypes/adoptionStep", "step1") :-
  secdeva_test_project(P, _), P != secdeva_test_noLevel.
field(P, "secdeva/fieldTypes/guidedSetUp", "true") :-
  secdeva_test_project(P, _), P != secdeva_test_old.

field(secdeva_test_ready, "secdeva/fieldTypes/description", "A gateway for building automation devices.").
field(secdeva_test_ready, "base/fieldTypes/owner", "owner@example.com").
field(secdeva_test_noLevel, "secdeva/fieldTypes/description", "A sensor.").
field(secdeva_test_noLevel, "base/fieldTypes/owner", "owner@example.com").

secdeva_test_complete(secdeva_test_yes).
secdeva_test_complete(secdeva_test_lib).
field(P, "secdeva/fieldTypes/description", "A device.") :- secdeva_test_complete(P).
field(P, "base/fieldTypes/owner", "owner@example.com") :- secdeva_test_complete(P).

field(secdeva_test_ready, "secdeva/fieldTypes/projectWritesSoftware", "no").
field(secdeva_test_noLevel, "secdeva/fieldTypes/projectWritesSoftware", "no").
field(P, "secdeva/fieldTypes/projectWritesSoftware", "yes") :- secdeva_test_complete(P).

% The library registers of secdeva_test_lib, each with one control created
% from a template card of the library:
% secdeva_test_library(RegisterIdentifier, TemplateCardKey)

secdeva_test_library("secdeva_register_implementation-controls", "secdeva_c0wtj0ci").
secdeva_test_library("secdeva_register_releases-controls", "secdeva_8nil3vzn").
secdeva_test_library("secdeva_register_verification-controls", "secdeva_hm5obl63").

secdeva_test_card((secdeva_test_lib, register, I), "ismsa/cardTypes/register") :- secdeva_test_library(I, _).
parent((secdeva_test_lib, register, I), secdeva_test_lib) :- secdeva_test_library(I, _).
field((secdeva_test_lib, register, I), "base/fieldTypes/identifier", I) :- secdeva_test_library(I, _).
secdeva_test_card((secdeva_test_lib, control, I), "ismsa/cardTypes/internalControl") :- secdeva_test_library(I, _).
parent((secdeva_test_lib, control, I), (secdeva_test_lib, register, I)) :- secdeva_test_library(I, _).
field((secdeva_test_lib, control, I), "templateCardKey", K) :- secdeva_test_library(I, K).

% The design register is in the fixtures of every project.
secdeva_test_card((secdeva_test_lib, control, design), "ismsa/cardTypes/internalControl").
parent((secdeva_test_lib, control, design), (secdeva_test_lib, register, design)).
field((secdeva_test_lib, control, design), "templateCardKey", "secdeva_2b7juhs8").

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
secdeva_test_control(secdeva_test_old, old_roles, foundation, "0|a", "secdeva_control_assign-people-to-project-roles", "inProgress").

secdeva_test_card(C, "ismsa/cardTypes/internalControl") :- secdeva_test_control(_, C, _, _, _, _).
parent(C, Register) :- secdeva_test_control(P, C, Phase, _, _, _), secdeva_test_registerCard(P, Phase, Register).
field(C, "rank", R) :- secdeva_test_control(_, C, _, R, _, _).
field(C, "title", I) :- secdeva_test_control(_, C, _, _, I, _).
field(C, "base/fieldTypes/identifier", I) :- secdeva_test_control(_, C, _, _, I, _).
field(C, "base/fieldTypes/assessment", A) :- secdeva_test_control(_, C, _, _, _, A).

projectCard(Card) :- secdeva_test_card(Card, _).
field(Card, "cardType", Type) :- secdeva_test_card(Card, Type).

%
% Assertions
%

secdeva_test_failure(Subject, Reason) :- secdeva_test_failure_(Subject, Reason).

% Set-up

secdeva_test_expectSetUp(secdeva_test_ready).
secdeva_test_expectSetUp(secdeva_test_lib).

secdeva_test_failure_(P, "is set up, but should not be") :-
  secdeva_test_project(P, _), secdeva_projectSetUp(P), not secdeva_test_expectSetUp(P).
secdeva_test_failure_(P, "is not set up, but should be") :-
  secdeva_test_expectSetUp(P), not secdeva_projectSetUp(P).

secdeva_test_expectSetUpStepDone(secdeva_test_new, 4).
secdeva_test_expectSetUpStepDone(secdeva_test_noLevel, 1).
secdeva_test_expectSetUpStepDone(secdeva_test_noLevel, 2).
secdeva_test_expectSetUpStepDone(secdeva_test_noLevel, 3).
secdeva_test_expectSetUpStepDone(secdeva_test_noLevel, 5).
secdeva_test_expectSetUpStepDone(secdeva_test_yes, 1..4).

secdeva_test_failure_((P, N), "set-up step should be done") :-
  secdeva_test_expectSetUpStepDone(P, N), not secdeva_projectSetUpStepDone(P, N).
secdeva_test_failure_((P, N), "set-up step should not be done") :-
  secdeva_projectSetUpStepDone(P, N),
  P != secdeva_test_ready, P != secdeva_test_old, P != secdeva_test_lib,
  secdeva_test_project(P, _),
  not secdeva_test_expectSetUpStepDone(P, N).

% The tree

secdeva_test_expectHidden(secdeva_test_new).
secdeva_test_expectHidden(secdeva_test_noLevel).
secdeva_test_expectHidden(secdeva_test_yes).

% The library

secdeva_test_failure_(secdeva_test_lib, "the library should be complete") :-
  not secdeva_projectLibraryComplete(secdeva_test_lib).
secdeva_test_failure_(secdeva_test_yes, "the library should be missing") :-
  not secdeva_projectLibraryMissing(secdeva_test_yes).
secdeva_test_failure_(P, "should not have the library") :-
  secdeva_test_project(P, _), secdeva_projectHasLibrary(P), P != secdeva_test_lib.
secdeva_test_failure_(secdeva_test_lib, "the library should have four parts") :-
  not 4 #count { T : secdeva_projectLibraryAdded(secdeva_test_lib, T) } 4.

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
