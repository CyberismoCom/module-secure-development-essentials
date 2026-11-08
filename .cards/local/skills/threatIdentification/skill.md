# Identify threats

{{#each results}}
This skill is for the threat model **{{this.title}}** (`{{this.key}}`).

{{#if this.project}}
It is in the project **{{this.project.title}}** (`{{this.project.key}}`). Record the results in its registers:

| Register | Card key |
|---|---|
| Risks | {{#if this.riskRegister}}`{{this.riskRegister.key}}`{{else}}missing{{/if}} |
| Security issues | {{#if this.securityIssueRegister}}`{{this.securityIssueRegister.key}}`{{else}}missing{{/if}} |
| Security requirements | {{#if this.requirementRegister}}`{{this.requirementRegister.key}}`{{else}}missing{{/if}} |
| Own products (solution structure) | {{#if this.ownProducts}}`{{this.ownProducts.key}}`{{else}}missing{{/if}} |
| Third-party products (solution structure) | {{#if this.thirdPartyProducts}}`{{this.thirdPartyProducts.key}}`{{else}}missing{{/if}} |
| Decisions | {{#if this.decisionRegister}}`{{this.decisionRegister.key}}`{{else}}missing{{/if}} |
| Technology assessments | {{#if this.technologyAssessments}}`{{this.technologyAssessments.key}}`{{else}}missing{{/if}} |
{{else}}
**This threat model is not inside a project**, so there are no registers for its risks, security issues and requirements. Move it under the Design phase of a project first (see the skill `secdeva/skills/threatModelling`).
{{/if}}

{{#if this.crossingDataflows}}
### Dataflows that cross a trust boundary

Analyse each of these:

| Source | Destination | Dataflow | Interface |
|---|---|---|---|
{{#each this.crossingDataflows}}
| {{this.sourceTitle}} (`{{this.sourceKey}}`) | {{this.destinationTitle}} (`{{this.destinationKey}}`) | {{this.dataflow}} | {{#if this.interfaceKey}}{{this.interfaceTitle}}{{#if this.port}} ({{this.port}}){{/if}} (`{{this.interfaceKey}}`){{/if}} |
{{/each}}
{{else}}
No dataflows cross a trust boundary yet. Model the system first (`secdeva/skills/dataflowModel`).
{{/if}}

### Already recorded

{{#if this.risks}}Risks: {{#each this.risks}}{{this.title}} (`{{this.key}}`){{#unless @last}}; {{/unless}}{{/each}}
{{else}}No risks yet.
{{/if}}
{{#if this.issues}}Security issues: {{#each this.issues}}{{this.title}} (`{{this.key}}`){{#unless @last}}; {{/unless}}{{/each}}
{{else}}No security issues yet.
{{/if}}
{{#if this.requirements}}Security requirements: {{#each this.requirements}}{{this.title}} (`{{this.key}}`){{#unless @last}}; {{/unless}}{{/each}}
{{else}}No security requirements yet.
{{/if}}
{{#if this.products}}Products: {{#each this.products}}{{this.title}} (`{{this.key}}`){{#unless @last}}; {{/unless}}{{/each}}
{{else}}No products linked yet.
{{/if}}

Do not record the same threat or weakness twice: read the existing cards first.
{{/each}}

## What to analyse

Analyse **every dataflow that crosses a trust boundary**: the source and the destination are not in the same technical trust boundaries, or one end is a person or an external entity. Flows from persons and external entities always count, even when they are inside the same physical or organisational boundary. The table above lists them.

Also analyse:

- **Data stores** with sensitive or critical data: tampering, information disclosure, denial of service.
- **Processes exposed to untrusted input**: all six STRIDE categories.
- **Persons and external entities**: spoofing and repudiation.
- **Interfaces**: an interface without authentication or transport security on a crossing dataflow is a weakness in itself. In OT, so are maintenance and debug ports that are reachable from outside their zone.

Do not analyse internal dataflows within one trust boundary unless asked.

## STRIDE

| Category | Threat to | Question for each dataflow |
|---|---|---|
| **S**poofing | Authentication | Can an attacker pretend to be the source or the destination? |
| **T**ampering | Integrity | Can an attacker change the data in transit or at rest? |
| **R**epudiation | Non-repudiation | Can an actor deny an action, and would we know? |
| **I**nformation disclosure | Confidentiality | Can an attacker read data they should not see? |
| **D**enial of service | Availability | Can an attacker disrupt or exhaust this flow? |
| **E**levation of privilege | Authorisation | Can an attacker gain higher privileges through this flow? |

For each crossing dataflow: identify the source, the destination, the protocol and the data; ask each question; check what the technology provides (encryption, mutual authentication, input validation); and look for existing mitigations in the codebase, configuration or documentation. In OT, consider safety: can the attack cause physical damage, harm to people or the environment, or loss of a critical function?

**Be specific.** Name the components, the protocol and the attack. Prefer one finding that covers several dataflows with the same boundary crossing and protocol over duplicates. Do not invent threats that the technology rules out.

| Good title | Bad title |
|---|---|
| Spoofing: Forged OIDC tokens accepted by the gateway | Spoofing threat |
| Tampering: Unauthenticated Modbus writes to the spillway gate PLC from the operations zone | Data could be tampered with |
| Elevation of privilege: Unauthorised control of the turbine governor through the vendor 4G modem | Privilege escalation |

## How to record the results in the project

Record each finding as the right kind of card. The buttons on the element's page in the Cyberismo app do the same as the tool calls below.

| Finding | Card | Template, created under | Link |
|---|---|---|---|
| A **threat**: something that can cause harm by exploiting weaknesses | Risk | `secdeva/templates/productRisk2` in the Risks register | element → risk: `ismsa/linkTypes/presentsRisk`, from each affected element |
| A **weakness** or vulnerability in the design or in a component | Security issue | `secdeva/templates/securityIssue` in the Security issues register | element → issue: `ismsa/linkTypes/presentsRisk`; issue → risk: `secdeva/linkTypes/increasesRisk` |
| A **countermeasure** to build or enforce | Security requirement | `secdeva/templates/securityRequirement` in the Security requirements register | requirement → element: `secdeva/linkTypes/appliesTo`; requirement → risk or issue: `ismsa/linkTypes/mitigates` |
| A **product** that implements an element | Product | `secdeva/templates/thirdPartyProduct` or `secdeva/templates/ownProduct` in the solution structure | element → product: `secdeva/linkTypes/implementedBy` |
| A **design decision**, such as accepting a risk | Decision | `base/templates/decision` in the Decisions register | element → decision: `base/linkTypes/relatesTo` |

`secdeva/templates/threat` is deprecated; do not use it.

### Risk

```
create_card(template="secdeva/templates/productRisk2", parentKey="<risk register>")
edit_card_metadata(cardKey="<risk>", field="title", value="Unauthorised control of the turbine governor through the vendor 4G modem")
create_link(sourceKey="<affected element>", destinationKey="<risk>", linkType="ismsa/linkTypes/presentsRisk")
```

Set the fields with `edit_card_metadata`. Likelihood and impact take `veryLow`, `low`, `moderate`, `high` or `veryHigh`; the risk level is calculated from them.

- `ismsa/fieldTypes/riskInitialLikelihood`, `ismsa/fieldTypes/riskInitialImpact`: before treatment.
- `ismsa/fieldTypes/riskMitigationStrategy`: `mitigate`, `transfer`, `avoid` or `accept`.
- `ismsa/fieldTypes/riskResidualLikelihood`, `ismsa/fieldTypes/riskResidualImpact`: after the planned treatment.

Fill in the sections of the risk's content with `edit_card_content`: related assets, threat, potential vulnerabilities, consequences, existing mitigations, justification of the levels, treatment plan and justification of the residual risk. Keep the macros of the template (the graph at the top and the report in the treatment plan).

### Security issue

```
create_card(template="secdeva/templates/securityIssue", parentKey="<security issue register>")
create_link(sourceKey="<affected element>", destinationKey="<issue>", linkType="ismsa/linkTypes/presentsRisk")
create_link(sourceKey="<issue>", destinationKey="<risk>", linkType="secdeva/linkTypes/increasesRisk")
```

| Field | Values |
|---|---|
| `secdeva/fieldTypes/securityIssueCategory` | `flaw` (a weakness, the default) or `threat` |
| `secdeva/fieldTypes/severity` | `critical`, `high`, `medium`, `low` or `none` |
| `secdeva/fieldTypes/severityJustification` | Why this severity |
| `secdeva/fieldTypes/strategy` | Concrete steps to fix it: technologies and configuration, not vague advice |
| `secdeva/fieldTypes/rootCauseCategory` | `trainingOrAwareness`, `thirdParty`, `documentation`, `requirements`, `bestPractice` or `notApplicable` |
| `secdeva/fieldTypes/rootCauseJustification` | Why this root cause |

Severity:

| Severity | Criteria |
|---|---|
| `critical` | Remote code execution, authentication bypass, full data breach, or control of a safety-critical function, exploitable without special access |
| `high` | Credential theft, privilege escalation, sensitive data exposure, or control of a process, under some conditions |
| `medium` | Limited data exposure, denial of service of a non-critical service, or exploitation that requires authenticated access |
| `low` | Minor information leakage, or unlikely conditions |
| `none` | Fully mitigated by existing controls, documented for completeness |

Describe the issue in the content: what it is, how it could be exploited, which dataflows and components it affects, and which mitigations exist.

### Security requirement

```
create_card(template="secdeva/templates/securityRequirement", parentKey="<security requirement register>")
create_link(sourceKey="<requirement>", destinationKey="<element>", linkType="secdeva/linkTypes/appliesTo")
create_link(sourceKey="<requirement>", destinationKey="<risk or issue>", linkType="ismsa/linkTypes/mitigates")
```

Write the requirement in the content in EARS form, such as "The plant shall allow remote access of vendors to the control zones only through the remote access VPN gateway and the OT DMZ jump host." Add references (such as IEC 62443-3-3 SR 1.13) and the justification. Set `secdeva/fieldTypes/testingToBypassMitigation` to `required` when testing should try to bypass the requirement.

### Products in the solution structure

Record which products implement the elements: your own products, third-party products and services. **Link an existing product** if it is already in the solution structure; create one only if it is not there yet.

```
create_card(template="secdeva/templates/thirdPartyProduct", parentKey="<third-party products>")
create_link(sourceKey="<element>", destinationKey="<product>", linkType="secdeva/linkTypes/implementedBy")
```

Set `secdeva/fieldTypes/productVendor`, `secdeva/fieldTypes/deliveryModel` (such as `weConsumeAsService` or `customerProvides`) and `secdeva/fieldTypes/sbomComponentType` (such as `application`, `operating-system` or `device`). Significant third-party technologies also get a technology assessment in the Technology assessments register.

## Workflow states

Move the cards forward with `transition_card(cardKey, transition)`, using the transition's name. Leave the decisions to the people responsible, such as accepting a risk; propose them instead.

- **Risk:** Open → `Complete analysis` → Analysed → `Complete treatment planning` → Treatment planned → `Approve treatment plan` → Treatment in progress → `Complete treatment` → Treatment complete. An analysed risk can also be closed (`Close as accepted`, `Close as avoided`, `Close as transferred`, `Close as not applicable`, `Close as duplicate`).
- **Security issue:** Open → `Analyse` → Analysed → `Fix required` → Fix required → `Start progress` → In progress → `Implementation complete` → To be verified → `Verification passed` → Closed as verified. Other ways out: `Defer fix`, `Accept risk`, `Not applicable`, `Duplicate`, `Transfer`.
- **Security requirement:** Draft → `Approve requirement` → Content ready → `Implementation done` → To be verified → `Verification passed` → Closed as verified, or `Reject requirement`.

A threat analysis usually leaves new risks and issues in the states Open or Analysed, and requirements in Draft.

## Example chain (OT)

A vendor's 4G modem in a turbine control cabinet bypasses the DMZ:

1. **Risk** "Unauthorised control of the turbine governor through the vendor 4G modem": likelihood `moderate`, impact `veryHigh`, strategy `mitigate`; linked from the modem.
2. **Security issue** "Vendor 4G modem bypasses the OT DMZ": `flaw`, severity `high`, root cause `thirdParty`; linked from the modem, and increases the risk.
3. **Security requirement** "Remote vendor access only through the OT DMZ jump host": applies to the modem, mitigates the risk and the issue.
4. **Product** "Governor vendor 4G service router" in the third-party products, implementing the modem.

## When the analysis is done

Summarise the findings for the user, starting with the highest severity. The threat model report lists the risks and security issues of the model; the threat model's review task records the review.
