/*
	Start of the death message stuff.
	2024: Compatibility with base gamemode changes
*/

include( 'vgui/vgui_gamenotice.lua' )

local function CreateDeathNotify()

	local x, y = ScrW(), ScrH()

	g_DeathNotify = vgui.Create( "DNotify" )

	g_DeathNotify:SetPos( 0, 25 )
	g_DeathNotify:SetSize( x - ( 25 ), y )
	g_DeathNotify:SetAlignment( 9 )
	g_DeathNotify:SetSkin( GAMEMODE.HudSkin )
	g_DeathNotify:SetLife( 4 )
	g_DeathNotify:ParentToHUD()

end

hook.Add( "InitPostEntity", "CreateDeathNotify", CreateDeathNotify )

local function RecvPlayerKilledByPlayer( length )

	local victim 	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker 	= net.ReadEntity()

	if ( !IsValid( attacker ) ) then return end
	if ( !IsValid( victim ) ) then return end

	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team() )
end

net.Receive( "PlayerKilledByPlayer", RecvPlayerKilledByPlayer )


local function RecvPlayerKilledSelf( length )

	local victim 	= net.ReadEntity()

	if ( !IsValid( victim ) ) then return end

	GAMEMODE:AddPlayerAction( victim:Name(), GAMEMODE.SuicideString )

end

net.Receive( "PlayerKilledSelf", RecvPlayerKilledSelf )


local function RecvPlayerKilled( length )

	local victim 	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker 	= net.ReadString()

	print("RecvPlayerKilled")
	if ( !IsValid( victim ) ) then return end

	GAMEMODE:AddDeathNotice( "#" .. attacker, -1, inflictor, victim:Name(), victim:Team() )

end

net.Receive( "PlayerKilled", RecvPlayerKilled )

local function RecvPlayerKilledNPC( length )

	local victim 	= net.ReadString()
	local inflictor	= net.ReadString()
	local attacker 	= net.ReadEntity()

	if ( !IsValid( attacker ) ) then return end

	GAMEMODE:AddDeathNotice( attacker, attacker:Team(), inflictor, "#" .. victim, 0 )

end

net.Receive( "PlayerKilledNPC", RecvPlayerKilledNPC )


local function RecvNPCKilledNPC( length )

	local victim 	= "#" .. net.ReadString()
	local inflictor	= net.ReadString()
	local attacker 	= "#" .. net.ReadString()

	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim, -1 )

end

net.Receive( "NPCKilledNPC", RecvNPCKilledNPC )


/*---------------------------------------------------------
   Name: gamemode:AddDeathNotice( Attacker, team1, Inflictor, Victim, team2, flags )
   Desc: Adds an death notice entry
---------------------------------------------------------*/
function GM:AddDeathNotice( attacker, team1, inflictor, victim, team2 )

	if ( !IsValid( g_DeathNotify ) ) then return end
	
	if inflictor and inflictor != "suicide" then

		local pnl = vgui.Create( "GameNotice", g_DeathNotify )

		pnl:AddText( attacker or "", GAMEMODE:GetTeamNumColor(team1) )
		pnl:AddIcon( inflictor )
		pnl:AddText( victim or "", GAMEMODE:GetTeamNumColor(team2) )

		g_DeathNotify:AddItem( pnl )

	else
		--We need to handle suicides within this due to basegame deprecation
		
		GAMEMODE:AddTeamPlayerAction( victim, GAMEMODE.SuicideString, team2 )
	end
end

function GM:AddPlayerAction( ... )

	if ( !IsValid( g_DeathNotify ) ) then return end

	local pnl = vgui.Create( "GameNotice", g_DeathNotify )

	for k, v in ipairs({...}) do
		pnl:AddText( v )
	end

	// The rest of the arguments should be re-thought.
	// Just create the notify and add them instead of trying to fit everything into this function!???

	g_DeathNotify:AddItem( pnl )

end

function GM:AddTeamPlayerAction( subject, action, teamnum )

	if ( !IsValid( g_DeathNotify ) ) then return end

	local pnl = vgui.Create( "GameNotice", g_DeathNotify )

	pnl:AddText( subject, GAMEMODE:GetTeamNumColor(teamnum) )
	pnl:AddText( action )

	// The rest of the arguments should be re-thought.
	// Just create the notify and add them instead of trying to fit everything into this function!???

	g_DeathNotify:AddItem( pnl )

end
