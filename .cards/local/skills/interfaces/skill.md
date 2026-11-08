# Document interfaces

{{#each results}}
This skill is for the threat model **{{this.title}}** (`{{this.key}}`), which has {{this.interfaceCount}} interfaces.

{{#if this.needInterfaces}}
**Elements that receive dataflows across a trust boundary but have no interfaces** — the attack surface that is not documented yet:
{{#each this.needInterfaces}}
- {{this.title}} (`{{this.key}}`)
{{/each}}

{{/if}}
{{#if this.bypassingDataflows}}
**Dataflows that go to an element instead of one of its interfaces** — reroute them to an interface:
{{#each this.bypassingDataflows}}
- {{this.sourceTitle}} → {{this.destinationTitle}}: "{{this.dataflow}}"
{{/each}}

{{/if}}
{{#if this.incompleteInterfaces}}
**Interfaces with missing authentication, transport security (logical interfaces only) or purpose:**
{{#each this.incompleteInterfaces}}
- {{this.ownerTitle}}: {{this.title}} (`{{this.key}}`)
{{/each}}

{{/if}}
{{#unless this.needInterfaces}}{{#unless this.bypassingDataflows}}{{#unless this.incompleteInterfaces}}
The interfaces of this threat model are complete.

{{/unless}}{{/unless}}{{/unless}}
{{/each}}
## What an interface is

An interface card documents one way into an element: a listening network service, or a physical port. It is a child of the process or data store that exposes it. Dataflows into the element are linked to the interface instead of the element itself.

The diagrams do not draw interfaces. They draw the dataflow to the element and add the interface's port to the label, such as "Remote desktop [RDP] (3389/tcp)". The threat model report lists every interface with its port, authentication, transport security and purpose, and whether it is external and whether its dataflows cross a trust boundary. These are the details that firewall rules, conduit requirements (IEC 62443-3-2) and security testing need.

## Which elements need interfaces

Model interfaces for the **attack surface**: every process or data store that receives dataflows across a trust boundary, or from persons or external entities. Elements with only internal dataflows do not need interfaces.

- **One interface per listening service.** If several dataflows use the same port, link all of them to the same interface. This shows, for example, that operational commands and engineering downloads share one unauthenticated Modbus port.
- **Once an element has interfaces, link all its incoming dataflows to them.** Otherwise the interface classification warns about dataflows to the parent element.
- **The destination of a dataflow is the listening side.** Only the destination can have a port.

## Creating an interface

1. `create_card(template="secdeva/templates/interface2", parentKey="<element>")` for a network service, or `create_card(template="secdeva/templates/physicalConnection", parentKey="<element>")` for a physical port.
2. Set the title: the service, such as "Modbus TCP server", "Remote Desktop" or "Front port".
3. Set the fields with `edit_card_metadata`:

| Field | Values |
|---|---|
| `secdeva/fieldTypes/interfaceType` | `logical` (a network service) or `physical` (a touch screen, front panel port, USB, local maintenance port) |
| `secdeva/fieldTypes/port` | Listening port and transport, such as `502/tcp`, `2404/tcp` or `4000-4100/udp`; `USB` or `Ethertype 0x8892` where it fits. Leave it empty if there is none |
| `secdeva/fieldTypes/interfaceAuthentication` | `required`, `optional` or `no` |
| `secdeva/fieldTypes/transportSecurity` | `required`, `optional` or `no` |
| `secdeva/fieldTypes/interfacePurpose` | A list of `operational`, `maintenance` and `debug` |
| `secdeva/fieldTypes/physicalConnectionCount` | For physical interfaces: how many such ports there are |

**Leave a field empty when it is not known**, and say in the card content that it is to be verified, for example with the vendor. Do not guess security properties.

4. Write one or two sentences of content with `edit_card_content`: what the interface is for and what is known about its security. Keep the classification report at the end of the content:

```
\{{#report}}
  "name": "secdeva/reports/threatModelInterface"
\{{/report}}
```

The template also creates a document review task under the interface. Keep it: inside a project, it is hidden in the navigation tree unless the project's adoption step is 3, which requires interface reviews.

## Rerouting a dataflow to an interface

Create the new link to the interface with the same label: `create_link(sourceKey, destinationKey="<interface>", linkType="secdeva/linkTypes/dataflow", description="<same label>")`. Then the old link to the element must go. `remove_link` cannot remove a link that has a description, so ask the user to remove it in the Cyberismo app. Do not edit the project files directly.

## Common OT protocols

| Protocol | Port | Usual security |
|---|---|---|
| Modbus TCP (also Schneider UMAS) | 502/tcp | No authentication, no encryption |
| Siemens S7comm / S7comm+ | 102/tcp | Optional access protection; TLS in newer firmware |
| IEC 61850 MMS | 102/tcp | Usually none (IEC 62351 is rare) |
| IEC 60870-5-104 | 2404/tcp | Usually none (IEC 62351 is rare) |
| DNP3 | 20000/tcp | Usually none (Secure Authentication is rare) |
| OPC UA | 4840/tcp | Optional: depends on the security mode |
| EtherNet/IP and CIP | 44818/tcp, 2222/udp | Usually none |
| PROFINET IO | Ethertype 0x8892 | None |
| Remote Desktop | 3389/tcp | Required (Network Level Authentication), TLS |
| AVEVA PI-to-PI | 5450/tcp | Windows authentication |
