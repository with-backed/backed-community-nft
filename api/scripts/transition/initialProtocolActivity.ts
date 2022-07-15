import axios from "axios";

const network = "polygon";

async function run() {
  const { data }: any = await axios.get(
    `https://withbacked.xyz/api/network/${network}/events/LendEvent/all`
  );

  console.log(data.length);

  for (let i = 0; i < data.length; i++) {
    const lendEvent = data[i];
    const lender = lendEvent.lender;

    await axios.post(
      "https://backed-community-nft.onrender.com/achievements/create/activity/lend_event",
      {
        ethAddress: lender,
      },
      {
        headers: {
          Authorization: `${process.env.BASIC_AUTH_USER}:${process.env.BASIC_AUTH_PASS}`,
        },
      }
    );

    console.log(`awarded activity XP for ${lender}`);
  }
}

run();
