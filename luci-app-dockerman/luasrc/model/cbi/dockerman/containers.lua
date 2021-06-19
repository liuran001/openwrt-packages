--[[
LuCI - Lua Configuration Interface
Copyright 2019 lisaac <https://github.com/lisaac/luci-app-dockerman>
]]--

require "luci.util"
local http = require "luci.http"
local uci = luci.model.uci.cursor()
local docker = require "luci.model.docker"
local dk = docker.new()

local images, networks, containers
local res = dk.images:list()
if res.code <300 then images = res.body else return end
res = dk.networks:list()
if res.code <300 then networks = res.body else return end
res = dk.containers:list({query = {all=true}})
if res.code <300 then containers = res.body else return end

local urlencode = luci.http.protocol and luci.http.protocol.urlencode or luci.util.urlencode

function get_containers()
  local data = {}
  if type(containers) ~= "table" then return nil end
  for i, v in ipairs(containers) do
    local index = (10^12 - v.Created) .. "_id_" .. v.Id
    data[index]={}
    data[index]["_selected"] = 0
    data[index]["_id"] = v.Id:sub(1,12)
    -- data[index]["name"] = v.Names[1]:sub(2)
    data[index]["_status"] = v.Status
    if v.Status:find("^Up") then
      data[index]["_name"] = "<font color='green'>"..v.Names[1]:sub(2).."</font>"
      data[index]["_status"] = "<a href='"..luci.dispatcher.build_url("admin/docker/container/"..v.Id).."/stats'><font color='green'>".. data[index]["_status"] .. "</font>" .. "<br><font color='#9f9f9f' class='container_cpu_status'></font><br><font color='#9f9f9f' class='container_mem_status'></font><br><font color='#9f9f9f' class='container_network_status'></font></a>"
    else
      data[index]["_name"] = "<font color='red'>"..v.Names[1]:sub(2).."</font>"
      data[index]["_status"] = '<font class="container_not_running" color="red">'.. data[index]["_status"] .. "</font>"
    end
    if (type(v.NetworkSettings) == "table" and type(v.NetworkSettings.Networks) == "table") then
      for networkname, netconfig in pairs(v.NetworkSettings.Networks) do
        data[index]["_network"] = (data[index]["_network"] ~= nil and (data[index]["_network"] .." | ") or "").. networkname .. (netconfig.IPAddress ~= "" and (": " .. netconfig.IPAddress) or "")
      end
    end
    -- networkmode = v.HostConfig.NetworkMode ~= "default" and v.HostConfig.NetworkMode or "bridge"
    -- data[index]["_network"] = v.NetworkSettings.Networks[networkmode].IPAddress or nil
    -- local _, _, image = v.Image:find("^sha256:(.+)")
    -- if image ~= nil then
    --   image=image:sub(1,12)
    -- end
    if v.Ports and next(v.Ports) ~= nil then
      data[index]["_ports"] = nil
      local ip = require "luci.ip"
      for _,v2 in ipairs(v.Ports) do
        -- display ipv4 only
        if ip.new(v2.IP or "0.0.0.0"):is4() then
          data[index]["_ports"] = (data[index]["_ports"] and (data[index]["_ports"] .. ", ") or "")
          .. ((v2.PublicPort and v2.Type and v2.Type == "tcp") and ('<a href="javascript:void(0);" onclick="window.open((window.location.origin.match(/^(.+):\\d+$/) && window.location.origin.match(/^(.+):\\d+$/)[1] || window.location.origin) + \':\' + '.. v2.PublicPort ..', \'_blank\');">') or "")
          .. (v2.PublicPort and (v2.PublicPort .. ":") or "")  .. (v2.PrivatePort and (v2.PrivatePort .."/") or "") .. (v2.Type and v2.Type or "")
          .. ((v2.PublicPort and v2.Type and v2.Type == "tcp")and "</a>" or "")
        end
      end
    end
    for ii,iv in ipairs(images) do
      if iv.Id == v.ImageID then
        data[index]["_image"] = iv.RepoTags and iv.RepoTags[1] or (iv.RepoDigests[1]:gsub("(.-)@.+", "%1") .. ":<none>")
      end
    end
    data[index]["_id_name"] = '<a href='..luci.dispatcher.build_url("admin/docker/container/"..v.Id)..'  class="dockerman_link" title="'..translate("Container detail")..'">'.. data[index]["_name"] .. "<br><font color='#9f9f9f'>ID: " ..  data[index]["_id"] .. "</font></a><br>Image: " .. data[index]["_image"]

    if type(v.Mounts) == "table" and next(v.Mounts) then
      for _, v2 in pairs(v.Mounts) do
        if v2.Type ~= "volume" then
          local v_sorce_d, v_dest_d
          local v_sorce = ""
          local v_dest = ""
          for v_sorce_d in v2["Source"]:gmatch('[^/]+') do
            if v_sorce_d and #v_sorce_d > 12 then
              v_sorce = v_sorce .. "/" .. v_sorce_d:sub(1,8) .. ".."
            else
              v_sorce = v_sorce .."/".. v_sorce_d
            end
          end
          for v_dest_d in v2["Destination"]:gmatch('[^/]+') do
            if v_dest_d and #v_dest_d > 12 then
              v_dest = v_dest .. "/" .. v_dest_d:sub(1,8) .. ".."
            else
              v_dest = v_dest .."/".. v_dest_d
            end
          end
          data[index]["_mounts"] = (data[index]["_mounts"] and (data[index]["_mounts"] .. "<br>") or "") .. '<span title="'.. v2.Source.. "￫" .. v2.Destination .. '" ><a href="'..luci.dispatcher.build_url("admin/docker/container/"..v.Id)..'/file?path='..v2["Destination"]..'">' .. v_sorce .. "￫" .. v_dest..'</a></span>'
        end
      end
    end
    data[index]["_image_id"] = v.ImageID:sub(8,20)
    data[index]["_command"] = v.Command
  end
  return data
end

local c_lists = get_containers()
-- list Containers
-- m = Map("docker", translate("Docker"))
m = SimpleForm("docker", translate("Docker"))
m.submit=false
m.reset=false
m:append(Template("dockerman/containers_running_stats"))

docker_status = m:section(SimpleSection)
docker_status.template = "dockerman/apply_widget"
docker_status.err=docker:read_status()
docker_status.err=docker_status.err and docker_status.err:gsub("\n","<br>"):gsub(" ","&nbsp;")
if docker_status.err then docker:clear_status() end

c_table = m:section(Table, c_lists, translate("Containers"))
c_table.nodescr=true
c_table.config="containers"

container_selecter = c_table:option(Flag, "_selected","")
container_selecter.disabled = 0
container_selecter.enabled = 1
container_selecter.default = 0
container_selecter.width = "1%"

-- container_id = c_table:option(DummyValue, "_id", translate("ID"))
-- container_id.width="10%"
-- container_name = c_table:option(DummyValue, "_name", translate("Container Name"))
-- container_name.rawhtml = true
container_info = c_table:option(DummyValue, "_id_name", translate("Container Info"))
container_info.rawhtml = true
container_info.width="15%"
container_status = c_table:option(DummyValue, "_status", translate("Status"))
container_status.width="15%"
container_status.rawhtml=true
container_ip = c_table:option(DummyValue, "_network", translate("Network"))
container_ip.width="10%"
container_ports = c_table:option(DummyValue, "_ports", translate("Ports"))
container_ports.width="5%"
container_ports.rawhtml = true
container_ports = c_table:option(DummyValue, "_mounts", translate("Mounts"))
container_ports.width="25%"
container_ports.rawhtml = true
-- container_image = c_table:option(DummyValue, "_image", translate("Image"))
-- container_image.width="8%"

container_command = c_table:option(DummyValue, "_command", translate("Command"))
container_command.width="15%"

container_selecter.write=function(self, section, value)
  c_lists[section]._selected = value
end

local start_stop_remove = function(m,cmd)
  local c_selected = {}
  -- 遍历table中sectionid
  local c_table_sids = c_table:cfgsections()
  for _, c_table_sid in ipairs(c_table_sids) do
    -- 得到选中项的名字
    if c_lists[c_table_sid]._selected == 1 then
      c_selected[#c_selected+1] = c_lists[c_table_sid]["_id"] --container_name:cfgvalue(c_table_sid)
    end
  end
  if #c_selected >0 then
    docker:clear_status()
    local success = true
    for _,cont in ipairs(c_selected) do
      docker:append_status("Containers: " .. cmd .. " " .. cont .. "...")
      local res = dk.containers[cmd](dk, {id = cont})
      if res and res.code >= 300 then
        success = false
        docker:append_status("code:" .. res.code.." ".. (res.body.message and res.body.message or res.message).. "\n")
      else
        docker:append_status("done\n")
      end
    end
    if success then docker:clear_status() end
    luci.http.redirect(luci.dispatcher.build_url("admin/docker/containers"))
  end
end

action_section = m:section(Table,{{}})
action_section.notitle=true
action_section.rowcolors=false
action_section.template="cbi/nullsection"

btnnew=action_section:option(Button, "_new")
btnnew.inputtitle= translate("New")
btnnew.template = "dockerman/cbi/inlinebutton"
btnnew.inputstyle = "add"
btnnew.forcewrite = true
btnstart=action_section:option(Button, "_start")
btnstart.template = "dockerman/cbi/inlinebutton"
btnstart.inputtitle=translate("Start")
btnstart.inputstyle = "apply"
btnstart.forcewrite = true
btnrestart=action_section:option(Button, "_restart")
btnrestart.template = "dockerman/cbi/inlinebutton"
btnrestart.inputtitle=translate("Restart")
btnrestart.inputstyle = "reload"
btnrestart.forcewrite = true
btnstop=action_section:option(Button, "_stop")
btnstop.template = "dockerman/cbi/inlinebutton"
btnstop.inputtitle=translate("Stop")
btnstop.inputstyle = "reset"
btnstop.forcewrite = true
btnkill=action_section:option(Button, "_kill")
btnkill.template = "dockerman/cbi/inlinebutton"
btnkill.inputtitle=translate("Kill")
btnkill.inputstyle = "reset"
btnkill.forcewrite = true
btnremove=action_section:option(Button, "_remove")
btnremove.template = "dockerman/cbi/inlinebutton"
btnremove.inputtitle=translate("Remove")
btnremove.inputstyle = "remove"
btnremove.forcewrite = true
btnnew.write = function(self, section)
  luci.http.redirect(luci.dispatcher.build_url("admin/docker/newcontainer"))
end
btnstart.write = function(self, section)
  start_stop_remove(m,"start")
end
btnrestart.write = function(self, section)
  start_stop_remove(m,"restart")
end
btnremove.write = function(self, section)
  start_stop_remove(m,"remove")
end
btnstop.write = function(self, section)
  start_stop_remove(m,"stop")
end
btnkill.write = function(self, section)
  start_stop_remove(m,"kill")
end

return m
