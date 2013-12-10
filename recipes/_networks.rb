
#
# Setup subnets
#
if node[:dhcp][:networks].empty?
  Chef::Log.info("Attribute node[:dhcp][:networks] is empty, guess you are using LWRP")
  return
end

node[:dhcp][:networks].each do |net|
  net_bag = data_bag_item( node[:dhcp][:networks_bag], Helpers::DataBags.escape_bagname(net) )

  next unless net_bag
  # run the lwrp with the bag data
  dhcp_subnet     net_bag["address"] do
    broadcast     net_bag["broadcast"]
    netmask       net_bag["netmask"]
    routers       net_bag["routers"] || []
    options       net_bag["options"] || []
    pool_options  net_bag["pool_options"] || []
    extra_pools   net_bag["extra_pools"] || []
    range         net_bag["range"] || ""
    ddns          net_bag["ddns"] if net_bag.has_key? "ddns"
    conf_dir      node[:dhcp][:dir]
    peer          node[:domain] if node[:dhcp][:failover]
    key           net_bag["key"] || {}
    zones         net_bag["zones"] || []
  end
end
