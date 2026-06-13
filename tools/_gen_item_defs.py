#!/usr/bin/env python3
"""Emit ItemDef .tres for the new inventory items (+ re-emit dried_meat with its
icon). Category {KEY=0, COMPANION_CARE=1, CONSUMABLE=2, LORE=3}; UseKind
{NONE=0, FEED_COMPANION=1}. Weapons are use_kind=NONE for now — combat dispatch
is a separate task; they exist as carryable items with art."""
from pathlib import Path

ICON_UID = {
    "dried_meat": "uid://pa1sb0em4lfl",
    "forest_berries": "uid://kqq56af16pv5",
    "sturdy_stick": "uid://cg3vcd2qmc3w2",
    "slingshot": "uid://d0hf8iwcu2nm8",
    "sling_stones": "uid://bite0x8585rc",
    "buried_bone": "uid://cuxdf4pj7557l",
    "tin_locket": "uid://dh1o2pmt1u0wu",
}

# id -> dict of fields (res_uid, name, category, desc, distorted, stackable,
#                       max_stack, discardable, companion, use_kind, bond, mor, consumed)
ITEMS = {
    "dried_meat": dict(res="uid://b8driedmeat001", name="Dried Meat", cat=1,
        desc="A strip of dried meat. Briar's ribs show through his scruff.",
        dist="Protein. The body that runs needs fuel.",
        stack=True, maxs=9, disc=True, comp="briar", uk=1, bond=8.0, mor=-3.0, cons=True),
    "forest_berries": dict(res="uid://b8berries00001", name="Forest Berries", cat=1,
        desc="A handful of dark berries from the fringe. Briar sniffs them, then eats.",
        dist="Bitter. Things grow sweet where the soil is rich.",
        stack=True, maxs=9, disc=True, comp="briar", uk=1, bond=4.0, mor=1.0, cons=True),
    "sturdy_stick": dict(res="uid://b8stick000001", name="Sturdy Stick", cat=2,
        desc="A heavy branch. Better than bare hands.",
        dist="It remembers being part of something that grew.",
        stack=False, maxs=1, disc=True, comp="", uk=0, bond=0.0, mor=0.0, cons=False),
    "slingshot": dict(res="uid://b8slingshot01", name="Slingshot", cat=2,
        desc="A whittled slingshot. Useless without stones.",
        dist="A small machine for keeping the world at a distance.",
        stack=False, maxs=1, disc=True, comp="", uk=0, bond=0.0, mor=0.0, cons=False),
    "sling_stones": dict(res="uid://b8slingstone1", name="Sling Stones", cat=2,
        desc="Smooth pebbles, sized for the sling.",
        dist="Each one is a small, simple certainty.",
        stack=True, maxs=9, disc=True, comp="", uk=0, bond=0.0, mor=0.0, cons=False),
    "buried_bone": dict(res="uid://b8bone0000001", name="Buried Bone", cat=1,
        desc="A bone Briar dug up. He is enormously proud of it.",
        dist="Someone buried this where the digging would be easy.",
        stack=False, maxs=1, disc=True, comp="briar", uk=1, bond=6.0, mor=0.0, cons=True),
    "tin_locket": dict(res="uid://b8locket00001", name="Tin Locket", cat=0,
        desc="A child's locket, caked with grave soil. It will not open.",
        dist="You know whose this was. You have always known.",
        stack=False, maxs=1, disc=False, comp="", uk=0, bond=0.0, mor=0.0, cons=False),
}

OUT = Path("resources/items")
TPL = '''[gd_resource type="Resource" script_class="ItemDef" load_steps=3 format=3 uid="{res}"]

[ext_resource type="Script" uid="uid://cnh5esvabvxfq" path="res://scripts/items/item_def.gd" id="1_itemdef"]
[ext_resource type="Texture2D" uid="{icon}" path="res://assets/sprites/items/{id}.png" id="2_icon"]

[resource]
script = ExtResource("1_itemdef")
id = &"{id}"
display_name = "{name}"
category = {cat}
icon = ExtResource("2_icon")
description = "{desc}"
distorted_description = "{dist}"
stackable = {stack}
max_stack = {maxs}
discardable = {disc}
companion_id = &"{comp}"
use_kind = {uk}
bond_delta = {bond}
morality_delta = {mor}
consumed_on_use = {cons}
'''

def gd(b: bool) -> str:
    return "true" if b else "false"

for iid, f in ITEMS.items():
    text = TPL.format(res=f["res"], icon=ICON_UID[iid], id=iid, name=f["name"],
        cat=f["cat"], desc=f["desc"], dist=f["dist"], stack=gd(f["stack"]),
        maxs=f["maxs"], disc=gd(f["disc"]), comp=f["comp"], uk=f["uk"],
        bond=f["bond"], mor=f["mor"], cons=gd(f["cons"]))
    (OUT / f"{iid}.tres").write_text(text)
    print("wrote", iid)
