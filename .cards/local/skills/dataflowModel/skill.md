# Build a dataflow model

{{#each results}}
This skill is for the threat model **{{this.title}}** (`{{this.key}}`). Number of elements: trust boundaries {{this.boundaryCount}}, processes {{this.processCount}}, data stores {{this.dataStoreCount}}, persons and external entities {{this.outsidePartyCount}}, interfaces {{this.interfaceCount}}, dataflows {{this.dataflowCount}}.

{{#if this.missingDescription}}
**Elements without a description** — add one with `edit_card_metadata(field="secdeva/fieldTypes/description")`:
{{#each this.missingDescription}}
- {{this.title}} (`{{this.key}}`)
{{/each}}

{{/if}}
{{#if this.boundaryWithoutType}}
**Trust boundaries without a type** — set `secdeva/fieldTypes/trustBoundaryType`:
{{#each this.boundaryWithoutType}}
- {{this.title}} (`{{this.key}}`)
{{/each}}

{{/if}}
{{#if this.outsidePartyInTechnicalBoundary}}
**Persons or external entities inside a technical trust boundary** — move them out, or into a physical or organisational boundary:
{{#each this.outsidePartyInTechnicalBoundary}}
- {{this.title}} (`{{this.key}}`)
{{/each}}

{{/if}}
{{#if this.withoutDataflows}}
**Elements without any dataflows** — connect them, or remove them if they play no part:
{{#each this.withoutDataflows}}
- {{this.title}} (`{{this.key}}`)
{{/each}}

{{/if}}
{{#if this.undescribedDataflows}}
**Dataflows without a label** — they are not drawn. Remove them and create them again with a `description`:
{{#each this.undescribedDataflows}}
- {{this.sourceTitle}} → {{this.destinationTitle}}
{{/each}}

{{/if}}
{{/each}}
## The model

The threat model card is the dataflow model. Its children are the elements of the diagram, and the diagrams are rendered from the cards and their links. (In older projects, the elements may be under a separate dataflow model card, `secdeva/cardTypes/dataflowModel`. It works the same way.)

| Element | Card type | Template | Drawn as |
|---|---|---|---|
| Trust boundary | `secdeva/cardTypes/trustBoundary` | `secdeva/templates/trustBoundary2` | Dashed frame: red, or grey for physical and organisational boundaries |
| Process | `secdeva/cardTypes/process` | `secdeva/templates/process2` | Rounded rectangle |
| Data store | `secdeva/cardTypes/dataStore` | `secdeva/templates/dataStore2` | Cylinder |
| External entity | `secdeva/cardTypes/external` | `secdeva/templates/external2` | Rectangle |
| Person | `secdeva/cardTypes/person` | `secdeva/templates/person2` | Rectangle |
| Group (not a DFD element) | `secdeva/cardTypes/group` | `secdeva/templates/group` | Grey rectangle with its title, if shown; keeps its elements together |
| Interface (see `secdeva/skills/interfaces`) | `secdeva/cardTypes/interface` | `secdeva/templates/interface2` | Not drawn; its port is added to the dataflow labels |

Do not use the deprecated templates without the suffix 2 (`secdeva/templates/process` and so on).

Create an element with `create_card(template, parentKey)`, then set its title with `edit_card_metadata(field="title")`.

### Hierarchy

- An element inside a trust boundary is a child of that trust boundary card. An element outside all trust boundaries is a direct child of the threat model card.
- Nested trust boundaries are nested zones: "Data centre" → "Server" → "Docker internal network".
- Persons and external entities are outside all technical trust boundaries. They may be inside a physical or organisational trust boundary (see below).
- Move an element with `move_card(cardKey, destinationKey)`: to a trust boundary to place it inside, or to the threat model card to place it outside all boundaries.

## Element fields

- `secdeva/fieldTypes/description`: shown inside the box on the diagram. **One or two short sentences.** Long descriptions make the boxes huge and the diagram unusable.
- `secdeva/fieldTypes/technology`: the product or technology, such as "Keycloak 23", "PostgreSQL 16" or "Siemens S7-1500".

| Good description | Bad description |
|---|---|
| External OIDC identity provider managed by customer | External OIDC identity provider managed by the customer organisation, used for single sign-on federation via Microsoft Entra ID with SAML and OpenID Connect protocols... |
| Stores user credentials and realm config | PostgreSQL database storing Keycloak user credentials, session tokens, realm configuration, client secrets, authentication events with 30-day retention... |

**Data stores** must say what data they hold, especially sensitive or critical data, so that the store can be analysed from the diagram alone: list the categories of data ("User credentials, session tokens, realm configuration") and name secrets, personal data and regulated data explicitly.

**Descriptions must match the dataflows.** If a description says "validates JWT from oauth2-proxy", there must be a dataflow from oauth2-proxy.

## Naming

- Name the element by **what it is**: the product or service ("Keycloak", "Microsoft Entra ID", "Siemens S7-1500 unit PLC"), or a role ("User", "Control room operator").
- Processes: by what they do or what component they are ("Edge proxy", "SCADA server", "Jump host").
- Data stores: by what they store ("Project data", "Process history archive").
- Trust boundaries: by the zone they represent ("Docker internal network", "OT DMZ (L3.5)").

## Dataflows

A dataflow is a link of type `secdeva/linkTypes/dataflow`:

`create_link(sourceKey, destinationKey, linkType="secdeva/linkTypes/dataflow", description="Read process history [HTTPS]")`

- The label goes in the parameter **`description`**. `linkDescription` is silently ignored, and a dataflow without a label is not drawn.
- The arrow points from the element that **initiates** the connection to the one that receives it: the backend connects to the database, so the arrow goes from the backend to the database. With interfaces, the destination is the listening side.
- Label format: `<purpose> [<protocol>]`, such as `Authenticate user [HTTPS]` or `Gate commands and status [Modbus TCP]`.
- The protocol is **required** for dataflows that cross a trust boundary, and recommended for the others.
- Keep labels short; they are drawn on the arrows.

| Good label | Bad label |
|---|---|
| `Auth requests [HTTPS]` | `LDAP bind and search requests for user authentication and group membership sync, plus OIDC token validation via JWKS endpoint...` |
| `Notifications [SMTP]` | `Outbound notifications: webhook HTTP POST (JSON payload), SMTP email (JavaMail), Slack webhooks...` |

- **One arrow per connection.** Responses do not need an arrow of their own. Create arrows in both directions only if both ends initiate connections independently.
- `remove_link` cannot remove a link that has a description. To change a dataflow, create the new link, and ask the user to remove the old one in the Cyberismo app. Do not edit the project files directly.

## Model the whole system

Cover every concern area, not only the production stack: users and production services, authentication (identity providers, credential stores), monitoring, and operations (deployment tooling, CI/CD, administrators, jump hosts, remote access). An element that is not modelled cannot appear in any view or threat analysis. In OT systems, also model engineering workstations, historians, remote access paths, vendor connections, and local panels and maintenance ports.

## Combine or separate elements

Keep the diagram readable by **combining elements that interact with the system in the same way** (same connections, same protocols), and list what was combined in the description:

- Users with different roles but the same access path → one "User" with "Roles: administrator, editor, reader".
- Database replicas, or several instances behind a load balancer → one element.

**Separate** elements whose dataflows or access paths differ: an administrator with a separate admin interface, a read-only reporting database next to the primary, an internal service on a different protocol.

**Repeating patterns** (one silo per customer, one control system per generating unit): model one representative with "(per customer)" or "(per unit)" in its title.

## Trust boundaries

A trust boundary is where the system **cannot trust incoming data**. Draw boundaries by trust, not by where containers happen to run.

- **Client-side code is untrusted.** A single-page application runs in the user's browser, so it is outside the backend's boundary, even if a backend container serves its files.
- **Databases are separate zones**, with their own authentication. The connection from the application to the database crosses a boundary; this is where injection attacks live.
- **In-process resources share trust**: an in-memory cache or a local file can share the application's boundary.
- **One boundary per independently secured zone.** Use several when components authenticate to each other or have different privileges. Nest boundaries only when crossing them changes the level of trust, not to group by team or by deployment stage.
- **In OT systems**, use one boundary per network zone of IEC 62443 (for example enterprise, OT DMZ, operations, and one zone per production cell), and set their type to `networkFiltered`.

Set `secdeva/fieldTypes/trustBoundaryType` on every trust boundary: `networkFiltered`, `networkUnfiltered`, `cloudTenant`, `host`, `executionEnvironmentConfined`, `executionEnvironmentPrivileged`, `process`, `logical`, `physical` or `organisational`.

### Persons and external entities inside a boundary

| Boundary type | Persons and external entities inside? |
|---|---|
| `physical` (site, building, room, cabinet) | Yes: the person has physical access there, or the equipment you do not control is located there |
| `organisational` (the edge of your organisation's control) | Yes: the person belongs to the organisation, such as employees inside and contractors outside |
| Any other type | No |

A person inside a boundary is still not trusted: its dataflows still cross a trust boundary. The placement records **who has physical or organisational access**, which matters for insiders, removable media and maintenance laptops in OT. A card has one parent, so put physical boundaries outermost and network zones inside them: "Plant site" (physical) → "Control network" → cell zones, with the control room operator as a direct child of the plant site.

## Systems and groups

**Systems.** To get an overview diagram, group the components of a real system under a parent process, such as "SCADA system" containing the SCADA server, the historian and its archive. The context diagram then shows the system as one box. Group only real systems with a name and an owner, and only inside one zone. Keep security-critical elements, such as jump hosts, remote access gateways and modems, visible. Link dataflows to the components, not to the system.

**Groups.** A group (`secdeva/templates/group`) organises elements in the navigation tree and arranges the diagrams, and nothing else. It is not an asset, not a trust boundary, and never the end of a dataflow. Use a group for elements that belong together but share no trust boundary or system, such as the clients of a service, a set of partner services, or zones that are side by side.

The field `secdeva/fieldTypes/showInDiagrams` decides whether the group is drawn. The group template sets it to `true`.

- **Shown** (`true`): the group is drawn as a grey rectangle with its title around its elements, in every layout and view.
- **Hidden** (`false` or empty): the group has no frame or title. In the layout _Follow the dataflows_ its elements are still kept together. In the layout _Zones in tree order_ it doesn't keep its elements together, so that persons and external entities stay in the rows of the elements they connect to.

Hide a group that only organises the navigation tree, such as one that collects the off-site parties of a plant, with `edit_card_metadata(cardKey="<group>", field="secdeva/fieldTypes/showInDiagrams", value=false)`. In the layout _Zones in tree order_, a group that contains zones is one row either way, and its zones are drawn side by side.

| If the container… | Use |
|---|---|
| changes the level of trust when crossed | a trust boundary |
| is a site or the edge of an organisation | a trust boundary of type `physical` or `organisational` |
| is a real system with a name and an owner | a process |
| only organises the tree, keeps related elements together in a diagram, or puts zones side by side in a layered diagram | a group |

Never use a group to avoid modelling a trust boundary that exists.

## Example

A web application:

- Trust boundary "Application runtime" (`executionEnvironmentConfined`): process "Web App" [Node.js 20] — "Serves the SPA and the REST API"
- Trust boundary "Data tier" (`executionEnvironmentConfined`): data store "Database" [PostgreSQL 16] — "User credentials, session tokens. Contains password hashes and OIDC client secrets"
- Outside all boundaries: person "User" — "Roles: administrator, editor, reader"; external entity "Identity provider" [Microsoft Entra ID]
- Dataflows: User → Web App `Browse application [HTTPS]`; Web App → Database `Read and write data [PostgreSQL]`; Web App → Identity provider `Authenticate user [HTTPS]`

An OT system (a hydro power plant):

- Trust boundary "Enterprise zone (L4–L5)"; physical boundary "Plant site" containing "OT DMZ (L3.5)", "Plant operations zone (L3)" and "Control network (L0–L2)" with one zone per production cell, plus the control room operator and the field technician
- A process "SCADA system" grouping the SCADA server and the historian; jump host and patch server in the DMZ
- Outside the site: corporate users, remote vendor engineers, and the grid operator's control centre
