import dimscord, asyncdispatch, dimscmd
import os, dotenv
import strutils
import strformat
import options

load()

let discord = newDiscordClient(getEnv("TOKEN"))

var cmd = discord.newHandler()

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

cmd.addSlash("ping") do ():
    ## Shows the bots ping
    await i.reply("Pong!")

cmd.addSlash("add") do (a: int, b: int):
    ## Adds two numbers
    await i.reply(fmt"{a} + {b} = {a + b}")

cmd.addSlash("subtract") do (a: int, b: int):
    ## Subtracts two numbers
    await i.reply(fmt"{a} - {b} = {a - b}")

cmd.addSlash("multiply") do (a: int, b: int):
    ## Multplies two numbers
    await i.reply(fmt"{a} * {b} = {a * b}")

cmd.addSlash("divide") do (a: int, b: int):
    ## Divides two numbers
    await i.reply(fmt"{a} / {b} = {a / b}")

cmd.addSlash("diverge") do (a: int, b: int):
    ## Diverges two numbers
    await i.reply(fmt"{a} div {b} = {a div b}")

cmd.addSlash("modulo") do (a: int, b: int):
    ## Multplies two numbers
    await i.reply(fmt"{a} mod {b} = {a mod b}")

waitFor discord.startSession()
