#!/bin/bash

_DEFAULT_reference_hosts=/etc/hosts
_DEFAULT_reference_hostname=/etc/hosts
_DEFAULT_domain_name=localdomain
_DEFAULT_munin_clients_conf=munin-winroll-clients.conf

[ -z "$SETCOLOR_SUCCESS" ] && SETCOLOR_SUCCESS="echo -en \\033[1;32m"
[ -z "$SETCOLOR_FAILURE" ] && SETCOLOR_FAILURE="echo -en \\033[1;31m"
[ -z "$SETCOLOR_WARNING" ] && SETCOLOR_WARNING="echo -en \\033[1;33m"
[ -z "$SETCOLOR_NORMAL"  ] && SETCOLOR_NORMAL="echo -en \\033[0;39m"

####
# Main :
####

if [ -z "$(which munin-cron 2>/dev/null)" ] ; then 
	$SETCOLOR_WARNING; echo -n "No Munin installed yet, do you want to keep going ? [N/y]"; $SETCOLOR_NORMAL; read _answer
	[ "$_answer" != "y" ] && exit 2 ;
fi


[ -x /opt/drbl/bin/get-client-ip-list ] && [ -n "$(/opt/drbl/bin/get-client-ip-list)" ] && ip_list="$(/opt/drbl/bin/get-client-ip-list)"

# get ip list
if [ -n "$ip_list" ] ; then
	$SETCOLOR_WARNING; echo -n "Get ip list from DRBL server [Y/n]"; $SETCOLOR_NORMAL; read _answer
	[ "$_answer" = "n" ] && ip_list=
fi

if [ -z "$ip_list" ] ; then
	until [ -e "$_reference_file" ] 
	do 
		_reference_file=
		$SETCOLOR_WARNING; echo -n "File path includes ip/hostname list [$_DEFAULT_reference_hosts]"; $SETCOLOR_NORMAL; read _reference_file
		[ -z "$_reference_file" ] && _reference_file=$_DEFAULT_reference_hosts
	done
	echo "Parse ip list from '$_reference_file'...";
	ip_list="$(awk '$1~/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/  && $1 !~/^127\./ {print $1}' $_reference_file)"
fi

# get domain name
domain_name="$(hostname -d)"
[ -z "$domain_name" ] && domain_name=$_DEFAULT_domain_name
$SETCOLOR_WARNING; echo -n "Domain name [$domain_name]"; $SETCOLOR_NORMAL; read _answer
[ -n "$_answer" ] && domain_name=$_answer
echo "Set domain name as : $domain_name ..."

# get display name 
get_host_from=$_DEFAULT_munin_clients_conf
$SETCOLOR_WARNING; echo -n "Get clients hostname via Munin service ? Default from local $_DEFAULT_reference_hostname  [N/y]"; $SETCOLOR_NORMAL; read _answer
[ "$_answer" = "y" ] && get_host_from=Munin

$SETCOLOR_WARNING; echo -n "Still to keep the record if get hostname fail (to use ip as hostname) [N/y]"; $SETCOLOR_NORMAL; read _answer
[ "$_answer" = "y" ] && _allow_get_name_fail=y

if [ "$get_host_from" = "Munin" ] ; then
	$SETCOLOR_WARNING	
	echo "Please make sure clients' Munin daemon is running." 
	$SETCOLOR_NORMAL
	echo "[Enter] to go !!" ; read
fi


[ -e "$_DEFAULT_munin_clients_conf" ] && rm $_DEFAULT_munin_clients_conf
i=0
for ip in $ip_list; do
	echo -n "get hostname of '$ip' :"
	hostname=
	if [ "$get_host_from" = "Munin" ] ; then
		#echo "perl -I ./cpan get_telent_result.pl -c 'nodes' $ip"		
		hostname="$(perl -I ./cpan get_telent_result.pl -c 'nodes' $ip 2>/dev/null)"
		if [ -z "$hostname"  && -z "$_allow_get_name_fail" ] ; then
			echo "No respondence from $ip !! Skip this ... " 
		fi
	else
		hostname="$(awk "\$1 == \"$ip\" {print \$2}" $_DEFAULT_reference_hostname)"
		if [ -z "$hostname"  -a -z "$_allow_get_name_fail" ] ; then
			echo "No match hostname !! Skip this ... " 
		fi
	fi

	[ -z "$hostname" -a "$_allow_get_name_fail" = "y" ] && hostname="$(echo $ip | tr '.' '-')"

	if [ -n "$hostname" ] ; then
		i=$[i + 1]
		echo "$hostname"
		cat >> $_DEFAULT_munin_clients_conf << EOF
## written by gen_munin_clients_conf.sh
[$hostname.$domain_name]
	address $ip
	use_node_name yes

EOF
	fi
done

$SETCOLOR_WARNING
echo "Total $i record(s) done in '$_DEFAULT_munin_clients_conf' "
echo "Please copy the file into correct folder for Munin (ex: /etc/munin/munin-conf.d) then restart munin daemon (ex: $ sudo -u munin munin-cron)"
$SETCOLOR_NORMAL

exit 0;






