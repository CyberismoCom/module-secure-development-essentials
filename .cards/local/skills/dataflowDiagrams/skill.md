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

- **`dataflows` — follow the dataflows (the default).** Elements are placed by the direction of the dataflows, so the elements that start connections are above the ones they connect to. The navigation tree order sets the left-to-right order. The elements of a group are kept together; a shown group is drawn as a grey rectangle around them. This suits typical software and IT models, where data mostly flows one way, from users inwards.
- **`zoneLayers` — zones in tree order.** For layered architectures, such as the Purdue model or ISA-95 in OT systems, or tiered networks. The card tree dictates the layout:
  - **Zones are stacked from top to bottom in tree order.** A zone is an outermost technical trust boundary; physical and organisational boundaries around it, such as a site, do not count. Rank the zones from the top level down with `rank_card_after`: enterprise (L4–L5), DMZ (L3.5), operations (L3), control (L0–L2).
  - **Zones side by side need a common parent**: a zone that really exists, such as a control network behind the L3 firewall with one zone per production cell, or else a group. Do not create a trust boundary or a process only for the layout.
  - **Persons and external entities** are placed automatically in the highest row of the elements they exchange dataflows with.
  - **Within a zone, the dataflows decide the order**, so an HMI is usually drawn above its PLC.
  - **Hidden groups set rows only.** They don't keep their elements together in this layout, so that persons and external entities stay in the rows of the elements they connect to. A shown group is drawn as a grey rectangle around its elements, so show only groups whose elements share a row, such as zones side by side.

Do not switch an existing model to `zoneLayers` unless its zones really are layers: peer zones, such as a user's computer, a code hosting service and a CI pipeline, are drawn worse when they are stacked.

## Views

Show a diagram on any card with the `graph` macro (edit the content with `edit_card_content`). The model is always `secdeva/graphModels/dataflow`:

```
\{{#graph}}
  "model": "secdeva/graphModels/dataflow",
  "view": "secdeva/graphViews/context",
  "cardKey": "<threat model key>",
  "mergeDataflows": true
\{{/graph}}
```

| View | Shows | Use it for |
|---|---|---|
| `secdeva/graphViews/context` | The top-level elements under `cardKey`. A system (a process with components) is one box. Trust boundaries are drawn around what they contain | The overview. The threat model report shows it |
| `secdeva/graphViews/allEntities` | Every element under `cardKey`, nested inside its trust boundaries and systems | The detailed diagram. The threat model report shows it |
| `secdeva/graphViews/entity` | The card `cardKey` with everything inside it, and the elements it exchanges dataflows with | One system or one zone in detail. Element pages show it |
| `secdeva/graphViews/label` | Only the elements that carry one of `labels`, inside their trust boundaries, and the dataflows between them | Targeted views |
| `secdeva/graphViews/zones` | Zones and conduits (IEC 62443-3-2): each innermost zone as one box, nested zones and physical boundaries as frames, persons and external entities on their own, and all dataflows between two boxes merged into one conduit labelled with their number | The zone-level overview of an OT model |

### Parameters

| Parameter | Views | Value and effect |
|---|---|---|
| `model`, `view` | all | Required: `secdeva/graphModels/dataflow` and one of the views above |
| `cardKey` | `context`, `allEntities`, `entity` | The card whose elements are drawn. It defaults to the card that contains the macro, so **on a page, set it to the threat model's key** (or to a trust boundary or system for a part of the model); otherwise the diagram is empty |
| `show` | `context`, `entity` | A list of card keys of further elements to draw as boxes, such as a component inside a system in the context view, or a neighbour in the entity view: `"show": ["<key>", "<key>"]` |
| `labels` | `label` | A list of labels; an element is shown if it has any of them: `"labels": ["remote-access", "engineering"]` |
| `root` | `zones` | The card key that limits the scope, normally the threat model. Without it, the zones of every model in the project are drawn |
| `mergeDataflows` | `context`, `allEntities`, `entity`, `label` | `true` draws all dataflows between the same two boxes as one arrow, with one line per dataflow in its label. Use it for overviews. The zones view always merges dataflows into conduits |
| `layout` | all | The Graphviz direction: `"TB"` (top to bottom, the default), `"LR"`, `"BT"` or `"RL"`. With the layered layout, `"LR"` turns the rows into columns |

**The label view is not limited to one threat model:** it shows every element in the project that has the label. If the project has several threat models, use labels that are distinct for each model, such as `plant-a-remote-access`.

## Labels

Labels slice a large diagram into focused views, one per concern area.

- Label **every** process, data store, external entity and person (not trust boundaries, interfaces or groups) with at least one label: `create_label(cardKey, label)`. Use `list_labels` to see the labels in use, and `remove_label` to fix mistakes. Labels are case-sensitive; use lowercase words joined with hyphens.
- A system (a process with components) does not need labels of its own: its labelled components are shown inside it.
- Derive labels from the architecture, not from the organisation:
  - Software: `production`, `authentication`, `operations`, `monitoring`.
  - OT: `remote-access`, `engineering`, `supervisory-control`, one label per production cell (`unit-control`, `dam-safety`), `grid-interface`, `business-data`, `patching`.
- **Each view must be self-contained.** If an element takes part in a flow of the concern, it needs the label too: a user who logs in belongs to `authentication` as well as `production`. Overlap is expected; an element can have several labels.
- Aim for 3 to 8 elements per label. A label with one or two elements is too narrow; one with nearly the whole diagram is too broad.
- An element without labels appears in no targeted view, only in the full diagrams.

## The Targeted views page

Put all label-based views of a threat model on **one page** under the threat model card. Do not create a card per label.

1. `create_card(template="base/templates/page", parentKey="<threat model>")`, and set its title to "Targeted views".
2. Write its content with `edit_card_content`: one section per concern. Each section has a heading, one sentence that says what the view shows, and a `graph` macro with the label view.
3. For an OT model, start the page with the zones-and-conduits overview, and optionally the context view with merged dataflows.
4. Read the page with `get_card` and check that each view is self-contained, and that its elements carry the right labels.

Example content:

```
== Zones and conduits

The zones of the plant and the conduits between them.

\{{#graph}}
  "model": "secdeva/graphModels/dataflow",
  "view": "secdeva/graphViews/zones",
  "root": "<threat model key>"
\{{/graph}}

== Remote access

Remote connections of vendors and engineers into the plant.

\{{#graph}}
  "model": "secdeva/graphModels/dataflow",
  "view": "secdeva/graphViews/label",
  "labels": ["remote-access"]
\{{/graph}}

== Unit control system

The control system of one generating unit and its connections.

\{{#graph}}
  "model": "secdeva/graphModels/dataflow",
  "view": "secdeva/graphViews/entity",
  "cardKey": "<unit control system key>"
\{{/graph}}
```

When the model changes, update the labels of new elements, so that the targeted views stay complete.

## Checking the result

Read the threat model card with `get_card` to see the rendered diagrams. Check that the labels are short, that no elements are missing from the views, and that the layers are in the right order.
