--[[Preliminaries
    Release-version: 1.1
    Author: cmdpwnd
    Project-Contributors: cmdpwnd
]]

--[[Guide
    [[Log:
        Configuration variable: _logPath
            default: _logPath = '/log.dc'
            
        stores result of an attempt to access a drive. 
        Format: user @ drive: boolean 
            [   
                user = diskLabel, 
                drive = drive's wired modem peripheral, 
                boolean = true or false
            ]
    ]]
    [[Key:
        Configuration variable: _keyPath
            default: _keyPath = '/aaa.dc'
        Note: _keyPath is the path at the root of the floppy disk NOT the computer
            
        stores user's authentication information on floppy disk
        Format: {
                    authentication = 'password'
                }
    ]]
    [[Database:
        Configuration variable: _dbPath
            default: _dbPath = '/db.dc'
            
        stores authorized drives, block information for drives & AAA configuration for users
        Format: {
                    alias = {
                            aliasName = 'minecraftName'
                        }
                    aaa = {
                        username = {
                            authentication = 'password',
                            authorization = {'_drive#','_drive#','etc'}
                        }
                    },
                    blockInfo = {
                        _drive# = {x,y,z,block1,block2,isMuted,isDefault}
                    }
                },
        Note: underscore character is necessary in "_drive#" unless drive is adjacent to computer; provided such, give side
         Ex.[
                '_15'
                'bottom'
            ]
        
        Note: if aaa.username.authorization[1] == '*' then username has unrestricted [global] access to all drives
        
        Note: An in game player may have multiple aliases in addition to their in game name.
        
        blockInfo lists the following:
            x,y,z coordinates of a block in the world
            block to replace the initial block with 
            block to replace the second block with
            boolean to suppress in game authentication & authorization messages
            boolean to allow access to all authenticated users
            Ex.
                _10 = {1,2,3,'minecraft:redstone_block 1','minecraft:stone 0',true,true}
                
                Process: [
                            initial block @ 1,2,3 = minecraft:stone 1
                            initial block replaced by minecraft:redstone_block 1
                            minecraft:redstone_block 1 replaced by minecraft:stone 0
                        ]
    ]]
    [[Debug:
        Configuration variable: _debug
            default: _debug = {false,true,true,true,true,true}
             [ index#
                1: enable debugging, view REQ_PATHS, mimic writes from _logPath to screen
                2: view authentication and authorization status
                3: view disk events
                4: view function execution summarization
                5: view non-summarized function execution
                6: view explict and sensitive user data
            ]
            Note: levels are NOT inter-dependent
            
        allows administrator to view process information on a user's attempt to authenticate to a drive
        Format: DEBUG: msg
    ]]
    [[Console:
        **NOT FEATURED IN CURRENT VERSION**
    ]]
--]]

--[[Configuration Examples
    [[Database:
        {
            alias = {
                cmdpwnd = 'jacky500'
            }
            aaa = {
                cmdpwnd = {authentication = 'password', authorization = {'_10'}}
                jacky500 = {authentication = 'password', authorization = {'*'}} #Alias cmdpwnd does NOT use this table; A Floppy Disk with label 'jacky500' will use this table
            }
            blockInfo = {
                _10 = {1,2,3,'minecraft:redstone_block 1','minecraft:stone 0',false,false}
                _11 = {1,2,3,'minecraft:redstone_block 1','minecraft:stone 0'}   #same as _10
                _12 = {4,7,-3,'minecraft:stone 1','minecraft:stone 0',true,false}
                _13 = {4,7,-3,'minecraft:stone 1','minecraft:stone 0',true}      #same as _12
                _14 = {2,-2,13,'minecraft:air','minecraft:stone 2',true,true}
                _15 = {2,-2,13,'minecraft:air','minecraft:stone 2',false,true} #explicit order required in this case
            }
        }
    ]]
    [[Paths:
        _logPath = '/AAA/attempts.log'
        _dbPath = '/AAA/database'
        _keyPath = '/AccessKeys/AAA/key'
    ]]
    [[Debug:
        _debug = {false,true,true,true,true,true}
            debugging disabled
            
        _debug = {true,true,false,true,true,false}
            debugging enabled: ignore level 3,6 msg
    ]]
--]]