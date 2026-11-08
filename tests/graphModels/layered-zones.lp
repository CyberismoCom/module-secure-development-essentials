% SPDX-FileCopyrightText: Cyberismo Ltd and contributors
% SPDX-License-Identifier: AGPL-3.0-only

% The zones and conduits view of the layered test model.
% model: secdeva/graphModels/dataflow
% view: secdeva/graphViews/zones
% params: {"root": "@Threat model - Layered test project"}

% innermost technical zones are boxes; nested zones and the site are frames
expectBox("Enterprise zone").
expectBox("DMZ").
expectBox("Operations zone").
expectBox("Cell A zone").
expectBox("Cell B zone").
expectBox("Safety zone").
expectBox("Field zone").
testCase(@concatenate(T, " is a box")) :- expectBox(T).
testPass(@concatenate(T, " is a box")) :- expectBox(T), k(T, K), node(K, _), not graph(K, _).

expectFrame("Plant site").
expectFrame("Control network").
testCase(@concatenate(T, " is a frame")) :- expectFrame(T).
testPass(@concatenate(T, " is a frame")) :- expectFrame(T), k(T, K), graph(K, _).

testCase("elements inside zones are hidden").
testPass("elements inside zones are hidden") :- k("PLC A", A), k("Jump host", J), not node(A, _), not node(J, _).
testCase("persons are drawn on their own").
testPass("persons are drawn on their own") :-
    k("Control room operator", O), k("Remote vendor engineer", V), node(O, _), node(V, _).

% dataflows between two boxes are merged into one conduit
testCase("conduit counts the dataflows between two zones").
testPass("conduit counts the dataflows between two zones") :-
    k("Operations zone", O), k("Cell A zone", A), edge((O, A, "2 dataflows"), _).
testCase("conduit with one dataflow").
testPass("conduit with one dataflow") :-
    k("Operations zone", O), k("Cell B zone", B), edge((O, B, "1 dataflow"), _).
testCase("dataflows inside one zone are not conduits").
testPass("dataflows inside one zone are not conduits") :- k("Operations zone", O), not edge((O, O, _), _).

% the zones view highlights dataflows that bypass layers
testCase("bypass conduit is red").
testPass("bypass conduit is red") :-
    k("Remote vendor engineer", V), k("Cell B zone", B), attr(edge, (V, B, "1 dataflow"), color, "#cc0000").
