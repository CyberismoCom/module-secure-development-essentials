%* Assertion tests for the requirement mapping rules
(secdeva/calculations/requirementMapping)

Run from the project root:

    cyberismo calc run tests/requirement-mapping.lp

The tests pass when "results" is empty. Each result is one failed assertion.
The fixtures are under "Test content" > "Test project" > "Testing - requirement
mapping", and one card under "Layered test project" has the same identifier as
a refinement in the test project. Their identifiers start with secdeva_test_map_.
*%

% Mapping facts, as an extension module would give them
secdeva_refines("secdeva_test_map_refinement-a1", "secdeva_test_map_essential-a").
secdeva_refines("secdeva_test_map_refinement-a2", "secdeva_test_map_essential-a").
secdeva_refines("secdeva_test_map_refinement-b1", "secdeva_test_map_essential-b").
secdeva_implements("secdeva_test_map_essential-a", "secdeva_test_map_compliance-c", "Checklist section 1").

% Test evidence, as a connector would give it
ismsa_testEvidence("secdeva_test_map_refinement-a1", "run-1", "passed", "2026-11-20", "1.0.0").
ismsa_testEvidence("secdeva_test_map_essential-b", "run-1", "passed", "2026-11-20", "1.0.0").

% secdeva_test_expectLink(SourceIdentifier, DestinationIdentifier, LinkType), in the test project
secdeva_test_expectLink("secdeva_test_map_refinement-a1", "secdeva_test_map_essential-a", "secdeva/linkTypes/refines").
secdeva_test_expectLink("secdeva_test_map_refinement-a2", "secdeva_test_map_essential-a", "secdeva/linkTypes/refines").
secdeva_test_expectLink("secdeva_test_map_refinement-b1", "secdeva_test_map_essential-b", "secdeva/linkTypes/refines").
secdeva_test_expectLink("secdeva_test_map_essential-a", "secdeva_test_map_compliance-c", "ismsa/linkTypes/implements").

% secdeva_test_expectAssessment(Identifier, Assessment, Explanation), in the test project
secdeva_test_expectAssessment("secdeva_test_map_refinement-a1", "ok", "The requirement has been reviewed and verified").
secdeva_test_expectAssessment("secdeva_test_map_essential-a", "open", "The requirement has been reviewed but a verification is not ready").
secdeva_test_expectAssessment("secdeva_test_map_essential-b", "ok", "The requirement has been reviewed and verified").
secdeva_test_expectAssessment("secdeva_test_map_compliance-c", "open", "The requirement is in scope but the linked implementation is not ready").


secdeva_test_mapProject(Project) :-
    projectCard(Project),
    field(Project, "title", "Test project"),
    base_projectCardType(Project, "secdeva/cardTypes/project2").

secdeva_test_mapCard(Id, Card) :-
    secdeva_test_mapProject(Project),
    secdeva_closestProject(Card, Project),
    field(Card, "base/fieldTypes/identifier", Id).

secdeva_test_failure(@concatenate(Source, " -> ", Destination), "link missing") :-
    secdeva_test_expectLink(Source, Destination, LinkType),
    not secdeva_test_linked(Source, Destination, LinkType).

secdeva_test_linked(Source, Destination, LinkType) :-
    secdeva_test_expectLink(Source, Destination, LinkType),
    secdeva_test_mapCard(Source, SourceCard),
    secdeva_test_mapCard(Destination, DestinationCard),
    link(SourceCard, DestinationCard, LinkType).

% A refinement in another project must not refine the essential of the test project
secdeva_test_failure(Id, "linked across projects") :-
    secdeva_test_mapProject(Project),
    field(Card, "base/fieldTypes/identifier", Id),
    secdeva_closestProject(Card, OtherProject),
    OtherProject != Project,
    link(Card, Essential, "secdeva/linkTypes/refines"),
    secdeva_closestProject(Essential, Project).

secdeva_test_failure(Id, @concatenate("assessment is not ", Expected)) :-
    secdeva_test_expectAssessment(Id, Expected, _),
    not secdeva_test_assessed(Id, Expected).

secdeva_test_assessed(Id, Expected) :-
    secdeva_test_expectAssessment(Id, Expected, _),
    secdeva_test_mapCard(Id, Card),
    field(Card, "base/fieldTypes/assessment", Expected).

secdeva_test_failure(Id, @concatenate("explanation is not: ", Expected)) :-
    secdeva_test_expectAssessment(Id, _, Expected),
    secdeva_test_mapCard(Id, Card),
    not field(Card, "base/fieldTypes/assessmentExplanation", Expected).

result((Subject, Reason)) :- secdeva_test_failure(Subject, Reason).
