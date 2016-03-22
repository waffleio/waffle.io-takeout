## CentOS 7

CentOS 7 introduced using firewalld for firewall configuration, and there have been a lot of reports that Docker and firewalld aren't playing well together. Here's how to configure a CentOS 7 system to work with Waffle Takeout.

The goal: Open up ports 80, 443, 8800, 9880, and the range 3001-3009 for incoming connections, and allow all outgoing.

##### Disable firewalld, Enable iptables. 
Docker on CentOS doesn’t always play nice with firewalld, so we’ll rely on iptables (this is how CentOS <6 worked too).
http://serverfault.com/a/739465/344862

##### Configure the firewall rules

To just make sure nothing else is wrong, we can open everything up. Or, trust me and skip to the next section to configure it the right way.
```
# accept all incoming, allow all outgoing
$> iptables -P INPUT ACCEPT # change default to allow incoming (this is dangerous)
$> iptables -F # flush all other rules
$> iptables -P OUTPUT ACCEPT # change default to allow outgoing
$> iptables -L # list rules
$> service iptables save # save it!
```

The correct firewall rules, where only what we need is open:
```
$> iptables -P INPUT ACCEPT # allow is still the default for now
$> iptables -F # flush all other rules
$> iptables -A INPUT -i lo -j ACCEPT # allow connections to the local interface
$> iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$> iptables -A INPUT -p tcp --dport 22 -j ACCEPT # ssh
$> iptables -A INPUT -p tcp --dport 8800 -j ACCEPT # replicated
$> iptables -A INPUT -p tcp --dport 9880 -j ACCEPT # replicated
$> iptables -A INPUT -p tcp --dport 80 -j ACCEPT
$> iptables -A INPUT -p tcp --dport 443 -j ACCEPT
$> iptables -A INPUT -p tcp --dport 3001:3009 -j ACCEPT # waffle services
$> iptables -P INPUT DROP # change the default to drop, instead of accept
$> iptables -P FORWARD DROP # no forwarding either
$> iptables -P OUTPUT ACCEPT # allow all outbound
$> iptables -L -v # make sure it looks ok

# and save it!
$> service iptables save
```

##### Install Replicated
`curl -sSL https://get.replicated.com | sudo sh`

That should do it!

## VirtualBox

If trying out Waffle Takeout on a VirtualBox VM, here are a few gotchas:

- Choose a bridge network adapter so you can connect to the service in a browser outside the VM. Details: bridged network adapter, choose whichever interface is connected to the internet (wifi, for example). Explanation: https://www.virtualbox.org/manual/ch06.html
- Configure a static IP address. A bridge network on VirtualBox creates an internal DHCP, which means your IP might change from under you. Waffle Takeout doesn't like it when this happens, so it's best to configure your VM to use a static IP. [Here's a 7 min video for how to do that on CentOS 7](https://www.youtube.com/watch?v=gDXQY2dC8z4) (The video is a bit painful to watch, but it getes the job done).
