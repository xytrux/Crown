import dimscord, dimscmd, asyncdispatch, os, strutils, dotenv

load()

let discord = newDiscordClient(getEnv("TOKEN"))

var cmd = discord.newHandler()

proc onReady(s: Shard, r: Ready) {.event(discord).} =
    await cmd.registerCommands()
    echo "Ready as " & $r.user

proc interactionCreate (s: Shard, i: Interaction) {.event(discord).} =
    discard await cmd.handleInteraction(s, i)

cmd.addSlash("ping") do ():
    ## Shows the bots ping
    await discord.api.interactionResponseMessage(
        interaction_id = i.id,
        interaction_token = i.token,
        kind = irtChannelMessageWithSource,
        response = InteractionCallbackDataMessage(content: "Pong!")
    )

waitFor discord.startSession()
