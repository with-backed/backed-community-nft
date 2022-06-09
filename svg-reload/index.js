const fs = require('fs');
const path = require('path');
const serve = require('./serve');
const boot = require('./boot');
const call = require('./call');
const compile = require('./compile');
const deploy = require('./deploy');

const SOURCE = path.join(__dirname, '..', 'contracts', 'src', 'BackedCommunityTokenDescriptorV1.sol');
const TRAIT_SOURCE = path.join(__dirname, '..', 'contracts', 'src', 'traits', 'GoldKeyTrait.sol');

async function main() {
  const { vm, pk } = await boot();

  async function handler() {
    const { abi, bytecode } = compile(SOURCE);
    const { abi: traitAbi, bytecode: traitByteCode } = compile(TRAIT_SOURCE);

    const address = await deploy(vm, pk, bytecode);
    const traitAddress = await deploy(vm, pk, traitByteCode);
    
    const result = await call(vm, address, abi, 'tokenURI', ["0x6b2770a75a928989c1d7356366d4665a6487e1b4", [3, 8, 11, 3, 2, 1, 0], traitAddress.toString()]);
    return result;
  }

  const { notify } = await serve(handler);

  fs.watch(path.dirname(SOURCE), notify);
  console.log('Watching', path.dirname(SOURCE));
  console.log('Serving  http://localhost:9901/');
}

main();
