import { ethers, Wallet } from "ethers";
import EthersAdapter from "@gnosis.pm/safe-ethers-lib";
import SafeServiceClient from "@gnosis.pm/safe-service-client";
import Safe from "@gnosis.pm/safe-core-sdk";
import { SafeTransactionDataPartial } from "@gnosis.pm/safe-core-sdk-types";
import BackedCommunityNFTABI from "../../contracts/out/BackedCommunityTokenV1.sol/BackedCommunityTokenV1.json";
import _ from "lodash";
import {
  CategoryOnChainChangeProposal,
  AccessoryOnChainChangeProposal,
} from "@prisma/client";
import { createAlchemyWeb3 } from "@alch/alchemy-web3";
import { getAlchemyProvider } from "./helpers";

const { utils } = ethers;

const GNOSIS_SENDER: string = process.env.GNOSIS_SAFE_OWNER_ADDRESS!;

async function initGnosisSdk(safeAddress: string) {
  const ethAdapter = new EthersAdapter({
    ethers,
    signer: new Wallet(process.env.GNOSIS_SAFE_OWNER_PK!, getAlchemyProvider()),
  });
  const txServiceUrl = process.env.GNOSIS_TX_SERVICE_URL!;
  const safeService = new SafeServiceClient({
    txServiceUrl,
    ethAdapter,
  });

  const safeSdk = await Safe.create({ ethAdapter, safeAddress });

  return {
    safeService,
    safeSdk,
  };
}

export async function proposeCategoryTx(
  proposals: CategoryOnChainChangeProposal[],
  ipfsLink: string
): Promise<number> {
  if (proposals.length === 0) return 0;

  const safeAddress = process.env.GNOSIS_SAFE_ADDRESS!;
  // TODO(adamgobes): ideally we don't have to spin up a new instance of the SDK on every call
  const { safeSdk, safeService } = await initGnosisSdk(safeAddress);
  const to = utils.getAddress(process.env.BACKED_COMMUNITY_NFT_ADDRESS!);

  const iface = new ethers.utils.Interface(BackedCommunityNFTABI.abi);

  const changesParams = proposals.map((proposal) => [
    proposal.communityMemberEthAddress,
    proposal.category,
    proposal.value,
    ipfsLink,
  ]);

  const transaction: SafeTransactionDataPartial = {
    to,
    data: iface.encodeFunctionData(
      "changeCategoryScores(tuple(address addr, string categoryId, int256 value, string ipfsLink)[])",
      [changesParams]
    ),
    value: "0",
  };

  let safeTransaction = await safeSdk.createTransaction(transaction);
  const nextNonce = await safeService.getNextNonce(safeAddress);

  safeTransaction = {
    ...safeTransaction,
    data: {
      ...safeTransaction.data,
      nonce: nextNonce,
    },
    addSignature: safeTransaction.addSignature,
  };

  await safeSdk.signTransaction(safeTransaction);
  const safeTxHash = await safeSdk.getTransactionHash(safeTransaction);
  await safeService.proposeTransaction({
    safeAddress,
    safeTransaction,
    safeTxHash,
    senderAddress: GNOSIS_SENDER,
    origin: GNOSIS_SENDER,
  });

  return nextNonce;
}

export async function proposeAccessoryTx(
  proposals: AccessoryOnChainChangeProposal[],
  ipfsLink: string
): Promise<number> {
  if (proposals.length === 0) return 0;

  const safeAddress = process.env.GNOSIS_SAFE_ADDRESS!;
  // TODO(adamgobes): ideally we don't have to spin up a new instance of the SDK on every call
  const { safeSdk, safeService } = await initGnosisSdk(safeAddress);
  const to = utils.getAddress(process.env.BACKED_COMMUNITY_NFT_ADDRESS!);

  const iface = new ethers.utils.Interface(BackedCommunityNFTABI.abi);

  const changesParams = proposals.map((proposal) => [
    proposal.communityMemberEthAddress,
    proposal.unlock,
    proposal.accessoryId,
    ipfsLink,
  ]);

  const transaction: SafeTransactionDataPartial = {
    to,
    data: iface.encodeFunctionData(
      "changeAccessoryLocks(tuple(address addr, bool unlock, uint256 accessoryId, string ipfsLink)[])",
      [changesParams]
    ),
    value: "0",
  };

  let safeTransaction = await safeSdk.createTransaction(transaction);
  const nextNonce = await safeService.getNextNonce(safeAddress);

  safeTransaction = {
    ...safeTransaction,
    data: {
      ...safeTransaction.data,
      nonce: nextNonce,
    },
    addSignature: safeTransaction.addSignature,
  };

  await safeSdk.signTransaction(safeTransaction);
  const safeTxHash = await safeSdk.getTransactionHash(safeTransaction);
  await safeService.proposeTransaction({
    safeAddress,
    safeTransaction,
    safeTxHash,
    senderAddress: GNOSIS_SENDER,
    origin: GNOSIS_SENDER,
  });

  return nextNonce;
}

export async function getTransactionStatusFromGnosisNonce(
  nonce: number
): Promise<[string, boolean]> {
  try {
    const safeAddress = process.env.GNOSIS_SAFE_ADDRESS!;
    const { safeService } = await initGnosisSdk(safeAddress);

    const allTransactions = (await safeService.getMultisigTransactions(
      safeAddress
    )) as any;

    const txHash = allTransactions.results.find(
      (t: any) => t?.nonce === nonce
    ).transactionHash;

    const web3 = createAlchemyWeb3(process.env.ALCHEMY_URL!);

    return [txHash, (await web3.eth.getTransactionReceipt(txHash)).status];
  } catch (e) {
    console.log(`Unable to get tx hash for nonce ${nonce}`);
    return ["", false];
  }
}

getTransactionStatusFromGnosisNonce(7).then((res) => console.log({ res }));
