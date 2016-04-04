--[[DataCenter AAA Server by cmdpwnd]]

term.clear()
term.setCursorPos(1,1)


local _logPath = 'log.dc'
local _dbPath = '/_db.dc'
local _keyPath = '/aaa.dc'
local _debugPath = '/debug.dc'
local _debug = {true,true,true,true,true,true}
--------------
local _timerOwner = {open={}}
local _argsCache = {open={}}
local db

function init()
    dprint('REQ_PATHS\nLog: '.._logPath..'\nDatabase: '.._dbPath..'\nDisk Key: '.._keyPath..'\n------------------\n',1)
    local f = fs.open(_dbPath,'r')
    db = textutils.unserialize(f.readAll()) f.close()
    db.wrap = {}
    db.prefix = {}
    db.unprefix = {}
    dprint('%init: database loaded',0)
    local adj = {'top','bottom','left','right','front','back'}
    for k in pairs(db.blockInfo) do
        noSkip = true
        for a=1,6 do
            if k == adj[a] then
                db.wrap[adj[a]] = peripheral.wrap(adj[a])
                db.prefix[adj[a]] = adj[a]
                db.unprefix[adj[a]] = adj[a]
                noSkip = false
            end
        end
        if noSkip == true then
            db.wrap['drive'..k] = peripheral.wrap('drive'..k)
            db.prefix[k] = 'drive'..k
            db.unprefix[db.prefix[k]] = k
        end
    end
    dprint('%database: network drive connections successful',0)
    for k in pairs(db.aaa) do
        for b=1,#db.aaa[k].authorization do
            if not db.aaa[k].authorization[b] == '*' then
                db.aaa[k].authorization[b] = db.prefix[db.aaa[k].authorization[b]]
            end
        end
        if db.alias[k] == nil then
            db.alias[k] = k
        end
    end
    dprint('%database: users inherited default drives',0)
    dprint('%database: fixed unassigned aliases',0)
    dprint('%init: switching to run()\n//////////////////',0)
    run()
end

function run()
    while true do
        local event, data = os.pullEvent()
        if event == 'timer' then
            local id = data
            dprint('event: expired timerID: '..id,3)
            for k in pairs(_timerOwner) do
                for i=1,#_timerOwner[k] do
                    dprint('_timerOwner['..tostring(k)..']['..tostring(i)..'] = '..tostring(_timerOwner[k][i]),5)
                    if _timerOwner[k][i] == id then
                        open(false,false,false,false,false,false,false,id)
                        local s = dprint('closed door\n------------------',4) or dprint('------------------',0)
                        table.remove(_timerOwner[k],i)
                    end
                end
            end
        elseif event == 'disk' then
                local drive = data
                dprint('event @ '..drive,3)
                local mount = disk.getMountPath(drive)
                local user = disk.getLabel(drive)
                dprint('Disk Label: '..tostring(user),5)
                local ok, err = pcall(function() local f = fs.open(mount.._keyPath,'r') f.close() end)
                if ok then
                    local f = fs.open(mount.._keyPath,'r')
                    local key = textutils.unserialize(f.readAll())
                    f.close()
                    --Authenticate
                    if not db.aaa[user] then
                        db.aaa[user] = {authentication = false,authorization = {'_'}}
                    end
                    if key.authentication == db.aaa[user].authentication then
                        dprint('Authentication = true',2)
                        if db.aaa[user].authorization[1] == '*' then --Global Authorization
                            dprint('Authorization = true | Global',2)
                            log(_logPath,tostring(os.time())..': '..user..' @ '..drive..' : true\n')
                            dprint(user..' @ '..drive..' : true',1)
                            disk.eject(drive)
                            local bi = db.blockInfo[db.unprefix[drive]]
                            open(bi[1],bi[2],bi[3],bi[4],bi[5],bi[6],user) --Execute function to open door
                        else --Non-Global Authorization
                            dprint('Attempting Non-Global Authorization',5)
                            local breakout = false
                            for k in pairs(db.blockInfo) do
                                dprint('iteration key='..k,5)
                                for a=1,#db.aaa[user].authorization do
                                    dprint('iteration a='..a,5)
                                    dprint('User Authorization index: '..tostring(db.prefix[db.aaa[user].authorization[a]]),6)
                                    if db.prefix[k] == drive and db.blockInfo[k][7] == true then
                                        dprint('Authorization = true | Default Drive',2)
                                        log(_logPath,tostring(os.time())..': '..user..' @ '..drive..' : true\n')
                                        dprint(user..' @ '..drive..' : true',1)
                                        disk.eject(drive)
                                        local bi = db.blockInfo[db.unprefix[drive]]
                                        open(bi[1],bi[2],bi[3],bi[4],bi[5],bi[6],user) --Execute function to open door
                                        breakout = true
                                        break
                                    elseif db.prefix[db.aaa[user].authorization[a]] == drive then
                                        dprint('Authorization = true | Authorized',2)
                                        log(_logPath,tostring(os.time())..': '..user..' @ '..drive..' : true\n')
                                        dprint(user..' @ '..drive..' : true',1)
                                        disk.eject(drive)
                                        local bi = db.blockInfo[db.unprefix[drive]]
                                        open(bi[1],bi[2],bi[3],bi[4],bi[5],bi[6],user) --Execute function to open door
                                        breakout = true
                                        break
                                    end
                                end
                                if breakout == true then
                                    local s = dprint('End Loop\n------------------',5) or dprint('------------------',0)
                                    dprint(s)
                                    break
                                end
                            end
                            if not breakout == true then
                                dprint('Authorization = false | Database: No Match',2)
                                log(_logPath,tostring(os.time())..': '..user..' @ '..drive..' : false\n')
                                dprint(user..' @ '..drive..' : false',1)
                                tellraw(user,'Access Denied: Invalid Key','red')
                                disk.eject(drive)
                            end
                        end
                    else
                        local s = dprint('Authentication = false \n|||||| key: '..tostring(key.authentication or 'nil')..'\n|||||| db:  '..tostring(db.aaa[user].authentication or 'nil'),6) or dprint('Authentication = false',2)
                        dprint(s)
                        log(_logPath,tostring(os.time())..': '..user..' @ '..drive..' : false\n')
                        dprint(user..' @ '..drive..' : false\n------------------',1)
                        tellraw(user,'Access Denied: Invalid Key','red')
                        disk.eject(drive)
                    end
                else --_keyPath not found: Null key
                    disk.eject(drive)
                    tellraw(user,'Access Denied: Null Key','yellow')
                    dprint('Authentication = false | Null Key',2)
                    dprint('null @ '..drive..' : false\n------------------',1)
                end
            end
        end
end

function open(x,y,z,block,block2,muted,user,timerID)
    if timerID then
        local args = _argsCache.open[#_argsCache.open]
        commands.exec('setblock '..args[1]..' '..args[2]..' '..args[3]..' '..args[4]..' destroy')
        table.remove(_argsCache.open)
        return
    end
    if not muted then tellraw(user,'Access Granted: '..user,'green') end
    commands.exec('setblock '..x..' '..y..' '..z..' '..block..' destroy')
    table.insert(_timerOwner.open,os.startTimer(2))
    table.insert(_argsCache.open,{x,y,z,block2})
    dprint('creating timerID: '..tostring(_timerOwner.open[#_timerOwner.open]),5)
end

function tellraw(user,text,color)
    if not user or not db.alias[user] then commands.exec('tellraw @p'..' {"text":\"'..text..'\","color":\"'..color..'\","italic":true}') else
        commands.exec('tellraw '..db.alias[user]..' {"text":\"'..text..'\","color":\"'..color..'\","italic":true}')
    end
end

function dprint(str,lvl)
    if _debug[1] == true and _debug[lvl] == true then
        print('DEBUG: '..tostring(str))
        local f = fs.open(_debugPath,'a')
        f.write(tostring(os.time())..': '..tostring(str)..'\n')
        f.close()
        return true
    elseif _debug[1] == true and lvl == 0 then
        print(tostring(str))
        local f = fs.open(_debugPath,'a')
        f.write(tostring(os.time())..': '..tostring(str)..'\n')
        f.close()
        return true
    end
    return false
end

function log(path,str)
    local ok = pcall(function() local f=fs.open(path,'a') f.close() end)
    if ok then
        local f = fs.open(path,'a')
        f.write(tostring(str))
        f.close()
        return
    end
    return false
end

init()
