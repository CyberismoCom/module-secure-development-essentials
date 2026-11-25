% Module documentation
%
% The documentation of a module is a tree of pages in its card root. The test
% content of the module is a separate top-level card with the label
% "test-content". Exported sites and documents leave out the test content and
% all its descendants, so that they show only the documentation. The app shows
% the test content.
%
% The rule applies in every project that uses base. A project can mark its own
% cards with the label to keep them out of its exports.
%
% Shared predicate: base_testContent/1. See the "For module authors" pages of
% the base documentation.

base_testContent(Card) :-
    label(Card, "test-content").

hiddenInTreeView(Card) :-
    base_testContent(Card),
    exportedSite.

hiddenInTreeView(Card) :-
    base_testContent(Card),
    exportedDocument.
