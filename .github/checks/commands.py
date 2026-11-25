#!/usr/bin/env python3
"""The slash command is registered and /arc help lists every command in commandDefinitions."""
import re

from lib import log, toc

COMMAND_FILE = toc.SRC / "Core" / "Command.lua"
REQUIRED = [
    ('SLASH_AUTOMATICROLECHECK1 = "/arc"', "Missing required token 'SLASH_AUTOMATICROLECHECK1 = \"/arc\"'."),
    ("SlashCmdList.AUTOMATICROLECHECK = function", "Missing required token 'SlashCmdList.AUTOMATICROLECHECK = function'."),
    ("local function HandleHelp()", "Missing HandleHelp function."),
    ("for i, def in ipairs(HELP_CELLS) do", "HandleHelp should build the help from HELP_CELLS."),
]

if not COMMAND_FILE.is_file():
    log.fail(f"{COMMAND_FILE} not found.")
text = COMMAND_FILE.read_text(encoding="utf-8")
block = re.search(r"^local commandDefinitions = \{\n(.*?)^\}", text, re.M | re.S)
keys = re.findall(r"^  ([a-z0-9_]+)\s*= \{", block.group(1), re.M) if block else []
if not keys:
    log.fail("Could not parse commandDefinitions keys.")
problems = [message for token, message in REQUIRED if token not in text]
helped = set(re.findall(r'key = "/arc ([a-z0-9_]+)"', text))
problems += [f"'/arc {key}' is missing from HELP_CELLS." for key in keys if key != "help" and key not in helped]
if problems:
    log.fail("\n".join(problems))
log.passed("Command registration and help contract look valid.")
