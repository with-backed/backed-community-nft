import { ethers, Wallet } from "ethers";
import EthersAdapter from "@gnosis.pm/safe-ethers-lib";
import SafeServiceClient from "@gnosis.pm/safe-service-client";
import Safe from "@gnosis.pm/safe-core-sdk";
import { SafeTransactionDataPartial } from "@gnosis.pm/safe-core-sdk-types";
import { getNetwork } from "@ethersproject/networks";
import BackedCommunityNFTABI from "../../contracts/out/BackedCommunityTokenV1.sol/BackedCommunityTokenV1.json";
import _ from "lodash";
import { ChangeType, OnChainChangeProposal } from "@prisma/client";
import { createAlchemyWeb3 } from "@alch/alchemy-web3";

const { utils } = ethers;

const GNOSIS_SENDER: string = process.env.GNOSIS_SAFE_OWNER_ADDRESS!;

async function initGnosisSdk(safeAddress: string) {
  const ethAdapter = new EthersAdapter({
    ethers,
    signer: new Wallet(
      process.env.GNOSIS_SAFE_OWNER_PK!,
      new ethers.providers.AlchemyProvider(
        "rinkeby",
        process.env.ALCHEMY_URL!.substring(
          process.env.ALCHEMY_URL!.lastIndexOf("/") + 1
        )
      )
    ),
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

// TODO(adamgobes): update this method to match new contracts, can ignore in PR review for now
export async function proposeTx(
  changeProposals: OnChainChangeProposal[]
): Promise<number> {
  const safeAddress = process.env.GNOSIS_SAFE_ADDRESS!;
  // TODO(adamgobes): ideally we don't have to spin up a new instance of the SDK on every call
  const { safeSdk, safeService } = await initGnosisSdk(safeAddress);
  const to = utils.getAddress(process.env.BACKED_COMMUNITY_NFT_ADDRESS!);

  const iface = new ethers.utils.Interface(BackedCommunityNFTABI.abi);

  const changesParams = changeProposals.map((proposal) => [
    proposal.changeType === ChangeType.CATEGORY_SCORE ? true : false,
    proposal.communityMemberEthAddress,
    proposal.categoryOrAccessoryId,
    proposal.ipfsURL,
  ]);

  const transaction: SafeTransactionDataPartial = {
    to,
    data: iface.encodeFunctionData(
      "unlockAccessoryOrIncrementCategory(tuple(bool isCategoryChange, address addr, uint256 changeableId, string ipfsLink)[])",
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
  const safeAddress = process.env.GNOSIS_SAFE_ADDRESS!;
  const { safeService } = await initGnosisSdk(safeAddress);
  const allTransactions = (await safeService.getAllTransactions(safeAddress, {
    executed: true,
    queued: false,
  })) as any;

  const txHash = allTransactions.results.find(
    (t: any) => t?.nonce === nonce
  ).transactionHash;

  const web3 = createAlchemyWeb3(process.env.ALCHEMY_URL!);

  return [txHash, (await web3.eth.getTransactionReceipt(txHash)).status];
}
