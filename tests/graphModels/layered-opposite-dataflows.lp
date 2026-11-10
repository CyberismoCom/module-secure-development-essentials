% SPDX-FileCopyrightText: Cyberismo Ltd and contributors
% SPDX-License-Identifier: AGPL-3.0-only

% An upward dataflow is drawn reversed with dir=back. If a dataflow with the
% same title runs the other way, the reversed edge would take its identifier,
% so the upward dataflow is drawn upwards instead. This case adds such a
% dataflow to the layered test model: PLC A answers the Historian with the
% same title as the Historian's request.
% model: secdeva/graphModels/dataflow
% view: secdeva/graphViews/allEntities
% params: {"cardKey": "@Threat model - Layered test project"}

link(P, H, "secdeva/linkTypes/dataflow", "Read status [Modbus TCP] (502/tcp)") :- k("PLC A", P), k("Historian", H).

testCase("both dataflows are drawn").
testPass("both dataflows are drawn") :-
    k("PLC A", P), k("Historian", H),
    edge((H, P, "Read status [Modbus TCP] (502/tcp)"), _), edge((P, H, "Read status [Modbus TCP] (502/tcp)"), _).
testCase("the downward dataflow is not reversed").
testPass("the downward dataflow is not reversed") :-
    k("PLC A", P), k("Historian", H), not attr(edge, (H, P, "Read status [Modbus TCP] (502/tcp)"), dir, back).
testCase("the upward dataflow does not constrain the rows").
testPass("the upward dataflow does not constrain the rows") :-
    k("PLC A", P), k("Historian", H), attr(edge, (P, H, "Read status [Modbus TCP] (502/tcp)"), constraint, false).
testCase("other upward dataflows are still reversed").
testPass("other upward dataflows are still reversed") :-
    k("Historian", H), k("Historian mirror", M), attr(edge, (M, H, "Replicate history [PI-to-PI]"), dir, back).
