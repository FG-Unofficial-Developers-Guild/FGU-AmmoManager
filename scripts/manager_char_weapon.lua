-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local addToWeaponDBOriginal;


function onInit()
	addToWeaponDBOriginal = CharWeaponManager.addToWeaponDB;
	CharWeaponManager.addToWeaponDB = addToWeaponDB;
	
	ItemManager.setCustomCharRemove(removeEvent);
end

--
--	Weapon inventory management
--

function onInvChanged(nodeParent, nodeChildUpdated)
	recalculateAmmo(nodeParent);
end

function recalculateAmmo(nodeInvItem, nodeWeapon)
	local sName = DB.getValue(nodeInvItem, "name", "");
	local sCount = sName:match("\(%d+\)");
	local nCount = tonumber(sCount) or 1;
	local nMultiplier = DB.getValue(nodeInvItem, "count", 1);
	
	if not nodeWeapon then
		nodeWeapon = getWeaponsFromItemNode(nodeInvItem);
	end
	if type(nodeWeapon) == "table" then
		for _,v in pairs(nodeWeapon) do
			DB.setValue(v, "maxammo", "number", nCount * nMultiplier)
		end
	else
		DB.setValue(nodeWeapon, "maxammo", "number", nCount * nMultiplier)
	end
end

function recalculateAmmoFromTemplate(nodeInvItem, nodeWeapon)
	local sName = DB.getValue(nodeInvItem, "name", "");
	local sCount = sName:match("\(%d+\)");
	local nCount = tonumber(sCount) or 1;
	local nMultiplier = DB.getValue(nodeInvItem, "count", 1);
	local nAmmo = DB.getValue(nodeWeapon, "ammo", 0);
	local nodeWeapons = getWeaponsFromItemNode(nodeInvItem);
	
	for _,v in pairs(nodeWeapons) do
		DB.setValue(v, "maxammo", "number", nCount * nMultiplier)
		DB.setValue(v, "ammo", "number", nAmmo)
	end
end

function recalculateAmmoFromWeapon(nodeWeapon)
	local shortcut = getAmmoLink(nodeWeapon);
	if not shortcut or shortcut == "" then
		return;
	end
	recalculateAmmo(DB.findNode(shortcut), nodeWeapon)
end

function clearAmmoLink(nodeWeapon, shortcut)
	if not shortcut or shortcut == "" then
		shortcut = getAmmoLink(nodeWeapon);
	end
	if shortcut and shortcut ~= "" then
		DB.removeHandler(shortcut, "onChildUpdate", CharAmmoManager.onInvChanged);
	end
	DB.setValue(nodeWeapon, "ammolink", "windowreference", nil, nil);
end

function getAmmoLink(nodeWeapon)
	local type, shortcut = DB.getValue(nodeWeapon, "ammolink", "windowreference");
	return shortcut;
end

function getWeaponsFromItemNode(nodeInvItem)
	local weapons = {};
	local shortcuts = {};
	local nodeChar = nodeInvItem.getChild("...");
	for _,v in pairs(DB.getChildren(nodeChar, "weaponlist")) do
		local sType, sShortcut = DB.getValue(v, "ammolink");
		if sType and sShortcut then
			local sID = sShortcut:match("inventorylist\.(.*)")
			if sID and sID == nodeInvItem.getName() then
				table.insert(weapons, v);
				table.insert(shortcuts, sShortcut);
			end
		end
	end
	return weapons, shortcuts;
end

function removeEvent(nodeItem)
	local sItemType = DB.getValue(nodeItem, "subtype", "");
	if sItemType:lower() == "ammunition" then
		local weaponNode, shortcuts = getWeaponsFromItemNode(nodeItem);
		
		if type(weaponNode) == "table" then
			if next(weaponNode) then
				DB.removeHandler(shortcuts[1], "onChildUpdate", CharAmmoManager.onInvChanged);
				for _,v in pairs(weaponNode) do
					DB.setValue(v, "ammolink", "windowreference", nil, nil);
				end
			end
		else
			if weaponNode then
				DB.setValue(weaponNode, "ammolink", "windowreference", nil, nil);
				DB.removeHandler(shortcuts, "onChildUpdate", CharAmmoManager.onInvChanged);
			end
		end
	end
end

function addToWeaponDB(nodeItem)
	addToWeaponDBOriginal(nodeItem);

	-- Parameter validation
	if not ItemManager.isWeapon(nodeItem) then
		return;
	end
	
	-- Get the weapon list we are going to add to
	local nodeChar = nodeItem.getChild("...");

	-- Handle special weapon properties
	local sProps = DB.getValue(nodeItem, "properties", "");
	
	local bThrown = CharWeaponManager.checkProperty(sProps, CharWeaponManager.WEAPON_PROP_THROWN);
	local bAmmo = CharWeaponManager.checkProperty(sProps, CharWeaponManager.WEAPON_PROP_AMMUNITION);
	
	if bAmmo or bThrown then
		for _,v in pairs(DB.getChildren(nodeChar, "weaponlist")) do
			local sType, sLink = DB.getValue(v, "shortcut");
			if sType and sLink then
				local sID = sLink:match("inventorylist\.(.*)")
				if sID and sID == nodeItem.getName() then
					DB.setValue(v, "ammolink", "windowreference", nil, nil);
					break
				end
			end
		end
	end
end