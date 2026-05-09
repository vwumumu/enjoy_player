#!/usr/bin/env node
/**
 * Convert logo SVG to PNG for flutter_launcher_icons.
 * Run from repo root: npm install --prefix tool && node tool/svg_to_png.mjs
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

async function main() {
  const { Resvg } = await import('@resvg/resvg-js');

  const argv = process.argv.slice(2);
  const size = Number(argv.find((a) => a.startsWith('--size='))?.split('=')[1]) || 1024;
  const positional = argv.filter((a) => !a.startsWith('--'));
  const inputSvg =
    positional[0] ?? join(__dirname, '..', 'assets', 'logo-light.svg');
  const outputPng =
    positional[1] ?? join(__dirname, '..', 'assets', 'logo.png');

  const svg = readFileSync(inputSvg, 'utf8');
  const resvg = new Resvg(svg, {
    fitTo: { mode: 'width', value: size },
  });
  const pngData = resvg.render();
  const pngBuffer = pngData.asPng();
  writeFileSync(outputPng, pngBuffer);
  console.log(`Wrote ${outputPng} (${size}x${size})`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
