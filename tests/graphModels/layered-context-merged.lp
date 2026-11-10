% SPDX-FileCopyrightText: Cyberismo Ltd and contributors
% SPDX-License-Identifier: AGPL-3.0-only

% The context view of the layered test model, with merged dataflows.
% model: secdeva/graphModels/dataflow
% view: secdeva/graphViews/context
% params: {"cardKey": "@Threat model - Layered test project", "mergeDataflows": true}

% a system (a process with components) is one box in the context view
testCase("system is drawn as one node").
testPass("system is drawn as one node") :- k("SCADA system", K), node(K, _), not graph(K, _).
testCase("components of a system are hidden").
testPass("components of a system are hidden") :- k("SCADA server", S), k("Historian", H), not node(S, _), not node(H, _).

% two dataflows between the same boxes become one edge listing both
testCase("parallel dataflows are merged into one edge").
testPass("parallel dataflows are merged into one edge") :-
    k("SCADA system", S), k("PLC A", A),
    #count { L : edge((S, A, L), _) } = 1,
    edge((S, A, "Commands [Modbus TCP] (502/tcp)<br/>Read status [Modbus TCP] (502/tcp)"), _).
testCase("both dataflows are still found before merging").
testPass("both dataflows are still found before merging") :-
    k("SCADA system", S), k("PLC A", A), #count { N : dataflowEdge((S, A, N), _, _, _) } = 2.
testCase("a single dataflow keeps its own label").
testPass("a single dataflow keeps its own label") :-
    k("SCADA system", S), k("PLC B", B), edge((S, B, "Commands to cell B [Modbus TCP]"), _).

% the layout works in the context view too
testCase("context view keeps the rows").
testPass("context view keeps the rows") :- k("SCADA system", S), effectiveRow(S, 3), k("PLC B", B), effectiveRow(B, 4).
