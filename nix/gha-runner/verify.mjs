// Offline gate for the FlexNetOS rUv-native Nix runner. Every gate is an exit code.
// Enforces the hard constraints: ZERO OS system deps, path law, bun-not-node runtime,
// Nushell scripts, and rUv-native harness dependencies. Run with: bun run verify.mjs
import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const HERE = dirname(fileURLToPath(import.meta.url));
const read = (p) => (existsSync(p) ? readFileSync(p, 'utf8') : null);

const flake = read(join(HERE, 'flake.nix'));
const runner = read(join(HERE, 'scripts', 'runner.nu'));
const pkg = read(join(HERE, 'harness', 'package.json'));

// Strip comments so gates test actual CODE, not prose that names the forbidden thing.
const stripComments = (s) =>
  s == null ? null
    : s.replace(/\/\*[\s\S]*?\*\//g, '')      // /* ... */ (nix)
       .split('\n').map((l) => l.replace(/(^|\s)(#|\/\/).*$/, '$1')).join('\n');
const flakeCode = stripComments(flake);
const runnerCode = stripComments(runner);

const results = [];
const check = (name, cond, detail = '') => results.push({ name, ok: !!cond, detail });

// Files present
check('flake.nix present', flake !== null);
check('runner.nu present', runner !== null);
check('harness/package.json present', pkg !== null);

// HARD: zero OS system dependencies — no systemd/service/host-package escape hatches.
const OS_DEP = /\b(systemctl|systemd|System\/Library|apt-get|apt install|yum |dnf |\/etc\/systemd|service\s+\w+\s+start|launchctl)\b/;
check('flake has NO OS system deps', flakeCode && !OS_DEP.test(flakeCode), 'systemd/service/apt/etc');
check('runner has NO OS system deps', runnerCode && !OS_DEP.test(runnerCode));

// Path law: profile-runtime, never ~/.local
check('runner uses profile-runtime', runner && runner.includes('profile-runtime'));
check('no ~/.local path', [flake, runner].every((s) => s && !/\.local\//.test(s)));

// Runtime law: bun, never bare node/npx at runtime
check('runner uses bun (not bare node/npx)',
  runnerCode && /\bbun run\b/.test(runnerCode) && !/\bnpx\b/.test(runnerCode) && !/\^node\b/.test(runnerCode));
check('flake runtime uses bun/bunx', flakeCode && /\b(bunx|bun run)\b/.test(flakeCode) && !/\bnpx\b/.test(flakeCode));

// Nushell (not bash) for scripts
check('runner is Nushell', runner && runner.startsWith('#!/usr/bin/env nu'));

// Secret law: token from env, never hardcoded
check('token read from env, not hardcoded', runner && runner.includes('GHA_RUNNER_TOKEN')
  && !/ghp_|github_pat_/.test(runner));

// rUv-native harness deps (grounded)
const deps = pkg ? (JSON.parse(pkg).dependencies || {}) : {};
check('deps @metaharness/kernel', '@metaharness/kernel' in deps);
check('deps @metaharness/host-github-actions', '@metaharness/host-github-actions' in deps);
check('deps agentic-flow', 'agentic-flow' in deps);

// Hermetic flake: pins nixpkgs, exposes runner app + hermetic devShell
check('flake pins nixpkgs input', flake && /nixpkgs\.url\s*=\s*"github:NixOS\/nixpkgs/.test(flake));
check('flake exposes runner app', flake && /runner\s*=\s*{/.test(flake));

let failed = 0;
for (const r of results) {
  console.log(`${r.ok ? 'PASS' : 'FAIL'}  ${r.name}${r.detail ? '  (' + r.detail + ')' : ''}`);
  if (!r.ok) failed++;
}
console.log(`\n${results.length - failed}/${results.length} gates passed`);
process.exit(failed ? 1 : 0);
