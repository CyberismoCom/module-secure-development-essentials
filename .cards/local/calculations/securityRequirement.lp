% Copyright © Cyberismo Ltd and contributors 2025
%
% License: https://github.com/CyberismoCom/module-secure-development-essentials/blob/main/LICENSE
% The use of the Cyberismo trademark: https://cyberismo.com/trademark-policy/
% This content is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.

link(Requirement, Risk, "ismsa/linkTypes/mitigates") :-
    field(Risk, "cardType", "ismsa/cardTypes/risk"),
    field(Requirement, "cardType", "secdeva/cardTypes/requirement"),
    parent(Requirement, Risk).

transitionDenied(
    Card,
    "Approve requirement",
    "All review tasks must be closed as done before the requirement can be approved."
    ) :-
        field(Card, "cardType", "secdeva/cardTypes/requirement"),
        parent(ReviewTask, Card),
        not field(ReviewTask, "workflowState", "Closed as done").

policyCheckFailure(
    Card,
    "Secure development",
    "The review subtasks of approved requirements must be closed as done",
    "Not all review tasks are closed as done. Complete the reviews."
    ) :-
        field(Card, "cardType", "secdeva/cardTypes/requirement"),
        not field(Card, "workflowState", "Draft"),
        not field(Card, "workflowState", "Closed as rejected"),
        parent(ReviewTask, Card),
        not field(ReviewTask, "workflowState", "Closed as done").

onTransitionExecuteTransition(Requirement, "Reopen", ReviewTask, "Reopen") :-
    field(Requirement, "cardType", "secdeva/cardTypes/requirement"),
    parent(ReviewTask, Requirement),
    field(ReviewTask, "cardType", "base/cardTypes/task").
