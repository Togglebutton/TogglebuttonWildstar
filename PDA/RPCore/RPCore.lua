local RPCore = {}

-- RCMP - RPCore Connection and Messaging Protocol
-- (yes, it's redundant, but I get to reference the Mounties)
local RCMPMessage = {}

RCMPMessage.Type_Request = 1
RCMPMessage.Type_Reply = 2 
RCMPMessage.Type_Error = 3 
RCMPMessage.Type_Broadcast = 4

RCMPMessage.ProtocolVersion = 1

function RCMPMessage:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.protocol = RCMPMessage.ProtocolVersion
    o.messagetype = RCMPMessage.Type_Request
    o.origin = RPCore:GetOriginName()

    return o
end

-- Accessor Convenience functions
-- Yes, we could just set command/sequence/etc., but this abstraction
-- means that if the actual internal variables change down the road,
-- the API continues to work.

function RCMPMessage:GetSequence()
	return self.sequence
end

function RCMPMessage:SetSequence(nSequence)
	if (type(nSequence) ~= "number") then
		error("RPCore: Attempt to set non-number sequence: " .. tostring(nSequence))
	end
	
	self.sequence = nSequence	
end

function RCMPMessage:GetCommand()
	return self.command
end

function RCMPMessage:SetCommand(strCommand)
	if (type(strCommand) ~= "string") then
		error("RPCore: Attempt to set non-string command: " .. tostring(strCommand))
	end

	self.command = strCommand
end

function RCMPMessage:GetType()
	return self.messagetype
end

function RCMPMessage:SetType(eMessageType)
	if (type(eMessageType) ~= "number") then
		error("RPCore: Attempt to set non-number type: " .. tostring(eMessageType))
	end
	
	if (eMessageType < RCMPMessage.Type_Request or eMessageType > RCMPMessage.Type_Error) then
		error("RPCore: Attempt to set unknown message type " .. eMessageType)
	end

	self.messagetype = eMessageType
end

function RCMPMessage:GetAddonProtocol()
	return self.addon
end

function RCMPMessage:SetAddonProtocol(strAddon)
	if (type(strAddon) ~= "string" and type(strAddon) ~= "nil") then
		error("RPCore: Attempt to set non-string addon: " .. tostring(strAddon))
	end

	self.addon = strAddon
end

function RCMPMessage:GetOrigin()
	return self.origin
end

function RCMPMessage:SetOrigin(strOrigin)
	if (type(strOrigin) ~= "string") then
		error("RPCore: Attempt to set non-string origin: " .. tostring(strOrigin))
	end

	self.origin = strOrigin
end

function RCMPMessage:GetDestination()
	return self.destination
end

function RCMPMessage:SetDestination(strDestination)
	if (type(strDestination) ~= "string") then
		error("RPCore: Attempt to set non-string destination: " .. tostring(strDestination))
	end

	self.destination = strDestination
end

function RCMPMessage:GetPayload()
	return self.payload
end

function RCMPMessage:SetPayload(tPayload)
	if (type(tPayload) ~= "table") then
		error("RPCore: Attempt to set non-table payload: " .. tostring(tPayload))
	end

	self.payload = tPayload
end

function RCMPMessage:Version()
	return self.protocol 
end

function RCMPMessage:ToCommPacket()

    return {
        rcmpv = self.protocol,
        command = self.command:lower(),
        messagetype = self.messagetype,
        addon = self.addon and self.addon:lower() or nil,
        payload = self.payload,  
        sequence = self.sequence,
        origin = self.origin,
        destination = self.destination
    }

end

function RCMPMessage:FromCommPacket(tPacket)

    if (tPacket == nil) then return end
    
	-- Protocol-revision 1
	-- These will PROBABLY always be valid.
    self.protocol = tPacket.rcmpv
    self.command = tPacket.command:lower()
    self.messagetype = tPacket.messagetype
    self.addon = tPacket.addon and tPacket.addon:lower() or nil
    self.payload = tPacket.payload
    self.sequence = tPacket.sequence
    self.origin = tPacket.origin
    self.destination = tPacket.destination
    
    -- Down the road, version-specific handling can go here
    
end

function RCMPMessage:ToString()
    local result = string.format("<%d> %s -> [%s:%d]", self.sequence or -1,
                            self.origin or "<unknown>", self.command or "<unknown>", 
                            self.messagetype or -1)

    if (self.addon ~= nil) then
        result = result .. string.format(" (%s)", self.addon)
    end

    if (self.destination ~= nil) then
        result = result .. string.format(" -> %s", self.destination)    
	end    
    return result
end

function RPCore:Reply(mMessage, tPayload)
	
    local newPacket = RPCore.RCMPMessage:new()
    newPacket.protocol = mMessage:Version()
    newPacket.sequence = mMessage:GetSequence()
    newPacket.addon = mMessage:GetAddonProtocol()
    newPacket.messagetype = RPCore.RCMPMessage.Type_Reply
    newPacket.payload = tPayload
    newPacket.destination = mMessage:GetOrigin()
	newPacket.command = mMessage:GetCommand()
    newPacket.origin = RPCore:GetOriginName()
    return newPacket
end

RPCore.RCMPMessage = RCMPMessage
RPCore.Error_UnimplementedProtocol = 1
RPCore.Error_UnimplementedCommand = 2
RPCore.Error_RequestTimedOut = 3

RPCore.Debug_Errors = 1
RPCore.Debug_Comm = 2 
RPCore.Debug_Access = 3

RPCore.Version = "1.0"

RPCore.TTL_Trait = 120
RPCore.TTL_Version = 300
RPCore.TTL_Flood = 30
RPCore.TTL_Channel = 60
RPCore.TTL_Packet = 15
RPCore.TTL_CacheDie = 604800

RPCore.Flag_InCharacter = 1
RPCore.Flag_Available = 2 
RPCore.Flag_InScene = 3 

RPCore.Trait_Name = "fullname"
RPCore.Trait_NameAndTitle = "title"
RPCore.Trait_RPState = "rpstate"
RPCore.Trait_Description = "shortdesc"
RPCore.Trait_Biography = "bio"

function RPCore:Initialize()
	Apollo.RegisterAddon(self)
end

function RPCore:OnLoad()

	-- This table contains API protocol records.
	-- The key is an API protocol name, while the value
	-- is an array of functions.  When a command for
	-- a given API protocol comes in, RPCore will call
	-- each function for that API protocol, passing
	-- the RCMPMessage as the one parameter.
	-- 
	self.tApiProtocolHandlers = {}

	-- This table contains our current stored traits
	-- The key is a given trait name, while the value
	-- is a table containing 'data' and 'revision'.
	self.tLocalTraits = {}

	-- Requests table
	-- This table is keyed off of the message sequence
	-- number.  The value is a table with 'message',
	-- 'time' and an optional 'handler' function.
	-- If a message is sent with a handler set, 
	-- any error/reply will be passed to that handler
	-- specifically.
	self.tOutgoingRequests = {}
	
	-- FloodPrevent Table
	-- This table is keyed off of a player's name, and contains 
	-- a table of addon:command identifiers with the last time
	-- the command was sent.
	self.tFloodPrevent = {}
	
	-- Cached player data table
	-- Basically multiple 'local traits' tables,
	-- save that the trait also contains a 'time' 
	-- field for when the trait was last updated.
	-- So we don't constantly ask for fresher versions. 
	-- 
	self.tCachedPlayerData = {}
	
	self.tPendingPlayerTraitRequests = {}
	
	-- Cached channels, so we don't lag by joining
	-- repeatedly.
	self.tCachedPlayerChannels = {}

	self.bTimeoutRunning = false
	self.nSequenceCounter = 0
	self.nDebugLevel = 0
	
	self.qPendingMessages = Queue:new()
	
	self.kstrRPStateStrings = {
		"In-Character, Not Available for RP",
		"Available for RP",
		"In-Character, Available for RP",
        "In a Private Scene (Temporarily OOC)",
		"In a Private Scene",
        "In an Open Scene (Temporarily OOC)",
        "In an Open Scene"
	}
	
	self.strPlayerName = nil 
	
	Apollo.RegisterTimerHandler("RPCore_RCMP_Timeout","HandleMessageTimeouts",self)
	Apollo.RegisterTimerHandler("RPCore_RCMP_TimeoutShutdown","ShutdownTimeoutTimer",self)
	Apollo.RegisterTimerHandler("RPCore_RCMP_Queue","ProcessMessageQueue",self)
	Apollo.RegisterTimerHandler("RPCore_RCMP_QueueShutdown","ShutdownQueueTimer",self)
	Apollo.RegisterTimerHandler("RPCore_RCMP_Setup","RCMPInitialize",self)
	Apollo.RegisterTimerHandler("RPCore_TraitQueue","ProcessTraitQueue",self)
	Apollo.RegisterTimerHandler("RPCore_CacheClean","CleanupCache",self)
	
	Apollo.CreateTimer("RPCore_RCMP_Setup",1,false) 
	Apollo.CreateTimer("RPCore_CacheClean", 60, true)
end 

function RPCore:OnSave(eLevel)
	if (eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character) then return nil end 

	return self:CacheAsTable()
end 

function RPCore:OnRestore(eLevel, tData)
	if (tData ~= nil and eLevel == GameLib.CodeEnumAddonSaveLevel.Character) then 
		self:LoadFromTable(tData)
	end
end

function RPCore:RCMPInitialize()
	if (GameLib.GetPlayerUnit() == nil) then 
		Apollo.CreateTimer("RPCore_RCMP_Setup",1,false)
		return
	end

    self.chnRPCore = ICCommLib.JoinChannel("RPCore","OnRCMP",self)
end
	
function RPCore:GetOriginName()
	local myUnit = GameLib.GetPlayerUnit()
	
	if (myUnit ~= nil) then 
		self.strPlayerName = myUnit:GetName() 
	end 
	
	return self.strPlayerName 
end 

function RPCore:SetDebugLevel(nDebugLevel)
	self.nDebugLevel = nDebugLevel
end

function RPCore:ValueOfBit(p)
	return 2 ^ (p - 1)  -- 1-based indexing
end

function RPCore:HasBitFlag(x, p)
	local np = self:ValueOfBit(p) 
	return x % (np + np) >= np       
end

function RPCore:SetBitFlag(x, p, b)
	local np = self:ValueOfBit(p) 
	if (b) then 
		return self:HasBitFlag(x, p) and x or x + np
	else 
		return self:HasBitFlag(x, p) and x - np or x 
	end 
end

function RPCore:Log(nLevel, strLog)
	-- Eventually, we can use nLevel for verbosity.
	if (nLevel > self.nDebugLevel) then return end
	
	Print("RPCore: " .. strLog)
end

function RPCore:FlagsToString(nState)
    local strState = self.kstrRPStateStrings[nState] or "Not Available for RP"
    
    return strState    
end

function RPCore:EscapePattern(strPattern)
    -- Prefix every non-alphanumeric character (%W) with a % escape character, 
    -- where %% is the % escape, and %1 is original character
    return strPattern:gsub("(%W)","%%%1")
end

function RPCore:TruncateString(strText, nLength)
	if (strText == nil) then return nil end 
	if (strText:len() <= nLength) then return strText end 
	
	local strResult = strText:sub(1,nLength) 
	local nSpacePos = strResult:find(" ",-1)
	if (nSpacePos ~= nil) then 
		strResult = strResult:sub(1,nSpacePos - 1) .. "..."
	end 
	
	return strResult
end 

function RPCore:GetTrait(strTarget, strTrait)
	local result = nil 
	
	if (strTrait == RPCore.Trait_Name) then 
		result = self:FetchTrait(strTarget,"fullname") or strTarget
	elseif (strTrait == RPCore.Trait_NameAndTitle) then 
		local name = self:FetchTrait(strTarget,"fullname")
		result = self:FetchTrait(strTarget,"title") 
		
		if (result == nil) then 
			result = name 
		else 
			local nStart,nEnd = result:find("#name#")
			if (nStart ~= nil) then 
				result = result:gsub("#name#",self:EscapePattern(name or strTarget))
			else 
				result = result .. " " .. (name or strTarget)
			end
		end 
	elseif (strTrait == RPCore.Trait_Description) then 
		result = self:FetchTrait(strTarget,"shortdesc")	
		if (result ~= nil) then 
			result = self:TruncateString(result,250)
		end
	elseif (strTrait == RPCore.Trait_RPState) then 
		local rpFlags = self:FetchTrait(strTarget,"rpflags") or 0
		result = self:FlagsToString(rpFlags)
	elseif (strTrait == RPCore.Trait_Biography) then 
		result = self:FetchTrait(strTarget, "biography")
	else 
		result = self:FetchTrait(strTarget, strTrait)
	end
	
	return result
end

function RPCore:SetRPFlag(flag, bSet)
    local nState, nRevision = self:GetLocalTrait("rpflag")
    
    nState = self:SetBitFlag(flag, bSet)
    self:SetLocalTrait("rpflag",nState)
end

function RPCore:ProcessTraitQueue()
	for strTarget, aRequests in pairs(self.tPendingPlayerTraitRequests) do 
		self:Log(RPCore.Debug_Comm,"Sending " .. table.getn(aRequests) .. " queued trait requests to " .. strTarget)
		local mMessage = RPCore.RCMPMessage:new()
		mMessage:SetDestination(strTarget) 
		mMessage:SetCommand("get")
		mMessage:SetPayload(aRequests) 
		
		self:SendMessage(mMessage) 
		
		self.tPendingPlayerTraitRequests[strTarget] = nil
	end
end 

function RPCore:FetchTrait(strTarget, strTraitName)
	if (strTarget == nil or strTarget == self:GetOriginName()) then
		-- This is for us!
		local tTrait = self.tLocalTraits[strTraitName] or {}
		
		self:Log(RPCore.Debug_Access,string.format("Fetching own %s: (%d) %s", strTraitName, tTrait.revision or 0, tostring(tTrait.data)))
		
		return tTrait.data, tTrait.revision
	else
		-- This is for someone else!
		local tPlayerTraits = self.tCachedPlayerData[strTarget] or {}
		local tTrait = tPlayerTraits[strTraitName] or {}
		
		self:Log(RPCore.Debug_Access,string.format("Fetching %s's %s: (%d) %s", strTarget, strTraitName, tTrait.revision or 0, tostring(tTrait.data)))
		-- If we don't have a cached trait, or our last request
		-- was more than 5 minutes ago, we request.
		local nTTL = RPCore.TTL_Trait
		if ((tTrait.revision or 0) == 0) then nTTL = 10 end 
		if (tTrait == nil or (os.time() - (tTrait.time or 0)) > nTTL) then
			tTrait.time = os.time()
			tPlayerTraits[strTraitName] = tTrait
			self.tCachedPlayerData[strTarget] = tPlayerTraits
			
			local tPendingPlayerQuery = self.tPendingPlayerTraitRequests[strTarget] or {}
			
			local tRequest = { trait = strTraitName, revision = tTraitRevision or 0 }

			table.insert(tPendingPlayerQuery,tRequest)

			self.tPendingPlayerTraitRequests[strTarget] = tPendingPlayerQuery 		
			
			Apollo.CreateTimer("RPCore_TraitQueue",1,false) 				
		end
		
		return tTrait.data, tTrait.revision
	end
end

function RPCore:CacheTrait(strTarget, strTrait, data, nRevision)
	if (strTrait == nil) then return end 

	if (strTarget == nil or strTarget == self:GetOriginName()) then
		-- This is for us!
		self.tLocalTraits[strTrait] = { data = data, revision = nRevision }

		self:Log(RPCore.Debug_Access,string.format("Caching own %s: (%d) %s", strTrait, nRevision or 0, tostring(data)))
				
		Event_FireGenericEvent("RPCore_TraitChanged", 
			{ player = self:GetOriginName(), trait = strTrait, data = data, revision = nRevision })
	else
		local tPlayerTraits = self.tCachedPlayerData[strTarget] or {}
		if (nRevision ~= 0 and tPlayerTraits.revision == nRevision) then 
			tPlayerTraits.time = os.time()
			return
		end
		
		if (data == nil) then return end 
		
		tPlayerTraits[strTrait] = { data = data, revision = nRevision, time = os.time() }
		self.tCachedPlayerData[strTarget] = tPlayerTraits
		
		self:Log(RPCore.Debug_Access,string.format("Caching %s's %s: (%d) %s", strTarget, strTrait, nRevision or 0, tostring(data)))
		Event_FireGenericEvent("RPCore_TraitChanged", 
			{ player = strTarget, trait = strTrait, data = data, revision = nRevision })
	end
end

function RPCore:SetLocalTrait(strTrait, data)
	local value, revision = self:FetchTrait(nil, strTrait)
	
	-- If the value is the same as our current data, we don't care.
	if (value == data) then return end

	if (strTrait == "state" or strTrait == "rpflag") then revision = 0 else revision = (revision or 0) + 1 end
	
	-- Otherwise, we increment our revision, cache and update	
	self:CacheTrait(nil, strTrait, data, revision)
end

function RPCore:GetLocalTrait(strTrait)
	return self:FetchTrait(nil, strTrait)
end

function RPCore:QueryVersion(strTarget)
	if (strTarget == nil or strTarget == self:GetOriginName()) then 
		local aProtocols = {}
				
		for strAddonProtocol, _ in pairs(self.tApiProtocolHandlers) do 
			table.insert(aProtocols, strAddonProtocol)
		end

		return RPCore.Version, aProtocols		
	end

	local tPlayerTraits = self.tCachedPlayerData[strTarget] or {}
	local tVersionInfo = tPlayerTraits["__rpVersion"] or {}

	-- Let's avoid flooding while we're waiting, shall we?
	local nLastTime = self:TimeSinceLastAddonProtocolCommand(strTarget,nil,"version")
	if (nLastTime < RPCore.TTL_Version) then 
		return tVersionInfo.version, tVersionInfo.addons
	end

	self:MarkAddonProtocolCommand(strTarget,nil,"version")		
	self:Log(RPCore.Debug_Access,string.format("Fetching %s's version", strTarget))
	if (tVersionInfo.version == nil or (os.time() - (tVersionInfo.time or 0) > RPCore.TTL_Version)) then
		local mMessage = RPCore.RCMPMessage:new()
		mMessage:SetDestination(strTarget)
		mMessage:SetType(RPCore.RCMPMessage.Type_Request)
		mMessage:SetCommand("version")
			
		self:SendMessage(mMessage)
	end
	
	return tVersionInfo.version, tVersionInfo.addons
end


function RPCore:StoreVersion(strTarget, strVersion, aProtocols)
	if (strTarget == nil or strVersion == nil) then return end 

	local tPlayerTraits = self.tCachedPlayerData[strTarget] or {}
	tPlayerTraits["__rpVersion"] = { version = strVersion, protocols = aProtocols, time = os.time() }
	self.tCachedPlayerData[strTarget] = tPlayerTraits
	
	self:Log(RPCore.Debug_Access,string.format("Storing %s' version: %s", strTarget, strVersion))
	Event_FireGenericEvent("RPCore_VersionUpdated", 
		{ player = strTarget, version = strVersion, protocols = aProtocols })
	
end

function RPCore:TimeSinceLastAddonProtocolCommand(strTarget, strAddonProtocol, strCommand)
	local strCommandId = string.format("%s:%s:%s", strTarget, strAddonProtocol or "base", strCommand) 
	
	local lastTime = self.tFloodPrevent[strCommandId] or 0
	
	return (os.time() - lastTime) 
end

function RPCore:MarkAddonProtocolCommand(strTarget, strAddonProtocol, strCommand)
	local strCommandId = string.format("%s:%s:%s", strTarget, strAddonProtocol or "base", strCommand) 
	
	self.tFloodPrevent[strCommandId] = os.time()	
end

function RPCore:OnRCMP(channel, tMsg, strSender)

    if (tonumber(tMsg.rcmpv or 0) > RPCore.RCMPMessage.ProtocolVersion) then
        -- Protocol version is higher than ours, we probably can't
        -- parse this.
        Print("RPCore: Warning: Received packet for unrecognized version " .. tMsg.rcmpv)
        return
    end

    local packet = RPCore.RCMPMessage:new()
    packet:FromCommPacket(tMsg)
	if (strSender ~= nil) then 
		packet:SetOrigin(strSender)
	end

	-- In case we are dealing with broadcast-y mode channel...	
	if (packet:GetDestination() == self:GetOriginName()) then 
		self:ProcessMessage(packet)
	end
end

function RPCore:ProcessMessage(packet)
	self:Log(RPCore.Debug_Comm,"process: " .. packet:ToString())
	
	if (eType == RPCore.RCMPMessage.Type_Error) then
		local tData = self.tOutgoingRequests[packet:GetSequence()] or {}
		if (tData.handler) then 
			tData.handler(packet)
			self.tOutgoingRequests[packet:GetSequence()] = nil
			return
		end
    end

    if (packet:GetAddonProtocol() == nil) then
		local eType = packet:GetType()
		local tPayload = packet:GetPayload() or {}
        -- This is something for RPCore itself.
        if (eType == RPCore.RCMPMessage.Type_Request) then
            -- Someone is requesting standardized data from us.  Let's handle this!

			if (packet:GetCommand() == "get") then
				-- They're requesting something from our data.
				local aReplies = {}
				for _, tTrait in ipairs(tPayload) do 
					local data, revision = self:FetchTrait(nil, tTrait.trait or "")
					if (data ~= nil) then
						local tResponse = { trait = tTrait.trait, revision = revision }
						if (tPayload.revision == 0 or revision ~= tPayload.revision) then 
							tResponse.data = data
						end
						table.insert(aReplies,tResponse)
					else 
						table.insert(aReplies, { trait = tTrait.trait, revision = 0 })
					end 
				end
				local mReply = self:Reply(packet, aReplies)
				self:SendMessage(mReply) 
			elseif (packet:GetCommand() == "version") then
				-- 'Version' has no actual parameters.
				local aProtocols = {}
				
				for strAddonProtocol, _ in pairs(self.tApiProtocolHandlers) do 
					table.insert(aProtocols, strAddonProtocol)
				end
				
				local mReply = self:Reply(packet,{ version = RPCore.Version, protocols = aProtocols })
				self:SendMessage(mReply)
			else
				-- This is not a command we know.  Uhoh.
				local mReply = self:Reply(packet, { error = self.Error_UnimplementedCommand })
				mReply:SetType(RPCore.RCMPMessage.Type_Error)
				self:SendMessage(mReply)
			end
        elseif (eType == RPCore.RCMPMessage.Type_Reply) then
            -- We have received a reply!  Let's cache our data, and
            -- fire the necessary event.
			if (packet:GetCommand() == "get") then 
				-- A response to a trait request!
				for _, tTrait in ipairs(tPayload) do 
					self:CacheTrait(packet:GetOrigin(), tTrait.trait, tTrait.data, tTrait.revision)
				end 
			elseif (packet:GetCommand() == "version") then
				-- We got someone's version information!
				self:StoreVersion(packet:GetOrigin(), tPayload.version, tPayload.protocols)	
			end			
        end
    else
        -- This is something explicitly targeted at an addon.
        local aAddon = self.tApiProtocolHandlers[packet:GetAddonProtocol()]

        if (aAddon ~= nil or table.getn(aAddon) == 0) then
			for _, fHandler in ipairs(aAddon) do 
				fHandler(packet) 
            end
		elseif (packet:GetType() == RPCore.RCMPMessage.Type_Request) then
			local mError = self:Reply(packet, { type = self.Error_UnimplementedProtocol })
			mError:SetType(RPCore.RCMPMessage.Type_Error)
			self:SendMessage(mError)
        end
    end

	-- If this was a reply to something we sent, let's clear out the outgoing request
	if (packet:GetType() == RPCore.RCMPMessage.Type_Reply or packet:GetType() == RPCore.RCMPMessage.Type_Error) then 
		self.tOutgoingRequests[packet:GetSequence()] = nil        
	end
end

function RPCore:SendMessage(mMessage, fCallback)
    if (mMessage.destination == self:GetOriginName()) then
        -- This is meant for me, I'm not going to send it.  You
        -- can't make me.
		self:Log(RPCore.Debug_Comm,"send (to self? ignoring): " .. mMessage:ToString())
        return
    end

    if (mMessage:GetType() ~= RPCore.RCMPMessage.Type_Error and mMessage:GetType() ~= RPCore.RCMPMessage.Type_Reply) then
    	self.nSequenceCounter = tonumber(self.nSequenceCounter or 0) + 1
    	mMessage:SetSequence(self.nSequenceCounter)
    end

	self.tOutgoingRequests[mMessage:GetSequence()] = { message = mMessage, handler = fHandler, time = os.time() }

	self.qPendingMessages:Push(mMessage)
	
	if (not self.bQueueProcessRunning) then 
		self.bQueueProcessRunning = true 
		Apollo.CreateTimer("RPCore_RCMP_Queue",0.5,true)
	end
end

function RPCore:ChannelForPlayer(strPlayerName)
	local channel = self.chnRPCore
	
	if (channel == nil) then 
   		channel = ICCommLib.JoinChannel("RPCore","OnRCMP",self)
	end
	
	return channel
end

function RPCore:ShutdownQueueTimer()
	self:Log(RPCore.Debug_Comm,"queue: query queue is empty, stopping queue timer")
	Apollo.StopTimer("RPCore_RCMP_Queue")
	self.bQueueProcessRunning = false 
end

function RPCore:ProcessMessageQueue()
	if (self.qPendingMessages:GetSize() == 0) then 
		Apollo.CreateTimer("RPCore_RCMP_QueueShutdown",0.1,false) 
		return 
	end
	
	local mMessage = self.qPendingMessages:Pop()

	self:Log(RPCore.Debug_Comm,"send: " .. mMessage:ToString())
    
	local channel = self:ChannelForPlayer(mMessage:GetDestination())
	-- See if we support the private message API
	-- So as to be forward-looking!
	if (channel.SendPrivateMessage ~= nil) then 
		channel:SendPrivateMessage({ mMessage:GetDestination() }, 
									 mMessage:ToCommPacket())
	else 
	    channel:SendMessage(mMessage:ToCommPacket())	
	end 

	-- Start our timeout handler.
	if (not self.bTimeoutRunning) then
		self.bTimeoutRunning = true
		Apollo.CreateTimer("RPCore_RCMP_Timeout",15,true)
	end
end

function RPCore:ShutdownTimeoutTimer()
	self:Log(RPCore.Debug_Comm,"timeout: outgoing message queue is empty, stopping timeout timer")
	Apollo.StopTimer("RPCore_RCMP_Timeout")
	self.bTimeoutRunning = false 
end 

function RPCore:HandleMessageTimeouts()
	local now = os.time()
	local nOutgoingCount = 0
	for nSequence, tData in pairs(self.tOutgoingRequests) do 
		if (now - tData.time > RPCore.TTL_Packet) then 
			-- Time out!
			self:Log(RPCore.Debug_Comm,"timeout: " .. tData.message:ToString())
			local mError = self:Reply(tData.message,
				{ error = RPCore.Error_RequestTimedOut, destination = tData.message:GetDestination(), localError = true })
			mError:SetType(RPCore.RCMPMessage.Type_Error)
			self:ProcessMessage(mError)
			
			self.tOutgoingRequests[nSequence] = nil
		else 
			nOutgoingCount = nOutgoingCount + 1
		end
	end
	
	-- Clean out stale flood prevention IDs
	for strCommandId, nLastTime in pairs(self.tFloodPrevent) do 
		if ((now - nLastTime) > RPCore.TTL_Flood) then 
			self.tFloodPrevent[strCommandId] = nil
		end
	end
	
	for strPlayerName, tChannelRecord in pairs(self.tCachedPlayerChannels) do 
		if ((now - tChannelRecord.time or 0) > RPCore.TTL_Channel) then 
			self.tCachedPlayerChannels[strPlayerName] = nil
		end
	end
	
	if (nOutgoingCount == 0) then
		Apollo.CreateTimer("RPCore_RCMP_TimeoutShutdown",0.1,false)  
	end 
end

function RPCore:CleanupCache()
	local nNow = os.time()
	for strPlayerName, tRecord in pairs(self.tCachedPlayerData) do 
		for strParam, tTrait in pairs(tRecord) do 
			if (nNow - tTrait.time > RPCore.TTL_CacheDie) then 
				tRecord[strParam] = nil 
			end 
		end 
		
		local nCount = 0
		for strParam, tTrait in pairs(tRecord) do 
			nCount = nCount + 1
		end
		
		if (nCount == 0) then 
			self.tCachedPlayerData[strPlayerName] = nil 
		end 
	end 
end 

function RPCore:Stats()
	local nLocalTraits = 0
	local nPlayers = 0
	local nCachedTraits = 0
	
	for strTrait, tRecord in pairs(self.tLocalTraits) do 
		nLocalTraits = nLocalTraits + 1
	end 
	
	for strPlayer, tRecord in pairs(self.tCachedPlayerData) do 
		nPlayers = nPlayers + 1
		for strParam, tValue in pairs(tRecord) do 
			nCachedTraits = nCachedTraits + 1
		end 
	end
	
	return nLocalTraits, nCachedTraits, nPlayers
end 

function RPCore:GetCachedPlayerList()
	Print("Retrieving Cached Player List")
	local tCachedPlayers = {}
	for strPlayerName,_ in pairs(self.tCachedPlayerData) do table.insert(tCachedPlayers,strPlayerName) end
	return tCachedPlayers
end

function RPCore:CacheAsTable()
	local tData = {}
	
	tData.localData  = self.tLocalTraits
	tData.cachedData = self.tCachedPlayerData
	
	return tData
end

function RPCore:LoadFromTable(tData)
	self.tLocalTraits = tData.localData or {}
	self.tCachedPlayerData = tData.cachedData or {}
	
	self:CleanupCache() -- Just in case there's old, stale data.
end

function RPCore:RegisterAddonProtocolHandler(strAddonProtocol,fHandler)
	local aHandlers = self.tApiProtocolHandlers[strAddonProtocol] or {}
	
	table.insert(aHandlers,fHandler)
	self.tApiProtocolHandlers[strAddonProtocol] = aHandlers
end 

_G["GeminiPackages"]:NewPackage(RPCore,"RPCore-1.1",1)

RPCore:Initialize()
