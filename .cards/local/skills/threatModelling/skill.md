# Threat modelling in Cyberismo

A threat model describes a system as a dataflow diagram (DFD) and records the threats, weaknesses and countermeasures that follow from it. In Cyberismo, the diagram is not drawn by hand: it is rendered from cards and links. Each element of the diagram (trust boundary, process, data store, external entity, person) is a card, and each dataflow is a link between two cards.

This works for software products and for operational technology (OT), such as a power plant, where the diagram can follow the Purdue model.

## Where threat models live

Create every threat model **inside a project**, a card of type `secdeva/cardTypes/project2` (template `secdeva/templates/project2`). Put it under the project's **Design** phase, the child card whose `base/fieldTypes/identifier` is `secdeva_phase_design`. Do not create threat models as separate cards at the root of the navigation tree.

The project connects the threat model to everything else:

- The project's *Manage threat models* control lists the threat model as its evidence automatically.
- Risks go to the project's **Risks** register, security issues to **Security issues**, security requirements to **Security requirements**, and the products that implement the elements to the **Solution structure**.
- Processes, data stores and interfaces of the threat model are assets of the project.

### Projects in this Cyberismo project

{{#each results}}
{{#if this.projects}}
{{#each this.projects}}
- **{{this.title}}** (`{{this.key}}`){{#if this.designPhase}}, Design phase `{{this.designPhase.key}}`{{/if}}
{{#if this.threatModels}}
{{#each this.threatModels}}
  - Threat model: **{{this.title}}** (`{{this.key}}`)
{{/each}}
{{else}}
  - No threat models yet.
{{/if}}
{{/each}}
{{else}}
There are no projects yet. Create one with `create_card(projectPrefix, template="secdeva/templates/project2")`, set its title with `edit_card_metadata`, and create the threat model under its Design phase.
{{/if}}
{{#if this.modelsOutsideProjects}}

These threat models are not inside a project. Move each one under the Design phase of a project with `move_card(cardKey="<threat model>", destinationKey="<design phase>")`:

{{#each this.modelsOutsideProjects}}
- **{{this.title}}** (`{{this.key}}`)
{{/each}}
{{/if}}
{{/each}}

## Creating a threat model

1. Find or create the project, and find its Design phase (listed above).
2. `create_card(template="secdeva/templates/threatModel2", parentKey="<design phase key>")`. The threat model card is also the dataflow model: the elements of the diagram are its children.
3. Set the title, such as "Threat model for Koskela hydro power plant".
4. The template creates a default trust boundary and a default person. Rename and reuse them, or remove them.

## Workflow

1. **Model the system.** Create the elements and the dataflows. Load the skill `secdeva/skills/dataflowModel`.
2. **Document the attack surface.** Create interfaces for the elements that receive dataflows across a trust boundary. Load `secdeva/skills/interfaces`.
3. **Make the diagrams readable.** Choose the layout, label the elements and create targeted views. Load `secdeva/skills/dataflowDiagrams`.
4. **Identify threats.** Analyse the dataflows that cross trust boundaries with STRIDE, and record risks, security issues, security requirements and products in the project's registers. Load `secdeva/skills/threatIdentification`.
5. **Review.** The threat model has a document review task. Review and approve the threat model, and review it again when the design changes, and at least annually.

The skills of steps 1 to 4 are enabled for the threat model card and for each element of its diagram. Load them with the threat model's card key: `get_skill(projectPrefix, name="secdeva/skills/dataflowModel", cardKey="<threat model key>")`. Their instructions include the current state of that threat model, such as elements that are missing descriptions, dataflows that cross trust boundaries, and the card keys of the project's registers.

## Working with the cards

- Read a card and its children: `get_card(projectPrefix, cardKey)`. The response shows the rendered diagrams of a threat model.
- Find cards: `list_cards(projectPrefix)`.
- Create elements: `create_card(projectPrefix, template, parentKey)`. Then set the title and fields with `edit_card_metadata`.
- Create dataflows: `create_link(projectPrefix, sourceKey, destinationKey, linkType="secdeva/linkTypes/dataflow", description="Purpose [protocol]")`. The label goes in the parameter `description`.
