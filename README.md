# Fantasy Ground Extension - AmmoManager

This D&D 5E extension allows players to link an ammo entry in their inventory to the ammo a weapon uses in the actions tab of their character sheet. The linked ammo's count will be automatically changed in the actions tab when it is increased or decreased in the inventory, and - upon ammo recovery - will update the inventory's ammo count accordingly.

Ammo bundles (i.e. "Arrows (20)" ) are handled correctly, and ammo will only be removed from the inventory in batches of the number listed in the item's name (20 in this case). The remainder will stay ticked in the actions tab (future recoveries will not take into account the remainder from a previous recovery. For this reason, it is recommended you adjust the bundle amount in your inventory manually after a recovery, or you use ammo singles).

An added house rule setting allows you to pick between 25%, 50% (default), 75%, and 100% ammo recovery.

![Example](https://i.imgur.com/nmSlb1v.gif)

### Specifics:
In order to be correctly linked, an item record must be in the players inventory and must have the subtype "Ammunition". The copy of the record that exists in the inventory must be dragged onto the empty link space on the actions tab next to the ammo count for the weapon you want to link it to. Multiple weapons can share the same ammo entry in the inventory, and their checkboxes will be synced. Two new radial menu options will appear when right-clicking the ammo counter: "Remove Ammo Link" to break the link between the weapon and the ammo entry in the inventory, and "Recover Ammo" to untick all ticked ammo checkboxes and remove half (by default) the expended ammo from your inventory.

### Compatibility:
This extension should be fully compatible with most extensions, unless another extension modifies the ammo section of the actions tab.

### Changelog:
- Hotfix to v1.0.1
--Fixed invalid processing when removing ammo not linked to any weapon from an inventory.
- Updated to v1.0.1
--Multiple weapons using the same ammo entry will have their ammo checkboxes linked.
- Released v1.0.0 
