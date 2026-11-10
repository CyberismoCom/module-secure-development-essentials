% SPDX-FileCopyrightText: Cyberismo Ltd and contributors
% SPDX-License-Identifier: AGPL-3.0-only

% A label view of the layered test model.
% model: secdeva/graphModels/dataflow
% view: secdeva/graphViews/label
% params: {"cardKey": "@Threat model - Layered test project", "labels": ["remote-access"]}

expectShown("Remote vendor engineer").
expectShown("Remote access gateway").
expectShown("Jump host").
expectShown("SCADA server").
expectShown("PLC B").
testCase(@concatenate(T, " is shown")) :- expectShown(T).
testPass(@concatenate(T, " is shown")) :- expectShown(T), k(T, K), node(K, _).

expectHidden("PLC A").
expectHidden("Corporate user").
expectHidden("Historian").
testCase(@concatenate(T, " is not shown")) :- expectHidden(T).
testPass(@concatenate(T, " is not shown")) :- expectHidden(T), k(T, K), not node(K, _).

testCase("zones of the shown elements are drawn").
testPass("zones of the shown elements are drawn") :- k("DMZ", D), k("Cell B zone", B), graph(D, _), graph(B, _).
testCase("rows are kept in the label view").
testPass("rows are kept in the label view") :- k("Jump host", J), effectiveRow(J, 2), k("PLC B", P), effectiveRow(P, 4).
