class_name ItemDef
extends Resource
## Data-driven item definition for the inventory system (vertical slice).
## Pure data + tier-aware description; NO runtime behavior (effects touch
## autoloads, so they live in Inventory). One .tres per item under
## res://resources/items/, filename stem MUST equal `id`.

enum Category { KEY = 0, COMPANION_CARE = 1, CONSUMABLE = 2, LORE = 3 }
## NONE/FEED_COMPANION = consumable verbs. EQUIP/THROW = weapons "used" from the
## satchel to become the equipped weapon; the attack reads the equipped weapon's
## kind (EQUIP → melee swing, THROW → ranged projectile spending `ammo_id`).
enum UseKind { NONE = 0, FEED_COMPANION = 1, EQUIP = 2, THROW = 3 }

## Stable lookup key — MUST match the .tres filename stem; the only field
## serialized into PlayerData.inventory (the save/load join key).
@export var id: StringName = &""
@export var display_name: String = ""
@export var category: int = Category.CONSUMABLE
@export var icon: Texture2D  ## 32x32 pixel icon, nullable (placeholder rect on miss)
@export_multiline var description: String = ""
## Optional VESSEL/HARDENED variant (empty = reuse description). Texture/narrative only.
@export_multiline var distorted_description: String = ""
@export var stackable: bool = false
@export var max_stack: int = 9
@export var discardable: bool = true
## Empty = usable on anyone/none; set (&"briar") gates FEED_COMPANION to that companion.
@export var companion_id: StringName = &""
@export var use_kind: int = UseKind.NONE
## For THROW weapons (e.g. slingshot): the item id spent per shot (e.g. &"sling_stones").
@export var ammo_id: StringName = &""
@export var bond_delta: float = 0.0
@export var morality_delta: float = 0.0
@export var consumed_on_use: bool = true
## One-time story unlock granted simply by ACQUIRING this item (e.g. the flute sets
## `flute_found`). Set on add to inventory, never cleared — persists via PlayerData.
@export var grants_flag: StringName = &""


## Tier-aware inspect text: distorted variant at HARDENED/VESSEL when set,
## else the base description. Texture only — never mechanical.
func read_description() -> String:
	if not distorted_description.is_empty() and PlayerData:
		if PlayerData.get_morality_tier() >= PlayerData.MoralityTier.HARDENED:
			return distorted_description
	return description
