% SPDX-FileCopyrightText: Cyberismo Ltd and contributors
% SPDX-License-Identifier: AGPL-3.0-only

% The deep test model has no diagram layout, so its diagrams follow the
% dataflows as before: no rows, no global ranking and no merged dataflows.
% model: secdeva/graphModels/dataflow
% view: secdeva/graphViews/allEntities
% params: {"cardKey": "@Threat model - Test project", "highlightRowSkips": true}

testCase("no rows without the layered layout").
testPass("no rows without the layered layout") :- not usedRow(_), not layoutEdge(_).
testCase("no global ranking without the layered layout").
testPass("no global ranking without the layered layout") :- not attr(graph, toplevelGraph, newrank, true).
testCase("no dataflows are reversed or highlighted").
testPass("no dataflows are reversed or highlighted") :- not upwardEdge(_, _), not rowSkipEdge(_).
testCase("each dataflow is its own edge").
testPass("each dataflow is its own edge") :-
    not mergedFlow(_, _, _),
    N = #count { E : edge_(E, _, _, _) }, N = #count { E : dataflowEdge(E, _, _, _) }, N > 0.
testCase("the deep model is drawn").
testPass("the deep model is drawn") :- k("Process 1.1.1", P), node(P, _).
