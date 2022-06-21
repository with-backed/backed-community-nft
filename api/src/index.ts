import app from "./app";
import { setupDiscordVoiceChannelListener } from "./webhooks/discord";

const port = process.env.PORT || 3001;

setupDiscordVoiceChannelListener();

app.listen(port, () => {
  console.log("server running...");
});
