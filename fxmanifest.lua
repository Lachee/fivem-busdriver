-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

version '1.0.0'
author 'Lachee'
description 'ESX Job for being a bus driver.'
repository 'https://github.com/lachee/fivem-busdriver'

fx_version 'adamant'
games { 'rdr3', 'gta5' }

dependencies {
    'mysql-async'
    'esx'
}

client_scripts{
    "config.lua",
    "common/utils.lua"
    "client/client.lua"
}

server_scripts{
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "common/utils.lua"
    "server/server.lua",
}

