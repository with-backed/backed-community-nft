const fs = require('fs');
const os = require('os');
const path = require('path');
const boot = require('./boot');
const call = require('./call');
const compile = require('./compile');
const deploy = require('./deploy');
const { DOMParser } = require('xmldom');

const SOURCE = path.join(__dirname, '..', 'contracts', 'src', 'BackedCommunityTokenDescriptorV1.sol');
const DESTINATION = path.join(os.tmpdir(), 'hot-chain-svg-');

async function main() {
  const { vm, pk } = await boot();
  const { abi, bytecode } = compile(SOURCE);
  const address = await deploy(vm, pk, bytecode);

  const tempFolder = fs.mkdtempSync(DESTINATION);
  console.log('Saving to', tempFolder);

  for (let i = 1; i < 256; i++) {
    const fileName = path.join(tempFolder, i + '.svg');
    console.log('Rendering', fileName);
    const svg = await call(vm, address, abi, 'tokenURI', [0x6b2770a75a928989c1d7356366d4665a6487e1b4, [0], 0x6b2770a75a928989c1d7356366d4665a6487e1b4]);
    fs.writeFileSync(fileName, svg);

    // Throws on invalid XML
    new DOMParser().parseFromString(svg);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
