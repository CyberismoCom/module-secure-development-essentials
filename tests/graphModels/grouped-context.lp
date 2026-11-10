% SPDX-FileCopyrightText: Cyberismo Ltd and contributors
% SPDX-License-Identifier: AGPL-3.0-only

% In the context view, a system is one box, and it stays in its group.
% model: secdeva/graphModels/dataflow
% view: secdeva/graphViews/context
% params: {"cardKey": "@Threat model - Grouped test project", "mergeDataflows": true}

testCase("a system is one box in its group").
testPass("a system is one box in its group") :-
    k("Backend services", G), k("Admin portal", S), node(S, G), not graph(S, _).
testCase("components of a collapsed system are not drawn").
testPass("components of a collapsed system are not drawn") :- k("Admin UI", C), not node(C, _).
testCase("the group of the system is still a cluster").
testPass("the group of the system is still a cluster") :- k("Backend services", G), k("Cloud platform", B), graph(G, B).
testCase("a dataflow to a component goes to its system").
testPass("a dataflow to a component goes to its system") :-
    k("Administrator", AD), k("Admin portal", S), edge((AD, S, _), _).
testCase("merged dataflows are drawn").
testPass("merged dataflows are drawn") :-
    k("Admin portal", S), k("Database", D), edge((S, D, "Manage data [SQL]"), _),
    #count { E : edge(E, _) } = 11.
