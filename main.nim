import dimscord, asyncdispatch, dimscmd
import os, dotenv
import strutils
import strformat
import options

load()

let discord = newDiscordClient(getEnv("TOKEN"))

var cmd = discord.newHandler()

const dimscordDefaultGuildID = "1247673555462787143"

proc reply(i: Interaction, msg: string) {.async.} =
    let response = InteractionResponse(
        kind: irtChannelMessageWithSource,
        data: some InteractionApplicationCommandCallbackData(
            content: msg
        )
    )
    await discord.api.createInteractionResponse(i.id, i.token, response)

proc onReady(s: Shard, r: Ready) {.event(discord).} =
    await cmd.registerCommands()
    echo "Ready as " & $r.user

    await s.updateStatus(activities = @[ActivityStatus(name: "with nim")], status = "idle")

proc interactionCreate (s: Shard, i: Interaction) {.event(discord).} =
    discard await cmd.handleInteraction(s, i)

cmd.addSlash("ping", guildID = dimscordDefaultGuildID) do ():
    ## Shows the bots ping
    await i.reply("Pong!")

cmd.addSlash("add", guildID = dimscordDefaultGuildID) do (a: int, b: int):
    ## Adds two numbers
    await i.reply(fmt"{a} + {b} = {a + b}")

cmd.addSlash("subtract", guildID = dimscordDefaultGuildID) do (a: int, b: int):
    ## Subtracts two numbers
    await i.reply(fmt"{a} - {b} = {a - b}")

cmd.addSlash("multiply", guildID = dimscordDefaultGuildID) do (a: int, b: int):
    ## Multplies two numbers
    await i.reply(fmt"{a} * {b} = {a * b}")

cmd.addSlash("divide", guildID = dimscordDefaultGuildID) do (a: int, b: int):
    ## Divides two numbers
    await i.reply(fmt"{a} / {b} = {a / b}")

cmd.addSlash("diverge", guildID = dimscordDefaultGuildID) do (a: int, b: int):
    ## Diverges two numbers
    await i.reply(fmt"{a} div {b} = {a div b}")

cmd.addSlash("modulo", guildID = dimscordDefaultGuildID) do (a: int, b: int):
    ## Multplies two numbers
    await i.reply(fmt"{a} mod {b} = {a mod b}")

cmd.addSlash("say", guildID = dimscordDefaultGuildID) do (message: string):
    ## Says the same thing back to you
    await i.reply(message)

cmd.addSlash("embed", guildID = dimscordDefaultGuildID) do (title: string, description: string):
    ## Embeds stuff for you
    await discord.api.interactionResponseMessage(i.id, i.token,
        kind = irtChannelMessageWithSource,
        response = InteractionCallbackDataMessage(
            embeds: @[Embed(
                title: some fmt"{title}",
                description: some fmt"{description}",
                color: some 0xFEEA40
            )]
        )
    )

cmd.addSlash("help", guildID = dimscordDefaultGuildID) do ():
    ## Shows help command
    await discord.api.interactionResponseMessage(i.id, i.token,
        kind = irtChannelMessageWithSource,
        response = InteractionCallbackDataMessage(
            embeds: @[Embed(
                title: some "Help",
                description: some "`/ping` - Shows the bots ping\n`/add` - Adds two numbers\n`/subtract` - Subtracts two numbers\n`/multiply` - Multiplies two numbers\n`/divide` - Divides two numbers\n`/diverge` - Diverges two numbers\n`/modulo` - Modulos two numbers\n`/say` - Says the same thing back to you\n`/embed` - Embeds stuff for you\n`/help` - Shows this message",
                color: some 0xFEEA40
            )]
        )
    )

waitFor discord.startSession()