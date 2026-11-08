% SPDX-FileCopyrightText: Cyberismo Ltd and contributors
% SPDX-License-Identifier: AGPL-3.0-only

% The layered layout ("Zones in tree order") of the layered test model.
% model: secdeva/graphModels/dataflow
% view: secdeva/graphViews/allEntities
% params: {"cardKey": "@Threat model - Layered test project", "highlightRowSkips": true}

% Rows follow the tree: one row per outermost zone, and one for the group
% that contains zones. Elements inside a zone are in its row.
expectRow("Enterprise zone", 1).
expectRow("DMZ", 2).
expectRow("Operations zone", 3).
expectRow("Control network", 4).
expectRow("Cell A zone", 4).
expectRow("PLC B", 4).
expectRow("Safety and field level", 5).
expectRow("Safety zone", 5).
expectRow("Field devices", 5).
% persons and external entities take the highest row of their dataflow partners
expectRow("Corporate user", 1).
expectRow("Remote vendor engineer", 1).
expectRow("Vendor cloud", 2).
expectRow("Control room operator", 3).
expectRow("Field technician", 4).

rowCount(T, N) :- expectRow(T, _), k(T, K), N = #count { R : effectiveRow(K, R) ; R : zoneRow(K, R) }.
testCase(@concatenate("row of ", T, " is ", R)) :- expectRow(T, R).
testPass(@concatenate("row of ", T, " is ", R)) :- expectRow(T, R), k(T, K), zoneRow(K, R), rowCount(T, 1).
testPass(@concatenate("row of ", T, " is ", R)) :- expectRow(T, R), k(T, K), effectiveRow(K, R), rowCount(T, 1).

% the physical site and the navigation group are not layers
testCase("site has no row of its own").
testPass("site has no row of its own") :- k("Plant site", K), not effectiveRow(K, _), not layer(K, _).
testCase("navigation group is not a layer").
testPass("navigation group is not a layer") :- k("Off-site parties", K), not layer(K, _).
testCase("site cluster is anchored in its top row").
testPass("site cluster is anchored in its top row") :- k("Plant site", K), rowMember(K, 2).
testCase("global ranking is on").
testPass("global ranking is on") :- attr(graph, toplevelGraph, newrank, true).

% groups are transparent: never drawn, and their elements belong to the group's parent
testCase("groups are not drawn").
testPass("groups are not drawn") :-
    k("Safety and field level", G1), k("Off-site parties", G2),
    not graph(G1, _), not node(G1, _), not graph(G2, _), not node(G2, _).
testCase("groups are not clusters in the layered layout").
testPass("groups are not clusters in the layered layout") :- #count { G : group(G), graph(G, _) } = 0, #count { G : framedGroup(G) } = 0.
testCase("a zone in a group belongs to the group's parent").
testPass("a zone in a group belongs to the group's parent") :- k("Plant site", S), k("Safety zone", Z), consistsOf(S, Z).

% a dataflow to a lower row number is drawn reversed
testCase("upward dataflow is drawn reversed").
testPass("upward dataflow is drawn reversed") :-
    k("Historian", H), k("Historian mirror", M),
    edge((M, H, "Replicate history [PI-to-PI]"), _),
    attr(edge, (M, H, "Replicate history [PI-to-PI]"), dir, back).
testCase("downward dataflow is not reversed").
testPass("downward dataflow is not reversed") :-
    k("Jump host", J), k("SCADA server", S),
    edge((J, S, "Administer [RDP]"), _), not attr(edge, (J, S, "Administer [RDP]"), dir, back).

% a dataflow that skips a row is highlighted, and only such a dataflow
testCase("dataflow that bypasses layers is red").
testPass("dataflow that bypasses layers is red") :-
    k("Remote vendor engineer", V), k("PLC B", P),
    attr(edge, (V, P, "Remote support [4G VPN]"), color, "#cc0000").
testCase("dataflows between adjacent rows are not red").
testPass("dataflows between adjacent rows are not red") :-
    k("Jump host", J), k("SCADA server", S), k("PLC A", A), k("Safety controller", C),
    not rowSkipEdge((J, S, "Administer [RDP]")),
    not rowSkipEdge((A, C, "Trip request [hardwired]")).
testCase("exactly one dataflow is highlighted").
testPass("exactly one dataflow is highlighted") :- #count { E : rowSkipEdge(E) } = 1.

% dataflows between different zones of one row do not push either zone down;
% dataflows within one zone still order its elements
testCase("same-row dataflow between zones does not constrain the ranking").
testPass("same-row dataflow between zones does not constrain the ranking") :-
    k("PLC A", A), k("PLC B", B), k("Safety controller", C), k("Field devices", D),
    attr(edge, (A, B, "Interlock [PROFINET]"), constraint, false),
    attr(edge, (C, D, "Trip [hardwired]"), constraint, false).
testCase("dataflow within a zone constrains the ranking").
testPass("dataflow within a zone constrains the ranking") :-
    k("HMI A", H), k("PLC A", A),
    edge((H, A, "Local commands [Modbus TCP] (502/tcp)"), _),
    not attr(edge, (H, A, "Local commands [Modbus TCP] (502/tcp)"), constraint, false).

% a dataflow to an interface is drawn to its owner, with the port in the label
testCase("interface port is added to the dataflow label").
testPass("interface port is added to the dataflow label") :-
    k("SCADA server", S), k("PLC A", A), dataflow(S, A, "Commands [Modbus TCP] (502/tcp)").
testCase("interfaces are not drawn").
testPass("interfaces are not drawn") :- k("Modbus TCP server", I), not node(I, _).

% physical and organisational boundaries are grey, the others red
testCase("physical boundary is grey").
testPass("physical boundary is grey") :- k("Plant site", K), attr(graph, K, color, "#666666").
testCase("network zone is red").
testPass("network zone is red") :- k("DMZ", K), attr(graph, K, color, "#aa0000"), not attr(graph, K, color, "#666666").
