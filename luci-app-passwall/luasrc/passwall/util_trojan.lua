module("luci.passwall.util_trojan", package.seeall)
local api = require "luci.passwall.api"
local uci = api.uci
local json = api.jsonc

function gen_config_server(node)
	local cipher = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:AES128-SHA:AES256-SHA:DES-CBC3-SHA"
	local cipher13 = "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384"
	local config = {
		run_type = "server",
		local_addr = "::",
		local_port = tonumber(node.port),
		remote_addr = (node.remote_enable == "1" and node.remote_address) and node.remote_address or nil,
		remote_port = (node.remote_enable == "1" and node.remote_port) and tonumber(node.remote_port) or nil,
		password = node.uuid,
		log_level = (node.log and node.log == "1") and tonumber(node.loglevel) or 5,
		ssl = {
			cert = node.tls_certificateFile,
			key = node.tls_keyFile,
			key_password = "",
			cipher = cipher,
			cipher_tls13 = cipher13,
			prefer_server_cipher = true,
			reuse_session = true,
			session_ticket = (node.tls_sessionTicket == "1") and true or false,
			session_timeout = 600,
			plain_http_response = "",
			curves = "",
			dhparam = ""
		},
		tcp = {
			prefer_ipv4 = false,
			no_delay = true,
			keep_alive = true,
			reuse_port = false,
			fast_open = (node.tcp_fast_open and node.tcp_fast_open == "1") and true or false,
			fast_open_qlen = 20
		}
	}
	return config
end

function gen_config(var)
	local node_id = var["-node"]
	if not node_id then
		print("-node 不能为空")
		return
	end
	local node = uci:get_all("passwall", node_id)
	local run_type = var["-run_type"]
	local local_addr = var["-local_addr"]
	local local_port = var["-local_port"]
	local server_host = var["-server_host"] or node.address
	local server_port = var["-server_port"] or node.port
	local loglevel = var["-loglevel"] or 2
	local cipher = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:AES128-SHA:AES256-SHA:DES-CBC3-SHA"
	local cipher13 = "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384"

	if api.is_ipv6(server_host) then
		server_host = api.get_ipv6_only(server_host)
	end
	local server = server_host

	local trojan = {
		run_type = run_type,
		local_addr = local_addr,
		local_port = tonumber(local_port),
		remote_addr = server,
		remote_port = tonumber(server_port),
		password = {node.password},
		log_level = tonumber(loglevel),
		ssl = {
			verify = (node.tls_allowInsecure ~= "1") and true or false,
			verify_hostname = true,
			cert = nil,
			cipher = cipher,
			cipher_tls13 = cipher13,
			sni = node.tls_serverName or server,
			alpn = {"h2", "http/1.1"},
			reuse_session = true,
			session_ticket = (node.tls_sessionTicket and node.tls_sessionTicket == "1") and true or false,
			curves = ""
		},
		udp_timeout = 60,
		tcp = {
			use_tproxy = (node.type == "Trojan-Plus" and var["-use_tproxy"]) and true or nil,
			no_delay = true,
			keep_alive = true,
			reuse_port = true,
			fast_open = (node.tcp_fast_open == "true") and true or false,
			fast_open_qlen = 20
		}
	}
	return json.stringify(trojan, 1)
end

_G.gen_config = gen_config

if arg[1] then
	local func =_G[arg[1]]
	if func then
		print(func(api.get_function_args(arg)))
	end
end
