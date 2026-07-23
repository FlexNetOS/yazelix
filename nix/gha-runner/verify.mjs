// Offline gate for the FlexNetOS composed Nix runner. Every gate is an exit code.
// Enforces the hard constraints: ZERO OS system deps, path law, bun-not-node runtime,
// Nushell scripts, the github-runner SUBSTRATE (executes all workflows), and the
// rUv-native metaharness agent layer. Run with: bun run verify.mjs
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
// (`--startuptype service` is a Runner.Listener CLI flag, not an OS service — excluded by the regex shape.)
const OS_DEP = /\b(systemctl|systemd|System\/Library|apt-get|apt install|yum |dnf |\/etc\/systemd|service\s+\w+\s+start|launchctl)\b/;
check('flake has NO OS system deps', flakeCode && !OS_DEP.test(flakeCode), 'systemd/service/apt/etc');
check('runner has NO OS system deps', runnerCode && !OS_DEP.test(runnerCode));

// Path law: profile-runtime, never ~/.local
check('runner uses profile-runtime', runner && runner.includes('profile-runtime'));
check('no ~/.local path', [flake, runner].every((s) => s && !/\.local\//.test(s)));

// SUBSTRATE: the real actions/runner from nixpkgs, wired into the launcher.
check('flake ships github-runner substrate', flakeCode && /pkgs\.github-runner/.test(flakeCode));
check('flake injects GHA_SUBSTRATE env', flakeCode && /GHA_SUBSTRATE=\$\{pkgs\.github-runner\}/.test(flakeCode));
check('runner registers to FlexNetOS org', runnerCode && runnerCode.includes('https://github.com/FlexNetOS'));
check('runner labels flexnetos,nix', runnerCode && /flexnetos,nix/.test(runnerCode));
check('runner has register command', runnerCode && /config\.sh/.test(runnerCode) && /--unattended/.test(runnerCode));
check('runner has run command (Runner.Listener)', runnerCode && /Runner\.Listener/.test(runnerCode));
check('runner state under RUNNER_ROOT', runnerCode && /RUNNER_ROOT/.test(runnerCode));

// Runtime law: bun for the agent layer (GHA_BUN from the closure), never bare node/npx
check('runner agent layer uses bun (not bare node/npx)',
  runnerCode && /GHA_BUN/.test(runnerCode) && /run \$cli/.test(runnerCode)
    && !/\bnpx\b/.test(runnerCode) && !/\^node\b/.test(runnerCode));
check('flake runtime uses bun/bunx', flakeCode && /\b(bunx|bun run)\b/.test(flakeCode) && !/\bnpx\b/.test(flakeCode));

// Nushell (not bash) for scripts
check('runner is Nushell', runner && runner.startsWith('#!/usr/bin/env nu'));

// Secret law: token from env, never hardcoded
check('token read from env, not hardcoded', runner && runner.includes('GHA_RUNNER_TOKEN')
  && !/ghp_|github_pat_/.test(runner));

// rUv-native harness deps (grounded: ADR-033, host-github-actions v0.1.2)
const deps = pkg ? (JSON.parse(pkg).dependencies || {}) : {};
check('deps @metaharness/kernel', '@metaharness/kernel' in deps);
check('deps @metaharness/host-github-actions', '@metaharness/host-github-actions' in deps);
check('deps agentic-flow', 'agentic-flow' in deps);

// Hermetic flake: pins nixpkgs by exact rev (yazelix lock rev), exposes runner app
check('flake pins nixpkgs input', flake && /nixpkgs\.url\s*=\s*"github:NixOS\/nixpkgs/.test(flake));
// Reproducibility: an explicit 40-hex rev, not a bare branch (which drifts build-to-build).
// The specific value is chosen for a cache.nixos.org hit — verify currency, not a literal.
check('flake pins nixpkgs to an explicit rev (reproducible)',
  flake && /nixpkgs\.url\s*=\s*"github:NixOS\/nixpkgs\/[0-9a-f]{40}"/.test(flake));
check('flake exposes runner app', flake && /runner\s*=\s*{/.test(flake));

let failed = 0;
for (const r of results) {
  console.log(`${r.ok ? 'PASS' : 'FAIL'}  ${r.name}${r.detail ? '  (' + r.detail + ')' : ''}`);
  if (!r.ok) failed++;
}
console.log(`\n${results.length - failed}/${results.length} gates passed`);
process.exit(failed ? 1 : 0);
