% Assets that have been directly added in the asset register are shown in the
% register report instead of the navigation

hiddenInTreeView(Asset) :-
  ancestor(Asset, AssetRegister),
  field(AssetRegister, "base/fieldTypes/identifier", "secdeva_register_assets"),
  ismsa_asset(Asset).

% Asset cards of the ISMS essentials module
%
% A development project can hold asset cards of the ISMS essentials module, created
% from the asset templates directly under the asset register. A development project
% is not an ISMS, so the asset control of the ISMS essentials module is switched off
% for them and the asset model of a development project applies instead: what is
% required of them is defined on the asset register.

secdeva_ismsAssetCardType("ismsa/cardTypes/asset").
secdeva_ismsAssetCardType("ismsa/cardTypes/assetData").
secdeva_ismsAssetCardType("ismsa/cardTypes/assetDevice").
secdeva_ismsAssetCardType("ismsa/cardTypes/assetInformationSystem").
secdeva_ismsAssetCardType("ismsa/cardTypes/assetSupplier").

secdeva_ismsAsset(Asset) :-
  secdeva_ismsAssetCardType(CardType),
  base_projectCardType(Asset, CardType),
  secdeva_closestProject(Asset, Project),
  base_projectCardType(Project, "secdeva/cardTypes/project2").

ismsa_disableAssetControl(Asset) :- secdeva_ismsAsset(Asset).
