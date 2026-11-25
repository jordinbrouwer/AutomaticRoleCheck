#!/usr/bin/env python3
"""Every /arc command, the minimap usage and the click hints are in README.md."""
import re
from pathlib import Path

from lib import log, toc

COMMAND_FILE = toc.SRC / "Core" / "Command.lua"
README = Path("README.md")

for path in (README, COMMAND_FILE):
    if not path.is_file():
        log.fail(f"{path} not found.")
readme = README.read_text(encoding="utf-8")
text = COMMAND_FILE.read_text(encoding="utf-8")

block = re.search(r"^local commandDefinitions = \{\n(.*?)^\}", text, re.M | re.S)
keys = sorted(set(re.findall(r"^  ([a-z0-9_]+)\s*= \{", block.group(1), re.M))) if block else []
if not keys:
    log.fail(f"Could not parse command definitions from {COMMAND_FILE}.")

minimap = re.search(r'key = "/arc minimap", extras = \{([^}]*)\}', text)
args = re.findall(r'"([a-z]+)"', minimap.group(1)) if minimap else []
if not args:
    log.fail("Could not parse minimap command args.")

wanted = ["/arc", *(f"/arc {key}" for key in keys), f"/arc minimap [{'|'.join(args)}]", "Left-click", "Right-click"]
missing = [f"Missing expected README token: {token}" for token in wanted if token not in readme]
if missing:
    log.fail("\n".join(missing))

section = re.search(r"^### Commands\n(.*?)(?=^### |\Z)", readme, re.M | re.S)
if not section or not section.group(1).strip():
    log.fail("Could not read the 'Commands' section.")
outside = [f"Missing '/arc {key}' in the 'Commands' section." for key in keys if f"/arc {key}" not in section.group(1)]
if outside:
    log.fail("\n".join(outside))
log.passed("README command and minimap usage coverage looks good.")
