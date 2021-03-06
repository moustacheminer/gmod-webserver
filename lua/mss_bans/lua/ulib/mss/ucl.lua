local API_URL = 'http://127.0.0.1/api/v1'
local AUTH = 'kromatic is a gay'

--[[
    HTTP REST endpoint
]]--

local function fetch(endpoint, payload, callback)
  print('Fetching: ' .. API_URL .. endpoint)
  http.Post(
    API_URL .. endpoint,
    {
      payload = util.TableToJSON(payload)
    },
    function(body)
      if callback then
        return callback(util.JSONToTable(body))
      end
    end,
    function(error)
      print('Error fetching: ' .. API_URL .. endpoint .. ' - ' .. error)
    end,
    {
      Authorization = AUTH
    }
  )
end

function ULib.ucl.saveGroups()
  for _, groupInfo in pairs( ULib.ucl.groups ) do
    table.sort(groupInfo.allow)
  end

  -- Write to local file as well as the API
  ULib.fileWrite( ULib.UCL_GROUPS, ULib.makeKeyValues( ULib.ucl.groups ) )

  fetch(
    '/ulib/ucl-save-groups',
    {
      groups = ULib.ucl.groups
    },
    nil
  )
end

local function reloadGroups()
  fetch(
    '/ulib/ucl-reload-groups',
    {},
    function(groups)
      ULib.ucl.groups = groups;
    end
  )
end

function ULib.ucl.saveUsers()
  for _, userInfo in pairs( ULib.ucl.users ) do
    table.sort(userInfo.allow)
    table.sort(userInfo.deny)
  end

  -- Write to local file as well as the API
  ULib.fileWrite( ULib.UCL_USERS, ULib.makeKeyValues( ULib.ucl.users ) )

  fetch(
    '/ulib/ucl-save-users',
    {
      users = ULib.ucl.users
    },
    nil
  )
end

local function reloadUsers()
  fetch(
    '/ulib/ucl-reload-users',
    {},
    function(users)
      ULib.ucl.users = users;
    end
  )
end

reloadGroups()
reloadUsers()

timer.Create(
  'ls-ucl-refresh',
  5,
  0,
  function()
    reloadGroups()
    reloadUsers()
  end
)
