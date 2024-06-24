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

type
  CommandInfo = object
    name: string
    description: string

var commands: seq[CommandInfo] = @[]

commands.add(CommandInfo(name: "/say", description: "Says the same thing back to you"))
commands.add(CommandInfo(name: "/embed", description: "Embeds stuff for you"))
commands.add(CommandInfo(name: "/help", description: "Shows the help message"))
commands.add(CommandInfo(name: "/ping", description: "Shows the bots ping"))
commands.add(CommandInfo(name: "/add", description: "Adds two numbers"))
commands.add(CommandInfo(name: "/subtract", description: "Subtracts two numbers"))
commands.add(CommandInfo(name: "/multiply", description: "Multiplies two numbers"))
commands.add(CommandInfo(name: "/divide", description: "Divides two numbers"))
commands.add(CommandInfo(name: "/diverge", description: "Diverges two numbers"))
commands.add(CommandInfo(name: "/modulo", description: "Modulos two numbers"))

cmd.addSlash("help", guildID = dimscordDefaultGuildID) do ():
    ## Shows the help message
    var helpDescription = newSeq[string]()
    for cmd in commands:
        # Append each command as a new element in the sequence
        helpDescription.add(fmt"`{cmd.name}` - {cmd.description}")

    # Join the sequence elements with "\n" explicitly for the final string
    let finalDescription = helpDescription.join("\n")

    await discord.api.interactionResponseMessage(i.id, i.token,
        kind = irtChannelMessageWithSource,
        response = InteractionCallbackDataMessage(
            embeds: @[Embed(
                title: some "Help",
                description: some finalDescription,
                color: some 0xFEEA40
            )]
        )
    )

waitFor discord.startSession()