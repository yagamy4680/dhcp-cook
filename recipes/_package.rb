
package node[:dhcp][:package_name]
directory node[:dhcp][:dir]

# For DHCP debugging purposes
#
package "dhcpdump"

# Edit apparmor settings to allow dhcpd to access files at extra_config_path
#
unless node[:dhcp][:extra_config_path].empty?
  # update /etc/apparmor.d/usr.sbin.dhcpd on ubuntu > 9.10
  case node[:platform]
  when "ubuntu"
    if node[:platform_version].to_f >= 9.10
      template node[:dhcp][:apparmor_config] do
        owner "root"
        group "root"
        mode 0644
        source "usr.sbin.dhcpd.erb"
        variables(
          :extra_config_path => node[:dhcp][:extra_config_path]
        )
      end

      service "apparmor" do
        action [ :restart ]
      end
    end
  end
end

