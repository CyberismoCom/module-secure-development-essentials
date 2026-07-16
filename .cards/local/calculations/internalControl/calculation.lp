editingContentDenied(InternalControl, "Internal controls are read-only") :-
  field(InternalControl, "cardType", "ismsa/cardTypes/internalControl"),
  ancestor(InternalControl, DevelopmentProject),
  field(DevelopmentProject, "cardType", "secdeva/cardTypes/project").