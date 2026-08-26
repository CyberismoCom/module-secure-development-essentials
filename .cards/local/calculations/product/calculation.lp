% The solution structure records what the solution is made of. Relationships between
% products are links, never parent and child cards: product composition is a graph,
% and a component that belongs to two products cannot have two parents.

% secdeva_csafRelationship(Component, Product, Kind, Label) means that Component relates
% to Product in the way named by Kind. Label is the human-readable form used in reports.

secdeva_csafRelationship(A, B, "defaultComponentOf", "built-in component of") :-
    link(A, B, "secdeva/linkTypes/defaultComponentOf").
secdeva_csafRelationship(A, B, "externalComponentOf", "external dependency of") :-
    link(A, B, "secdeva/linkTypes/externalComponentOf").
secdeva_csafRelationship(A, B, "installedOn", "installed on") :-
    link(A, B, "secdeva/linkTypes/installedOn").
secdeva_csafRelationship(A, B, "installedWith", "installed alongside") :-
    link(A, B, "secdeva/linkTypes/installedWith").
secdeva_csafRelationship(A, B, "optionalComponentOf", "optional add-on of") :-
    link(A, B, "secdeva/linkTypes/optionalComponentOf").

% The same relationship reads differently from each end. The label in
% secdeva_csafRelationship describes the part ("optional add-on of X"); this one names
% what the part *is*, for tables that list the components of a product.

secdeva_csafPartLabel("defaultComponentOf", "built-in component").
secdeva_csafPartLabel("externalComponentOf", "external dependency").
secdeva_csafPartLabel("installedOn", "platform").
secdeva_csafPartLabel("installedWith", "bundled alongside").
secdeva_csafPartLabel("optionalComponentOf", "optional add-on").

% A relationship that makes us responsible for placing a distinct product on the market.
% A default component is absorbed into the product that contains it, so it is excluded.

secdeva_distributableRelationship(P) :-
    secdeva_csafRelationship(P, _, Kind, _),
    Kind != "defaultComponentOf".

%
% The planned economic operator role
%

secdeva_placedOnMarketByUs(P) :-
    base_projectCardType(P, "secdeva/cardTypes/product"),
    not field(P, "secdeva/fieldTypes/productOrigin", "own"),
    secdeva_distributableRelationship(P),
    not link(P, _, "secdeva/linkTypes/defaultComponentOf").

% The role is a calculated field with an override, so it is emitted as fieldCalculated
% and the runtime suppresses it whenever the user has set a value by hand.

secdeva_economicOperatorRoleIsCalculated(P) :-
    base_projectCardType(P, CardType),
    calculatedField(CardType, "secdeva/fieldTypes/economicOperatorRole"),
    overridableField(CardType, "secdeva/fieldTypes/economicOperatorRole").

secdeva_roleForDelivery("weDeliver", "distributor").
secdeva_roleForDelivery("weImportAndDeliver", "importer").
secdeva_roleForDelivery("weRebrandAndDeliver", "manufacturer").

fieldCalculated(P, "secdeva/fieldTypes/economicOperatorRole", Role) :-
    secdeva_placedOnMarketByUs(P),
    secdeva_economicOperatorRoleIsCalculated(P),
    field(P, "secdeva/fieldTypes/deliveryModel", Delivery),
    secdeva_roleForDelivery(Delivery, Role).

% Delivery models under which the product is never placed on the market, so no economic
% operator role arises. weOperateAsService and weConsumeAsService differ in who runs the
% software, which matters a great deal for security management but not for the CRA.

secdeva_notPlacedOnMarket("customerProvides").
secdeva_notPlacedOnMarket("weOperateAsService").
secdeva_notPlacedOnMarket("weConsumeAsService").

% Developing a product ourselves makes us its manufacturer only if we actually place it
% on the market. A service we host is not placed on the market and carries no economic
% operator role. The role follows from the delivery model, so an own product with none
% recorded has no role yet, and the policy check below asks for one.

secdeva_ownProductNotPlacedOnMarket(P) :-
    base_projectCardType(P, "secdeva/cardTypes/product"),
    field(P, "secdeva/fieldTypes/productOrigin", "own"),
    field(P, "secdeva/fieldTypes/deliveryModel", Delivery),
    secdeva_notPlacedOnMarket(Delivery).

fieldCalculated(P, "secdeva/fieldTypes/economicOperatorRole", "manufacturer") :-
    base_projectCardType(P, "secdeva/cardTypes/product"),
    secdeva_economicOperatorRoleIsCalculated(P),
    field(P, "secdeva/fieldTypes/productOrigin", "own"),
    field(P, "secdeva/fieldTypes/deliveryModel", _),
    not secdeva_ownProductNotPlacedOnMarket(P).

fieldCalculated(P, "secdeva/fieldTypes/economicOperatorRole", "none") :-
    secdeva_economicOperatorRoleIsCalculated(P),
    secdeva_ownProductNotPlacedOnMarket(P).

fieldCalculated(P, "secdeva/fieldTypes/economicOperatorRole", "integratedComponent") :-
    base_projectCardType(P, "secdeva/cardTypes/product"),
    secdeva_economicOperatorRoleIsCalculated(P),
    not field(P, "secdeva/fieldTypes/productOrigin", "own"),
    link(P, _, "secdeva/linkTypes/defaultComponentOf").

fieldCalculated(P, "secdeva/fieldTypes/economicOperatorRole", "none") :-
    base_projectCardType(P, "secdeva/cardTypes/product"),
    secdeva_economicOperatorRoleIsCalculated(P),
    not field(P, "secdeva/fieldTypes/productOrigin", "own"),
    field(P, "secdeva/fieldTypes/deliveryModel", Delivery),
    secdeva_notPlacedOnMarket(Delivery).

% Which group a product belongs to follows from its origin field, not from where the
% card happens to sit in the tree. The grouping cards are browsing containers and a
% target for the create buttons; they are not what decides anything.

secdeva_productGroup(Product, "secdeva_group_own-products") :-
    base_projectCardType(Product, "secdeva/cardTypes/product"),
    field(Product, "secdeva/fieldTypes/productOrigin", "own").

secdeva_productGroup(Product, "secdeva_group_third-party-products") :-
    base_projectCardType(Product, "secdeva/cardTypes/product"),
    field(Product, "secdeva/fieldTypes/productOrigin", Origin),
    Origin != "own".

%
% Policy checks
%

policyCheckFailure(
    P, "Solution structure", "Origin is a required field",
    "Record whether this is an own product or a third-party product.") :-
        base_projectCardType(P, "secdeva/cardTypes/product"),
        not field(P, "workflowStateCategory", "initial"),
        not field(P, "secdeva/fieldTypes/productOrigin", _).

policyCheckFailure(
    P, "Solution structure", "Delivery model is a required field",
    "Record what we do with this product, including who is responsible for operating it. The planned economic operator role is derived from it.") :-
        base_projectCardType(P, "secdeva/cardTypes/product"),
        not field(P, "workflowStateCategory", "initial"),
        not field(P, "secdeva/fieldTypes/deliveryModel", _).

policyCheckFailure(
    P, "Solution structure", "An overridden economic operator role needs a justification",
    "The planned economic operator role has been set by hand. Record why in the economic operator role justification field.") :-
        base_projectCardType(P, "secdeva/cardTypes/product"),
        fieldOverride(P, "secdeva/fieldTypes/economicOperatorRole", _),
        not field(P, "secdeva/fieldTypes/economicOperatorRoleJustification", _).

policyCheckFailure(
    P, "Solution structure", "A distributor or importer needs a known vendor",
    "Both roles carry obligations to verify conformity marking and to reach the manufacturer. Record the vendor.") :-
        base_projectCardType(P, "secdeva/cardTypes/product"),
        fieldCalculated(P, "secdeva/fieldTypes/economicOperatorRole", Role),
        secdeva_roleNeedsVendor(Role),
        not field(P, "secdeva/fieldTypes/productVendor", _).

secdeva_roleNeedsVendor("distributor").
secdeva_roleNeedsVendor("importer").

policyCheckFailure(
    P, "Solution structure", "Placing a product under our own name makes us its manufacturer",
    "This product is delivered under our own name or substantially modified, which makes us the manufacturer. Assign an owner who is accountable for the manufacturer obligations.") :-
        base_projectCardType(P, "secdeva/cardTypes/product"),
        field(P, "secdeva/fieldTypes/deliveryModel", "weRebrandAndDeliver"),
        not field(P, "base/fieldTypes/owner", _).

% Products are assets of the project.

ismsa_asset(P, "Product") :- base_projectCardType(P, "secdeva/cardTypes/product").
ismsa_disableAssetControl(P) :- base_projectCardType(P, "secdeva/cardTypes/product").
