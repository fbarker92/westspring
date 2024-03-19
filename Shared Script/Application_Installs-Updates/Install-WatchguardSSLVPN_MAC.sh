curl https://cdn.watchguard.com/SoftwareCenter/Files/MUVPN_SSL/12_10/WG-MVPN-SSL_12_10.dmg -o /tmp/watchguardd_ssl_vpn.dmg
hdiutil attach /tmp/watchguardd_ssl_vpn.dmg
installer -pkginfo -pkg "/Volumes/WatchGuard Mobile VPN/WatchGuard Mobile VPN with SSL Installer V683002.mpkg" -target /Applications
##NOT WORKING AT THE MOMENT (not sure if this is specific to this installer or a general issue)
hdiutil detach /tmp/watchguardd_ssl_vpn.dmg