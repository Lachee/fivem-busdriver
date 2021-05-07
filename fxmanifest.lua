-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

version '1.0.0'
author 'Lachee'
description 'ESX Job for being a bus driver.'
repository 'https://github.com/lachee/fivem-busdriver'

client_scripts {
    "config.lua",
    "common/*.lua",
    "common/entities/*.lua",

    "client/entities/*.lua",
    
    "client/utils.lua",
    "client/client.lua",
    "client/commands.lua",
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "common/*.lua",
    "common/entities/*.lua",

    "server/entities/*.lua",
 
    "server/server.lua",
    "server/commands.lua",
}


fx_version 'adamant'
games { 'rdr3', 'gta5' }

dependencies {
    'mysql-async'
}

