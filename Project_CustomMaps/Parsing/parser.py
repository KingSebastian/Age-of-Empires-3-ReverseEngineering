import csv
import re
from pathlib import Path
from typing import List, Dict, Optional


# -------------------------
# Models
# -------------------------

class Argument:
    def __init__(self, _type: str, name: str):
        self._type = _type
        self.name = name

    def __str__(self):
        return f"{self._type} {self.name}"


class Command:
    def __init__(
        self,
        name: str,
        _type: Optional[str] = None,
        arg_lst: Optional[List[Argument]] = None,
        desc: str = ""
    ):
        self.name = name
        self._type = _type
        self.arg_lst = arg_lst or []
        self.desc = desc

    def __str__(self):
        args = ", ".join(str(arg) for arg in self.arg_lst)
        type_part = self._type + " " if self._type else ""
        desc_part = f" : {self.desc}" if self.desc else ""
        return f"{type_part}{self.name}({args}){desc_part}"


# -------------------------
# Core storage
# -------------------------

commands: Dict[str, Command] = {}


# -------------------------
# Parsing
# -------------------------

def parse_command(text: str) -> Optional[Command]:
    text = text.strip()

    if not text:
        return None

    # Skip debugger / junk
    if "xsDebugger" in text or "-" in text:
        return None

    # Split description (ONLY first colon)
    parts = text.split(":", 1)
    signature = parts[0].strip()
    desc = parts[1].strip() if len(parts) > 1 else ""

    # Match full function signature
    match = re.match(r"(?:(\w+)\s+)?(\w+)\((.*?)\)", signature)

    if match:
        _type, name, args_str = match.groups()

        args = []
        if args_str and args_str != "void":
            for arg in args_str.split(","):
                arg = arg.strip()
                if not arg:
                    continue

                parts = arg.split()
                if len(parts) == 2:
                    args.append(Argument(parts[0], parts[1]))
                else:
                    # fallback (unknown format)
                    args.append(Argument("", arg))

        return Command(name=name, _type=_type, arg_lst=args, desc=desc)

    else:
        # fallback: only name
        name = signature.strip()
        return Command(name=name, _type=None, arg_lst=[], desc=desc)


# -------------------------
# Merging logic
# -------------------------

def merge_command(cmd: Command):
    if cmd is None:
        return

    key = cmd.name

    if key not in commands:
        commands[key] = cmd
        return

    existing = commands[key]

    # ---- TYPE ----
    if not existing._type and cmd._type:
        existing._type = cmd._type

    elif existing._type and cmd._type and existing._type != cmd._type:
        print(f"[TYPE CONFLICT] {cmd.name}: {existing._type} vs {cmd._type}")

    # ---- ARGUMENTS ----
    if not existing.arg_lst and cmd.arg_lst:
        existing.arg_lst = cmd.arg_lst

    elif existing.arg_lst and cmd.arg_lst:
        if len(cmd.arg_lst) > len(existing.arg_lst):
            existing.arg_lst = cmd.arg_lst

    # ---- DESCRIPTION ----
    if len(cmd.desc) > len(existing.desc):
        existing.desc = cmd.desc


# -------------------------
# File processing
# -------------------------

def parse_file(file: Path):
    print(f"Processing: {file}")

    with open(file, "r", encoding="utf-8", errors="ignore") as tsv:
        reader = csv.reader(tsv, delimiter="\t")

        for row in reader:
            if len(row) < 2:
                continue

            text = row[1]
            cmd = parse_command(text)
            if cmd:
                merge_command(cmd)


# -------------------------
# Main
# -------------------------

def main():
    base_path = Path.cwd()
    files = list(base_path.parent.joinpath("RE_Dumps").rglob("*.tsv"))

    for file in files:
        parse_file(file)

    print("\n--- All COMMANDS ---\n")
    with open(base_path.joinpath("temp_all_commands.txt"), "w+") as output:
        for cmd in sorted(commands.values(), key=lambda c: c.name):
            print(cmd, file=output)


if __name__ == "__main__":
    main()