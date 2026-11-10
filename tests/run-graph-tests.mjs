#!/usr/bin/env node
// SPDX-FileCopyrightText: Cyberismo Ltd and contributors
// SPDX-License-Identifier: AGPL-3.0-only

// Runs the assertion tests of the graph models against the test content.
//
// The graph models are not part of the project's calculations, so assertion
// reports cannot test them. Instead, each test case in tests/graphModels is a
// logic program that is run together with a graph model and a rendered graph
// view, in the same way as the graph macro runs them.
//
// A test case starts with header comments:
//
//   % model: secdeva/graphModels/dataflow
//   % view: secdeva/graphViews/allEntities
//   % params: {"cardKey": "@Threat model - Layered test project", "mergeDataflows": true}
//
// A parameter value "@<title>" is replaced with the key of the card that has
// that title. The case declares testCase("name") facts and the testPass("name")
// rules that make them pass. The helper k(Title, Key) finds a card of the test
// model by its title.
//
// usage: node tests/run-graph-tests.mjs [case ...]
// Requires the cyberismo CLI. Exits with 1 if a test fails.

import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname, basename } from 'node:path';
import { fileURLToPath } from 'node:url';

const moduleRoot = join(dirname(fileURLToPath(import.meta.url)), '..');
const resources = join(moduleRoot, '.cards', 'local');
const casesFolder = join(moduleRoot, 'tests', 'graphModels');

// card titles to keys, from the test content
function cardTitles() {
  const titles = new Map();
  const walk = (folder) => {
    for (const entry of readdirSync(folder, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      const path = join(folder, entry.name);
      try {
        const card = JSON.parse(readFileSync(join(path, 'index.json'), 'utf8'));
        if (!titles.has(card.title)) titles.set(card.title, entry.name);
      } catch {
        // not a card folder
      }
      walk(path);
    }
  };
  walk(join(moduleRoot, 'cardRoot'));
  return titles;
}

// renders the subset of Handlebars that the graph views use
function render(template, params) {
  let out = template.replace(
    /\{\{#each (?:this\.)?(\w+)\}\}([\s\S]*?)\{\{\/each\}\}/g,
    (_, name, body) =>
      (params[name] ?? []).map((item) => body.replaceAll('{{this}}', item)).join(''),
  );
  for (let i = 0; i < 5; i++) {
    out = out.replace(
      /\{\{#if (\w+)\}\}((?:(?!\{\{#if)[\s\S])*?)(?:\{\{else\}\}((?:(?!\{\{#if)[\s\S])*?))?\{\{\/if\}\}/g,
      (_, name, then, otherwise = '') => (params[name] ? then : otherwise),
    );
  }
  return out.replace(/\{\{(\w+)\}\}/g, (_, name) => String(params[name] ?? ''));
}

function header(source, name) {
  const match = source.match(new RegExp(`^% ${name}: (.*)$`, 'm'));
  if (!match) throw new Error(`missing "% ${name}:" header`);
  return match[1].trim();
}

const harness = `
selectAll.
k(Title, Key) :- testModel(Model), field(Key, "title", Title), ancestor(Key, Model).
k(Title, Model) :- testModel(Model), field(Model, "title", Title).
result(Name) :- testCase(Name).
field(Name, "verdict", "PASS") :- testCase(Name), testPass(Name).
field(Name, "verdict", "FAIL") :- testCase(Name), not testPass(Name).
`;

const titles = cardTitles();
const requested = process.argv.slice(2);
const cases = readdirSync(casesFolder)
  .filter((file) => file.endsWith('.lp'))
  .filter((file) => requested.length === 0 || requested.includes(basename(file, '.lp')));

const work = mkdtempSync(join(tmpdir(), 'secdeva-graph-tests-'));
let failed = 0;
let passed = 0;

for (const file of cases) {
  const source = readFileSync(join(casesFolder, file), 'utf8');
  const params = JSON.parse(header(source, 'params'));
  for (const [name, value] of Object.entries(params)) {
    if (typeof value === 'string' && value.startsWith('@')) {
      const key = titles.get(value.slice(1));
      if (!key) throw new Error(`${file}: no card titled "${value.slice(1)}"`);
      params[name] = key;
    }
  }
  const model = readFileSync(join(resources, 'graphModels', header(source, 'model').split('/').pop(), 'model.lp'), 'utf8');
  const view = render(
    readFileSync(join(resources, 'graphViews', header(source, 'view').split('/').pop(), 'view.lp.hbs'), 'utf8'),
    params,
  );
  const testModel = params.cardKey ?? params.root;
  if (!testModel) throw new Error(`${file}: the params need a cardKey or a root, so that k() can find the cards`);
  const program = `${model}\n${view}\ntestModel(${testModel}).\n${harness}\n${source}`;
  const programFile = join(work, file);
  writeFileSync(programFile, program);
  console.log(`\n${basename(file, '.lp')}`);
  let output;
  try {
    output = JSON.parse(
      execFileSync('cyberismo', ['calc', 'run', programFile, '-p', moduleRoot], {
        maxBuffer: 1 << 28,
        stdio: ['ignore', 'pipe', 'pipe'],
      }).toString(),
    );
  } catch (error) {
    output = { error: (error.stderr?.toString() || error.message).trim() };
  }
  if (output.error || output.results.length === 0) {
    console.log(`  FAIL  the case did not run: ${output.error ?? 'no test cases'}`);
    failed++;
    continue;
  }
  for (const result of output.results) {
    console.log(`  ${result.verdict}  ${result.key}`);
    if (result.verdict === 'PASS') passed++;
    else failed++;
  }
}

console.log(`\n${passed} passed, ${failed} failed`);
process.exit(failed === 0 ? 0 : 1);
