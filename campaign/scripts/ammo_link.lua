function onInit()
	registerMenuItem("Remove Ammo Link", "shortcutdelete", 1);
	registerMenuItem("Recover Ammo", "halve", 2);
	DB.addHandler(window.getDatabaseNode().getPath(), "onChildUpdate", onDataChanged);
	local shortcut = CharAmmoManager.getAmmoLink(window.getDatabaseNode());
	if shortcut and shortcut ~= "" then
		DB.addHandler(shortcut, "onChildUpdate", CharAmmoManager.onInvChanged);
	end
	onDataChanged();
end
function onClose()
	DB.removeHandler(window.getDatabaseNode().getPath(), "onChildUpdate", onDataChanged);
	local shortcut = CharAmmoManager.getAmmoLink(window.getDatabaseNode());
	if shortcut and shortcut ~= "" then
		DB.removeHandler(shortcut, "onChildUpdate", CharAmmoManager.onInvChanged);
	end
end
function onMenuSelection(selection)
	if selection == 1 then
		CharAmmoManager.clearAmmoLink(window.getDatabaseNode());
	end
	if selection == 2 then
		recoverAmmo();
	end
end
function recoverAmmo(nRecoveryCoef)
	if not nRecoveryCoef then
		nRecoveryCoef = tonumber(OptionsManager.getOption("HRRA"));
	end
	local nMaxAmmo = DB.getValue(window.getDatabaseNode(), "maxammo", 0);
	local nExpendedAmmo = DB.getValue(window.getDatabaseNode(), "ammo", 0);
	local nLostAmmo = math.ceil(nExpendedAmmo * (1-nRecoveryCoef));
	local shortcut = CharAmmoManager.getAmmoLink(window.getDatabaseNode());
	if shortcut and shortcut ~= "" then
		local nodeInvItem = DB.findNode(shortcut);
		local sName = DB.getValue(nodeInvItem, "name", "");
		local sCount = sName:match("\(%d+\)");
		local nCount = tonumber(sCount) or 1;
		local nMultiplier = DB.getValue(nodeInvItem, "count", 1);
		
		local nDiv = math.floor(nLostAmmo/nCount);
		local nRemainder = nLostAmmo%nCount;
		
		local weapons = CharAmmoManager.getWeaponsFromItemNode(nodeInvItem);
		for _,v in pairs(weapons) do
			DB.setValue(v, "ammo", "number", nRemainder);
		end
		DB.setValue(nodeInvItem, "count", "number", nMultiplier - nDiv);
	else
		DB.setValue(window.getDatabaseNode(), "ammo", "number", nLostAmmo);
	end
end
function onDataChanged()
	local bRanged = (window.type.getValue() ~= 0);
	window.ammolink.setVisible(bRanged);
	local shortcut = CharAmmoManager.getAmmoLink(window.getDatabaseNode());
	if shortcut and shortcut ~= "" then
		local nodeInvItem = DB.findNode(shortcut);
		local onDataChangedTemp = onDataChanged;
		onDataChanged = nil; -- prevents infinite loop when recalculating ammo
		CharAmmoManager.recalculateAmmoFromTemplate(nodeInvItem, window.getDatabaseNode());
		onDataChanged = onDataChangedTemp;
	end
end
function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local type, shortcut = draginfo.getShortcutData();
		if type == "item" and shortcut and shortcut ~= "" and shortcut:match("inventorylist\.(.*)") ~= nil then
			local node = window.getDatabaseNode();
			CharAmmoManager.clearAmmoLink(node);
			DB.setValue(node, "ammolink", "windowreference", type, shortcut);
			DB.addHandler(shortcut, "onChildUpdate", CharAmmoManager.onInvChanged);
			CharAmmoManager.recalculateAmmo(DB.findNode(shortcut));
			return true;
		end
	end
end