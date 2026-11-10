% SPDX-FileCopyrightText: Cyberismo Ltd and contributors
% SPDX-License-Identifier: AGPL-3.0-only

% Outside the layered layout, each group whose elements are drawn becomes a
% cluster that keeps its elements together. A shown group (Partners) is a grey
% rectangle with its title; the others are invisible. No dataflow is lost.
% model: secdeva/graphModels/dataflow
% view: secdeva/graphViews/allEntities
% params: {"cardKey": "@Threat model - Grouped test project"}

testCase("the model follows the dataflows").
testPass("the model follows the dataflows") :- testModel(M), not zoneLayers(M), not usedRow(_).

% clusters for groups, in their nearest drawn container
testCase("a top-level group is a cluster").
testPass("a top-level group is a cluster") :- k("Clients", G), graph(G, toplevelGraph).
testCase("a group in a trust boundary is a cluster inside it").
testPass("a group in a trust boundary is a cluster inside it") :- k("Backend services", G), k("Cloud platform", B), graph(G, B).
testCase("a nested group is a cluster inside its group").
testPass("a nested group is a cluster inside its group") :- k("Payment partners", G), k("Partners", P), graph(G, P).
testCase("a group without elements is not drawn").
testPass("a group without elements is not drawn") :- k("Empty group", G), not graph(G, _), not node(G, _).

% hidden groups are invisible clusters
testCase("hidden groups are invisible clusters").
testPass("hidden groups are invisible clusters") :-
    k("Clients", C), k("Backend services", B), k("Payment partners", P),
    attr(graph, C, style, invis), attr(graph, B, style, invis), attr(graph, P, style, invis),
    #count { G : group(G), graph(G, _) } = 4.
testCase("hidden groups have no label").
testPass("hidden groups have no label") :-
    #count { G : group(G), attr(graph, G, label, _), not shownGroup(G) } = 0.

% a shown group is a grey rectangle with its title
testCase("a shown group is a grey rectangle").
testPass("a shown group is a grey rectangle") :-
    k("Partners", G), graph(G, toplevelGraph), attr(graph, G, color, "#999999"),
    not attr(graph, G, style, _), not attr(graph, G, color, "#000000").
testCase("a shown group has its title as the label").
testPass("a shown group has its title as the label") :-
    k("Partners", G), attr(graph, G, label, "<<font point-size='24'><b> Partners </b></font><br/>>").

% elements are placed in their group
testCase("elements are in their group").
testPass("elements are in their group") :-
    k("Clients", C), k("User", U), k("Web app", W), node(U, C), node(W, C),
    k("Backend services", B), k("API service", A), node(A, B),
    k("Partners", P), k("Email service", E), node(E, P).
testCase("an element in a nested group is in the inner group").
testPass("an element in a nested group is in the inner group") :- k("Payment partners", G), k("Payment provider", X), node(X, G).
testCase("a system in a group is a cluster inside the group").
testPass("a system in a group is a cluster inside the group") :-
    k("Backend services", G), k("Admin portal", S), graph(S, G), k("Admin UI", C), node(C, S).
testCase("an element outside groups stays in its trust boundary").
testPass("an element outside groups stays in its trust boundary") :- k("Cloud platform", B), k("Database", D), node(D, B).
testCase("each card is placed once").
testPass("each card is placed once") :-
    #count { X : node(X, G1), node(X, G2), G1 != G2 } = 0,
    #count { X : graph(X, G1), graph(X, G2), G1 != G2 } = 0.

% dataflows
testCase("every dataflow is drawn").
testPass("every dataflow is drawn") :-
    #count { N : dataflowEdge((_, _, N), _, _, _) } = 12,
    #count { N : edge((_, _, N), _) } = 12.
testCase("dataflows into a group keep their endpoints").
testPass("dataflows into a group keep their endpoints") :-
    k("User", U), k("Web app", W), edge((U, W, "Browse [HTTPS]"), _),
    k("API service", A), k("Payment provider", P), edge((A, P, "Charge [HTTPS]"), _),
    k("Administrator", AD), k("Admin UI", UI), edge((AD, UI, "Administer [HTTPS]"), _).
