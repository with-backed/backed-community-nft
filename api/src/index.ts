import Discord from "discord.js";
import app from "./app";

const port = process.env.PORT || 3001;

const client = new Discord.Client();
client.login(process.env.DISCORD_BOT_TOKEN!);
client.on("voiceStateUpdate", (oldState, newState) => {
  // null oldState.channelID means user is joining
  if (oldState.channelID === null) {
    console.log({ member: newState.member, channelID: newState.channelID });
  }
});

app.listen(port, () => {
  console.log("server running...");
});
