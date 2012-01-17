**********************
** Directory index  **
**********************

.
|-- cpan						| perl CPAN library for get_telent_result.pl usage
|-- gen_munin_clients_conf.sh	| Munin client collector script 
|-- get_telent_result.pl		| Get information from Munin clients
|-- README.txt					| readme file
|-- sample-hosts.txt			| ip-hostname mapping sample file
`-- sample-munin-winroll-clients.conf	| Munin server configuration sample (just for reference)

********************
**  Requirement   **
********************
Read "Server site" section on http://www.drbl-winroll.org/#config-monitor for detail of Munin server.
In short, server need these packages :apache2 munin munin-node . 

********************
**  How to use:   **
********************
Run ./gen_munin_clients_conf.sh and follow its instruction
The script would detect if the current environment is in DRBL Server or not.It would generate Munin clients configuration for server running. Then it would restart Munin server by default.


