--Lua的Json简略用法.配合UnityEngine.PlayerPrefs用来保存本地聊天记录

--解码json  key：读取PlayerPrefs的键
function JsonRead(key)
    local PlayerPrefs = UnityEngine.PlayerPrefs
    local jsonRead =  PlayerPrefs.GetString(key)
    if jsonRead == nil or jsonRead == '' or jsonRead == "{}" then
        return nil
    end
    local data = json.decode(jsonRead)
	return data
end

--编码json table:需编码的数据表  key：存入PlayerPrefs的键
function JsonWrite(table,key)
    local PlayerPrefs = UnityEngine.PlayerPrefs
    local jsonEncode = json.encode(table)
    PlayerPrefs.SetString(key, jsonEncode)
end

-------------------------------------以下为实例.只提供参考--------------------------------------------
--pChatData:游戏运行时用来做更新的聊天数据（同时也用来更新本地聊天数据）.
local pChatData = {}

--开始游戏时.读取缓存在本地的PlayerPrefs（通过JsonRead），并重新构造table数据
function GetLocalPChatData()
	local localChatData = JsonRead('PChatData')
	if localChatData then
		for _,v in ipairs(localChatData) do
			pChatData[v.frinedId] = {}
			for i = 0,table.getCount(v) - 1 do 
				table.insert(pChatData[v.frinedId],v["info" .. i])
			end
		end
	end
end

--拿到已经初始化完成的聊天数据.进入游戏
function ReturnLocalPChatData()
	return pChatData
end

--这个函数在游戏中是当notify消息过来时，处理聊天消息的函数.通俗的将就是用做消息缓存更新
function SetLocalPChatData()
    if(GetLocalPChatData()) [otherAccid] then
        if table.getCount((GetLocalPChatData()) [otherAccid]) >= 20 then
            table.remove((GetLocalPChatData()) [otherAccid], 1)
        end
        table.insert((GetLocalPChatData()) [otherAccid], data2)
    else
        (GetLocalPChatData()) [otherAccid] = {data2}
    end
end
--构造json数据结构.这里使用的结构为：
--{
--  {
--     frinedId = 1,
--     info1 = 
--     {
--         guildName = "1",
--         ...,
--     },
--     info2 = 
--     {
--         guildName = "2",
--         ...,
--     },
--     ...,
--  }，
--  {
--     frinedId = 2,
--     info1 = 
--     {
--         guildName = "1",
--         ...,
--     },
--     info2 = 
--     {
--         guildName = "2",
--         ...,
--     },
--     ...,
--  }，
--  ...，
--}
--我这样做的目的是为了用数据时，可以很方便的通过frinedId去获取该玩家的所有聊天记录
--这一步也就是说构造Json结构，并存入PlayerPrefs，键：PChatData
function SetTableData()
    local list = GameMgr.GetLocalPChatData()
    local _ts = {}
	for k,v in pairs(list) do
		local _temp = {}
		_temp.frinedId = k
		local index = 1
		for _,info in ipairs(v) do
			_temp["info" .. index] = 
			{
				guildName = info.guildName,
				lv = info.lv,
				vipLv = info.vipLv,
				accId = info.accId,
				chatType = info.chatType,
				roleName = info.roleName,
				msg = info.msg,
				sendTime = info.sendTime,
				baseId = info.baseId,
				isFriend = info.isFriend,
				guildId = info.guildId,
			}
			index = index + 1
		end
		table.insert(_ts,_temp)
    end
    JsonWrite(_ts,'PChatData')
end
------------------------------END-----------------------------






-------项目需要，又写了一个最近聊天的本地缓存(简略介绍)--------
--最近聊天数据
local recentlyData = {}

--获取并缓存数据
function GetRecentlyChatData()
	local reInfos = JsonRead('RecentlyChatData')
	if reInfos then
		for _,v in ipairs(reInfos) do
			recentlyData[v.accId] = v
			UIMgr.SetlocalPChatList(v)
		end
	end
end

--返回数据
function ReturnRecentlyChatData()
	return recentlyData
end

--缓存存入的时间
function SetRecentlyChatData()
    if (GetRecentlyChatData())[otherAccid] then
        (GetRecentlyChatData())[otherAccid].time = os.time()
    else
        (GetRecentlyChatData())[otherAccid] = vo
        ControlRecentlyLength(vo)
    end
end

--控制最近聊天本地数据的数量(<40)
function ControlRecentlyLength(infos)
    UIMgr.SetlocalPChatList(infos)
    local _ts = UIMgr.GetlocalPChatList()
    if table.getCount(_ts) > 40 then
        table.sort(_ts,function(a,b)
            return a.time > b.time
        end)
        local lastId = _ts[table.getCount(_ts)].accId
        local tb = removeValueByKey(GameMgr.GetRecentlyChatData(),lastId)
        table.remove(UIMgr.GetlocalPChatList(),table.getCount(_ts))
        SetRecentlyChatDataBySort(tb)
    end
end

--获取限制数量后的数据.并已根据时间排序
function SetRecentlyChatDataBySort(data)
	recentlyData = data
end

--构造并编码数据.key：RecentlyChatData
-- {
--     {
--         time = 111，
--         ...，
--     }，
--     {
--         time = 222，
--         ...，
--     }
--     ...，
-- }

function SetRecentlyTabletData()
    local list = GameMgr.GetRecentlyChatData()
    local _ls = {}
    for _, v in pairs(list) do
		local temp = {
			guildName = v.guildName,
			lv = v.lv,
			vipLv = v.vipLv,
			accId = v.accId,
			chatType = v.chatType,
			roleName = v.roleName,
			msg = v.msg,
			sendTime = v.sendTime,
			baseId = v.baseId,
			isFriend = v.isFriend,
			guildId = v.guildId,
			time = v.time,
		}
		table.insert(_ls,temp)
    end
    JsonWrite(_ls,'RecentlyChatData')
end

--获取最近聊天可使用的数据
function UseRecentlyData()
	local infos = GetRecentlyChatData()
	local _ts = {}
	if not infos then return _ts end

	for _,v in pairs(infos) do
		table.insert(_ts,v)
	end
	return _ts
end








