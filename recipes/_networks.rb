
#
# Setup subnets
#
if node[:dhcp][:networks].empty?
  raise Chef::Exceptions::AttributeNotFound, "node[:dhcp][:networks] must contain entries for dhcpd to operate"
end

node[:dhcp][:networks].each do |net|
  if node[:dhcp][:use_bags] == true
    data = data_bag_item( node[:dhcp][:networks_bag], Helpers::DataBags.escape_bagname(net) )
  else
    data = node[:dhcp][:network_data][net]
  end

  next unless data
  # run the lwrp with the bag data
  dhcp_subnet data["address"] do
    broadcast data["broadcast"]
    netmask   data["netmask"]
    routers   data["routers"] || []
    options   data["options"] || []
    range     data["range"] || ""
    ddns      data["ddns"] if data.has_key? "ddns"
    conf_dir  node[:dhcp][:dir]
    peer      node[:domain] if node[:dhcp][:failover]
    key       data["key"] || {}
    zones     data["zones"] || []
  end
end
