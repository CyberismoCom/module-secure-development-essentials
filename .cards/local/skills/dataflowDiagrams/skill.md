# Dataflow diagrams and views

{{#each results}}
This skill is for the threat model **{{this.title}}** (`{{this.key}}`). Its diagram layout is **{{#if this.layered}}zones in tree order{{else}}follow the dataflows{{/if}}**.

{{#if this.labels}}
Labels in use:
{{#each this.labels}}
- `{{this.label}}`: {{this.count}} elements
{{/each}}
{{else}}
No elements are labelled yet.
{{/if}}

{{#if this.unlabelled}}
**Elements without labels** — they appear in no targeted view:
{{#each this.unlabelled}}
- {{this.title}} (`{{this.key}}`)
{{/each}}

{{/if}}
{{#if this.pages}}
Pages under the threat model: {{#each this.pages}}{{this.title}} (`{{this.key}}`){{#unless @last}}, {{/unless}}{{/each}}.
{{else}}
There is no page under the threat model yet. Create a "Targeted views" page (see below).
{{/if}}

{{/each}}
## Diagram layout

The field `secdeva/fieldTypes/diagramLayout` of the threat model card selects how the diagrams are laid out:

- **`dataflows` — follow the dataflows (the default).** Elements are placed by the direction of the dataflows, so the elements that start connections are above the ones they connect to. The navigation tree order sets the left-to-right order. This suits typical software and IT models, where data mostly flows one way, from users inwards.
- **`zoneLayers` — zones in tree order.** For layered architectures, such as the Purdue model or ISA-95 in OT systems, or tiered networks. The card tree dictates the layout:
  - **Zones are stacked from top to bottom in tree order.** A zone is an outermost technical trust boundary; physical and organisational boundaries around it, such as a site, do not count. Rank the zones from the top level down with `rank_card_after`: enterprise (L4–L5), DMZ (L3.5), operations (L3), control (L0–L2).
  - **Zones side by side need a common parent**: a zone that really exists, such as a control network behind the L3 firewall with one zone per production cell, or else a group. Do not create a trust boundary or a process only for the layout.
  - **Persons and external entities** are placed automatically in the highest row of the elements they exchange dataflows with.
  - **Within a zone, the dataflows decide the order**, so an HMI is usually drawn above its PLC.

Do not switch an existing model to `zoneLayers` unless its zones really are layers: peer zones, such as a user's computer, a code hosting service and a CI pipeline, are drawn worse when they are stacked.

## Views

Show a diagram on any card with the `graph` macro (edit the content with `edit_card_content`):

```
\{{#graph}}
  "model": "secdeva/graphModels/dataflow",
  "view": "secdeva/graphViews/context",
  "mergeDataflows": true
\{{/graph}}
```

| View | Shows | Parameters |
|---|---|---|
| `secdeva/graphViews/context` | The top-level elements of the card's model; systems (processes with components) as single boxes | `show`: list of card keys to expand |
| `secdeva/graphViews/allEntities` | All elements under the card | |
| `secdeva/graphViews/entity` | One element and its contents | `show` |
| `secdeva/graphViews/label` | Only the elements with the given labels, and the dataflows between them | `labels`: list of labels |
| `secdeva/graphViews/zones` | Zones and conduits (IEC 62443-3-2): each innermost zone as one box, nested zones and physical boundaries as frames, and all dataflows between two boxes merged into one conduit | `root`: card key that limits the scope, such as the threat model |

Parameters that every view accepts:

- `"mergeDataflows": true` draws all dataflows between the same two boxes as one arrow, with one line per dataflow in the label. Use it for overview diagrams. The threat model report uses it for its context diagram.
- `"highlightRowSkips": true` (with the layered layout) draws in red every dataflow that skips a layer, such as a vendor's remote connection directly into a control zone that bypasses the DMZ. The zones view always highlights them.
- `"layout"`: Graphviz direction, such as `"LR"` for left to right. Not needed with the layered layout.

The threat model report already shows the context and detailed diagrams. For OT models, add the zones view and highlighted views to a page under the threat model.

## Labels and targeted views

Labels slice a large diagram into focused views, one per concern area.

- Label **every** process, data store, external entity and person (not trust boundaries, interfaces or groups) with at least one label: `create_label(cardKey, label)`. Use `list_labels` to see the labels in use. Labels are case-sensitive.
- Derive labels from the architecture, not from the organisation:
  - Software: `production`, `authentication`, `operations`, `monitoring`.
  - OT: `remote-access`, `engineering`, `supervisory-control`, one label per production cell (`unit-control`, `dam-safety`), `grid-interface`, `business-data`, `patching`.
- **Each view must be self-contained.** If an element takes part in a flow of the concern, it needs the label too: a user who logs in belongs to `authentication` as well as `production`. Overlap is expected.
- Aim for 3 to 8 elements per label. A label with one or two elements is too narrow; one with nearly the whole diagram is too broad.

Put all targeted views on **one page** under the threat model: `create_card(template="base/templates/page", parentKey="<threat model>")`, titled "Targeted views". Give it one section per label:

```
== Remote access

Remote connections of vendors and engineers into the plant.

\{{#graph}}
  "model": "secdeva/graphModels/dataflow",
  "view": "secdeva/graphViews/label",
  "labels": ["remote-access"],
  "highlightRowSkips": true
\{{/graph}}
```

For an OT model, start the page with the zones-and-conduits overview:

```
== Zones and conduits

\{{#graph}}
  "model": "secdeva/graphModels/dataflow",
  "view": "secdeva/graphViews/zones",
  "root": "<threat model key>"
\{{/graph}}
```

## Checking the result

Read the threat model card with `get_card` to see the rendered diagrams. Check that the labels are short, that no elements are missing from the views, and that the layers are in the right order.
