% Copyright © Cyberismo Ltd and contributors 2025
%
% License: https://github.com/CyberismoCom/module-secure-development-essentials/blob/main/LICENSE
% The use of the Cyberismo trademark: https://cyberismo.com/trademark-policy/
% This content is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.

policyCheckFailure(
    Card,
    "Secure development",
    "Release tasks must be done",
    @concatenate("This release task for ", ReleaseName, " has not been done. Do the task and close it as done.")
    ) :-
        field(Card, "cardType", "base/cardTypes/review"),
        parent(Card, Release),
        field(Release, "cardType", "secdeva/cardTypes/version"),
        field(Release, "title", ReleaseName),
        not field(Card, "workflowStateCategory", "closed").

policyCheckFailure(
    Card,
    "Secure development",
    "Release documents must be approved",
    @concatenate("This release document for ", ReleaseName, " has not been approved. Review and approve the document.")
    ) :-
        field(Card, "cardType", "base/cardTypes/controlledDocument"),
        ancestor(Card, Release),
        field(Release, "cardType", "secdeva/cardTypes/version"),
        field(Release, "title", ReleaseName),
        not field(Card, "workflowStateCategory", "closed").
