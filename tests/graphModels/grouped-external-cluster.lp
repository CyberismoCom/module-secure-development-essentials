% SPDX-FileCopyrightText: Cyberismo Ltd and contributors
% SPDX-License-Identifier: AGPL-3.0-only

% Clusters inherit the attributes of their parent graph, so a cluster that does
% not set its own style would be invisible inside a hidden group or the
% invisible diagram frame. This case adds a process under Payment provider, so
% that the external entity is drawn as a cluster inside the hidden group
% Payment partners.
% model: secdeva/graphModels/dataflow
% view: secdeva/graphViews/allEntities
% params: {"cardKey": "@Threat model - Grouped test project"}

field("test_paymentApi", "cardType", "secdeva/cardTypes/process").
field("test_paymentApi", "title", "Payment API").
parent("test_paymentApi", P) :- k("Payment provider", P).
ancestor("test_paymentApi", P) :- k("Payment provider", P).
ancestor("test_paymentApi", A) :- k("Payment provider", P), ancestor(P, A).

testCase("the external entity is a cluster in the hidden group").
testPass("the external entity is a cluster in the hidden group") :-
    k("Payment provider", P), k("Payment partners", G), graph(P, G), node("test_paymentApi", P).
testCase("the external entity cluster is drawn with a solid border").
testPass("the external entity cluster is drawn with a solid border") :-
    k("Payment provider", P), attr(graph, P, style, solid), attr(graph, P, color, "#000000").
testCase("a hidden group that contains a cluster keeps its margin").
testPass("a hidden group that contains a cluster keeps its margin") :-
    k("Payment partners", G), attr(graph, G, margin, "40"), not attr(graph, G, margin, "0").
testCase("every drawn cluster sets its own style").
testPass("every drawn cluster sets its own style") :- #count { X : graph(X, _), not attr(graph, X, style, _) } = 0.
