import { ethers } from "ethers";
import BackedCommunityNFTABI from "../../contracts/out/BackedCommunityTokenV1.sol/BackedCommunityTokenV1.json";

export async function getCurrentCategoryScoreForUser(
  category: string,
  address: string
) {
  const backedCommunityTokenContract = new ethers.Contract(
    process.env.BACKED_COMMUNITY_NFT_ADDRESS!,
    BackedCommunityNFTABI.abi,
    getAlchemyProvider()
  );

  const currentScore: ethers.BigNumber =
    await backedCommunityTokenContract.addressToCategoryScore(
      address,
      category
    );

  return currentScore;
}

export function getAlchemyProvider() {
  return new ethers.providers.AlchemyProvider(
    parseInt(process.env.CHAIN_ID!),
    process.env.ALCHEMY_URL!.substring(
      process.env.ALCHEMY_URL!.lastIndexOf("/") + 1
    )
  );
}
