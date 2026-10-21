#!/usr/bin/env python3
"""catalog.json helper.

  python tools/catalog.py check     # CI: ids, slugs and recipe folders are consistent
  python tools/catalog.py readme    # rewrites the recipe list in README.md (between the markers)
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SITE = "https://cloudtales.gr/recipes"
BEGIN, END = "<!-- recipes:begin -->", "<!-- recipes:end -->"


def load() -> dict:
    return json.loads((ROOT / "catalog.json").read_text(encoding="utf-8"))


def check(cat: dict) -> int:
    errors = []
    codes = {c["code"] for c in cat["categories"]}
    ids, slugs = set(), set()
    for r in cat["recipes"]:
        if r["category"] not in codes:
            errors.append(f"{r['id']}: unknown category {r['category']}")
        if not re.fullmatch(rf"{r['category']}-\d{{2}}", r["id"]):
            errors.append(f"{r['id']}: id does not match its category")
        if not r["slug"].startswith(r["id"].lower() + "-"):
            errors.append(f"{r['id']}: slug must start with the lower-case id")
        if r["id"] in ids:
            errors.append(f"{r['id']}: duplicate id")
        if r["slug"] in slugs:
            errors.append(f"{r['slug']}: duplicate slug")
        ids.add(r["id"])
        slugs.add(r["slug"])
    for folder in sorted(p.name for p in (ROOT / "recipes").iterdir() if p.is_dir()):
        if folder not in slugs:
            errors.append(f"recipes/{folder}: not in catalog.json (folder name must be the recipe slug)")
    for e in errors:
        print(f"::error::{e}")
    print(f"{len(cat['recipes'])} recipes in {len(codes)} categories; {len(errors)} problem(s)")
    return 1 if errors else 0


def readme(cat: dict) -> int:
    done = {p.name for p in (ROOT / "recipes").iterdir() if p.is_dir()}
    lines = []
    for c in cat["categories"]:
        rs = [r for r in cat["recipes"] if r["category"] == c["code"]]
        ready = sum(r["slug"] in done for r in rs)
        lines += ["", f"### {c['name']} ({ready}/{len(rs)})", ""]
        for r in rs:
            if r["slug"] in done:
                lines.append(f"- ✅ **{r['id']}** [{r['title']}](recipes/{r['slug']}/) · [article]({SITE}/{c['slug']}/{r['slug']}/)")
            else:
                lines.append(f"- ⬜ **{r['id']}** {r['title']}")
    block = "\n".join([BEGIN, *lines, "", END])
    path = ROOT / "README.md"
    text = path.read_text(encoding="utf-8")
    text = re.sub(re.escape(BEGIN) + r".*?" + re.escape(END), lambda _: block, text, flags=re.S)
    path.write_text(text, encoding="utf-8", newline="\n")
    print(f"README.md: {len(done)} of {len(cat['recipes'])} recipes have code")
    return 0


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "check"
    sys.exit({"check": check, "readme": readme}[cmd](load()))
