import Discord from "discord.js";
import app from "./app";

const port = process.env.PORT || 3001;

const client = new Discord.Client();
client.login(process.env.DISCORD_BOT_TOKEN!);
client.on("voiceStateUpdate", (oldState, newState) => {
  console.log({ oldState, newState });
});

app.listen(port, () => {
  console.log("server running...");
});
