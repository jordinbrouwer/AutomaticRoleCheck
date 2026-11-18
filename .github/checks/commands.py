#!/usr/bin/env python3
"""The slash command is registered and /arc help is built from commandDefinitions."""
import re

from lib import log, toc

COMMAND_FILE = toc.SRC / f"{toc.ADDON}_Command.lua"
REQUIRED = [
    ('SLASH_AUTOMATICROLECHECK1 = "/arc"', "Missing required token 'SLASH_AUTOMATICROLECHECK1 = \"/arc\"'."),
    ("SlashCmdList.AUTOMATICROLECHECK = function", "Missing required token 'SlashCmdList.AUTOMATICROLECHECK = function'."),
    ("local function HandleHelp()", "Missing HandleHelp function."),
    ("for _, key in ipairs(orderedKeys) do", "HandleHelp should iterate ordered command keys."),
    ("local definition = commandDefinitions[key]", "HandleHelp should derive text from commandDefinitions."),
]

if not COMMAND_FILE.is_file():
    log.fail(f"{COMMAND_FILE} not found.")
text = COMMAND_FILE.read_text(encoding="utf-8")
block = re.search(r"^commandDefinitions = \{\n(.*?)^\}", text, re.M | re.S)
if not block or not re.search(r"^  [a-z0-9_]+\s*= \{", block.group(1), re.M):
    log.fail("Could not parse commandDefinitions keys.")
problems = [message for token, message in REQUIRED if token not in text]
if problems:
    log.fail("\n".join(problems))
log.passed("Command registration and help contract look valid.")
