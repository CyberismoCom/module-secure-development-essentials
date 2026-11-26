% Extension modules can define installable extensions to cards with following kinds of facts:

% This is the legacy format, for secdeva/cardTypes/project:
%
% secdeva_installableExtension(
%     ExtensibleCardIdentifier,   % identifier of the card that can be extended
%     ModuleDescription,          % display name of the module that introduces an extension
%     Template,                   % the template that includes the extensions
%     ButtonLabel,                % button label for instantiating the extensions
%     ExampleIdentifier           % an example of an identifier of an extension, for checking whether the extension has been installed
% ).

% This is the new format, for secdeva/cardTypes/project2. 
% The checking is done based on the templateCard fields
%
% secdeva_installableExtension(
%     ExtensibleCardIdentifier,   % identifier of the card that can be extended
%     ModuleDescription,          % display name of the module that introduces an extension
%     Template,                   % the template that includes the extensions
%     ButtonLabel                 % button label for instantiating the extensions
% ).

% The secure development library: controls for teams that write or change
% software. The core controls are in secdeva/templates/project2.

secdeva_installableExtension(
    "secdeva_register_design-controls",
    "the secure development library",
    "secdeva/templates/secureDevelopmentDesign",
    "Add the secure development design controls"
).

secdeva_installableExtension(
    "secdeva_register_implementation-controls",
    "the secure development library",
    "secdeva/templates/secureDevelopmentImplementation",
    "Add the secure development implementation controls"
).

secdeva_installableExtension(
    "secdeva_register_releases-controls",
    "the secure development library",
    "secdeva/templates/secureDevelopmentReleases",
    "Add the secure development release controls"
).

secdeva_installableExtension(
    "secdeva_register_verification-controls",
    "the secure development library",
    "secdeva/templates/secureDevelopmentVerification",
    "Add the secure development verification controls"
).
