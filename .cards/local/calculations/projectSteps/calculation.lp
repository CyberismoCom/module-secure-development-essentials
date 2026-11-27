%
% Steps of a development project
%
% The project card shows the steps in two views: the set-up checklist
% (secdeva/reports/projectSetUp) until the project is set up, and then the
% dashboard (secdeva/reports/projectDashboard). Both use the facts of this
% calculation, so that they always agree.
%
% The steps are only for projects made from secdeva/templates/project2.
%

secdeva_project2(Project) :-
  base_projectCardType(Project, "secdeva/cardTypes/project2").

%
% Set-up steps
%
% secdeva_projectSetUpStep(Ordinal, Text)
%

secdeva_projectSetUpStep(1, "Give the project the name of the product").
secdeva_projectSetUpStep(2, "Describe the product").
secdeva_projectSetUpStep(3, "Set the owner of the project").
secdeva_projectSetUpStep(4, "Choose the adoption step").
secdeva_projectSetUpStep(5, "Choose the practices for the kind of work").

secdeva_projectSetUpStepDone(Project, 1) :-
  secdeva_project2(Project),
  field(Project, "title", Title),
  Title != "Untitled development project",
  Title != "".

secdeva_projectSetUpStepDone(Project, 2) :-
  secdeva_project2(Project),
  field(Project, "secdeva/fieldTypes/description", Description),
  Description != "".

secdeva_projectSetUpStepDone(Project, 3) :-
  secdeva_project2(Project),
  field(Project, "base/fieldTypes/owner", _).

secdeva_projectSetUpStepDone(Project, 4) :-
  secdeva_project2(Project),
  field(Project, "base/fieldTypes/adoptionStep", _).

% Step 5 asks if the team writes or changes software. A "yes" adds the
% secure development library: one extension template for each phase register
% (secdeva/calculations/extensions). The step is done when the question has
% an answer, and after a "yes" when every part of the library is added.
% Projects made before the split have the library and no answer, so the
% library counts as the answer.

secdeva_projectSetUpStepDone(Project, 5) :-
  secdeva_projectSoftwareAnswered(Project),
  not secdeva_projectLibraryMissing(Project).

secdeva_projectSoftwareAnswered(Project) :-
  secdeva_project2(Project),
  field(Project, "secdeva/fieldTypes/projectWritesSoftware", _).

secdeva_projectSoftwareAnswered(Project) :-
  secdeva_projectHasLibrary(Project).

secdeva_projectLibraryMissing(Project) :-
  secdeva_project2(Project),
  field(Project, "secdeva/fieldTypes/projectWritesSoftware", "yes"),
  not secdeva_projectLibraryComplete(Project).

secdeva_projectSetUp(Project) :-
  secdeva_project2(Project),
  secdeva_projectSetUpStepDone(Project, N) : secdeva_projectSetUpStep(N, _).

%
% The secure development library
%
% secdeva_projectLibraryRegister(Project, Template, Register, ButtonLabel):
% the phase register of the project that a template of the library adds
% controls to.
%

secdeva_projectLibraryTemplate(Template, RegisterIdentifier, ButtonLabel) :-
  secdeva_installableExtension(RegisterIdentifier, "the secure development library", Template, ButtonLabel).

secdeva_projectLibraryRegister(Project, Template, Register, ButtonLabel) :-
  secdeva_project2(Project),
  secdeva_projectLibraryTemplate(Template, RegisterIdentifier, ButtonLabel),
  field(Register, "base/fieldTypes/identifier", RegisterIdentifier),
  secdeva_closestProject(Register, Project).

% A template is added when a card under its register was created from it.
% Projects made before the split have the same template card keys, so their
% controls count as added. The template card key is a string (INTDEV-1398),
% so it is converted first.

secdeva_projectLibraryAdded(Project, Template) :-
  secdeva_projectLibraryRegister(Project, Template, Register, _),
  ancestor(Card, Register),
  field(Card, "templateCardKey", TemplateCardKey),
  ancestor(TemplateCard, Template),
  @concatenate(TemplateCard, "") == @concatenate(TemplateCardKey, "").

secdeva_projectHasLibrary(Project) :-
  secdeva_projectLibraryAdded(Project, _).

secdeva_projectLibraryComplete(Project) :-
  secdeva_project2(Project),
  secdeva_projectLibraryAdded(Project, Template) : secdeva_projectLibraryTemplate(Template, _, _).

%
% Control steps
%
% After the set-up, the steps are the internal controls of the project at its
% adoption step. The first steps come first, in this order. The other
% controls follow in the order of the phases and of the controls in each
% phase register.
%
% secdeva_projectFirstStep(Ordinal, ControlIdentifier, Label)
%

secdeva_projectFirstStep(1, "secdeva_control_assign-people-to-project-roles", "Assign security roles").
secdeva_projectFirstStep(2, "secdeva_control_ensure-competence", "Check the competence of the team").
secdeva_projectFirstStep(3, "secdeva_control_security-context", "Describe the security context").
secdeva_projectFirstStep(4, "secdeva_control_threat-models", "Model the threats").
secdeva_projectFirstStep(5, "secdeva_control_high-level-risks", "Assess the risks").
secdeva_projectFirstStep(6, "secdeva_control_security-requirements", "Write the security requirements").
secdeva_projectFirstStep(7, "secdeva_control_scope-secure-development-activities", "Choose the practices for the project").

% The phase of a control: the phase that its phase register belongs to
% (secdeva_copyProgressMetric/2 in secdeva/calculations/progress).

secdeva_projectControlPhase(Project, Control, Phase, RegisterRank) :-
  secdeva_project2(Project),
  base_projectCardType(Control, "ismsa/cardTypes/internalControl"),
  secdeva_closestProject(Control, Project),
  parent(Control, Register),
  field(Register, "base/fieldTypes/identifier", RegisterIdentifier),
  field(Register, "rank", RegisterRank),
  secdeva_copyProgressMetric(RegisterIdentifier, PhaseIdentifier),
  field(Phase, "base/fieldTypes/identifier", PhaseIdentifier),
  secdeva_closestProject(Phase, Project).

% The controls that are steps: those at the adoption step of the project.

secdeva_projectStepControl(Project, Control) :-
  secdeva_projectControlPhase(Project, Control, _, _),
  not base_greaterAdoptionStep(Control, Project).

% The position of a step: (0, Ordinal, Ordinal) for a first step, and (1,
% Register rank, Control rank) for the others. Both tuples have three
% elements, because Clingo orders tuples of different lengths by their length
% first. Tuples of the same length are ordered element by element.

secdeva_projectStepKey(Project, Control, (0, Ordinal, Ordinal)) :-
  secdeva_projectStepControl(Project, Control),
  field(Control, "base/fieldTypes/identifier", Identifier),
  secdeva_projectFirstStep(Ordinal, Identifier, _).

secdeva_projectStepKey(Project, Control, (1, RegisterRank, Rank)) :-
  secdeva_projectStepControl(Project, Control),
  secdeva_projectControlPhase(Project, Control, _, RegisterRank),
  field(Control, "rank", Rank),
  field(Control, "base/fieldTypes/identifier", Identifier),
  not secdeva_projectFirstStep(_, Identifier, _).

secdeva_projectStepKey(Project, Control, (1, RegisterRank, Rank)) :-
  secdeva_projectStepControl(Project, Control),
  secdeva_projectControlPhase(Project, Control, _, RegisterRank),
  field(Control, "rank", Rank),
  not field(Control, "base/fieldTypes/identifier", _).

% The label of a step: the short label of a first step, or the title of the
% control.

secdeva_projectStepLabel(Project, Control, Label) :-
  secdeva_projectStepKey(Project, Control, (0, Ordinal, Ordinal)),
  secdeva_projectFirstStep(Ordinal, _, Label).

secdeva_projectStepLabel(Project, Control, Title) :-
  secdeva_projectStepKey(Project, Control, (1, _, _)),
  field(Control, "title", Title).

% A step is done when its control is OK or out of scope.

secdeva_projectStepDoneValue("ok").
secdeva_projectStepDoneValue("notApplicable").

secdeva_projectStepDone(Project, Control) :-
  secdeva_projectStepControl(Project, Control),
  field(Control, "base/fieldTypes/assessment", Assessment),
  secdeva_projectStepDoneValue(Assessment).

secdeva_projectStepOpen(Project, Control) :-
  secdeva_projectStepKey(Project, Control, _),
  not secdeva_projectStepDone(Project, Control).

% secdeva_projectStepIndex(Project, Index, Control): all steps, numbered from
% 1 in the order of all steps.

secdeva_projectStepIndex(Project, Index, Control) :-
  secdeva_projectStepKey(Project, Control, Key),
  Before = #count { K : secdeva_projectStepKey(Project, C, K), K < Key },
  Index = Before + 1.

% secdeva_projectNextStep(Project, Index, Control): the open steps, numbered
% from 1 in the order of all steps.

secdeva_projectNextStep(Project, Index, Control) :-
  secdeva_projectStepOpen(Project, Control),
  secdeva_projectStepKey(Project, Control, Key),
  Before = #count { K : secdeva_projectStepOpen(Project, C), secdeva_projectStepKey(Project, C, K), K < Key },
  Index = Before + 1.

secdeva_projectOpenStepCount(Project, N) :-
  secdeva_project2(Project),
  N = #count { C : secdeva_projectStepOpen(Project, C) }.

% The first steps are done when no first step is open.

secdeva_projectFirstStepsDone(Project) :-
  secdeva_project2(Project),
  not secdeva_projectStepOpen(Project, C) : secdeva_projectStepKey(Project, C, (0, _, _)).

%
% Phases
%
% The dashboard shows one progress tile for each phase: the share of the
% steps of the phase that are done, in per cent. A phase with no steps at
% the adoption step has no value. A click opens the first open step of the
% phase, or the phase card when all are done.
%

secdeva_projectPhase(Project, Phase) :-
  secdeva_project2(Project),
  base_projectCardType(Phase, "secdeva/cardTypes/phase"),
  parent(Phase, Project).

secdeva_projectPhaseStep(Project, Phase, Control) :-
  secdeva_projectStepKey(Project, Control, _),
  secdeva_projectControlPhase(Project, Control, Phase, _).

secdeva_projectPhaseProgress(Project, Phase, Value) :-
  secdeva_projectPhase(Project, Phase),
  Total = #count { C : secdeva_projectPhaseStep(Project, Phase, C) },
  Total > 0,
  Done = #count { C : secdeva_projectPhaseStep(Project, Phase, C), secdeva_projectStepDone(Project, C) },
  Value = 100 * Done / Total.

secdeva_projectPhaseFirstOpenKey(Project, Phase, Key) :-
  secdeva_projectPhase(Project, Phase),
  Key = #min { K : secdeva_projectPhaseStep(Project, Phase, C), secdeva_projectStepOpen(Project, C), secdeva_projectStepKey(Project, C, K) },
  Key != #sup.

secdeva_projectPhaseTarget(Project, Phase, Control) :-
  secdeva_projectPhaseFirstOpenKey(Project, Phase, Key),
  secdeva_projectPhaseStep(Project, Phase, Control),
  secdeva_projectStepKey(Project, Control, Key).

secdeva_projectPhaseTarget(Project, Phase, Phase) :-
  secdeva_projectPhase(Project, Phase),
  not secdeva_projectPhaseFirstOpenKey(Project, Phase, _).

%
% The tree
%
% A new project shows only the project card in the tree until it is set up.
% The children stay reachable by link and by search.
%
% Only the projects with the field "Guided set-up" are hidden. New projects
% get the field from the template. Older projects do not have it, so their
% tree does not change, even when they have no owner or description.
%

secdeva_guidedProject(Project) :-
  secdeva_project2(Project),
  field(Project, "secdeva/fieldTypes/guidedSetUp", "true").

hiddenInTreeView(Card) :-
  secdeva_guidedProject(Project),
  parent(Card, Project),
  not secdeva_projectSetUp(Project).
