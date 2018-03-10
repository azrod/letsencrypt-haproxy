#!/bin/bash
#
# Let'sEncrypt Generator for Haproxy
# Copyright (C) 2018 Mickael Stanislas
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
# Last Update : 20180310 - Version 1.0
#
# --- Variable -----------------------------------------------------------------
sendmail="false" # -- Send mail if error in execution script
#
# --- Mail config
emailaddress="contact@example.com" # -- mail address for error mail
#
# --- Temp Directory
dir="/tmp/letsencrypt-generator/" # -- directory temporary for certbot
#
# --- List domain
# Do not fill in the www
listdomain="example.com other-example.com" # -- List of domains separated by spaces (example.com other-example.com)
#
# ------------------------------------------------------------------------------

test -z $1 && __listdomain=${listdomain} || __listdomain=${1}

function send_mail_error {
  if test -n ${emailaddress} && [[ $sendmail == "true" ]] ; then
    cat ${dir}emailletsencrypt | mail -s "[LETSENCRYPT] certificate generation $1" $emailaddress
  fi
}

function test_config_haproxy {
  haproxy -c -f /etc/haproxy/haproxy.cfg >/dev/null 2>&1
  return $?
}

for dom in ${__listdomain} ; do

test -d $dir || mkdir -p $dir
test -f ${dir}emailletsencrypt

cat << EOF > ${dir}emailletsencrypt

Certificate generation for the domain $dom
DATE : $(date)
SERVER : $(hostname -f)

#---------- ERROR MESSAGE ----------#

EOF

certbot certonly --standalone \
		     -d ${dom} \
		     -d www.${dom} \
    	   --non-interactive --agree-tos \
    		 --email noreply@noreply.com \
         --http-01-port=8888 2>&1 >> ${dir}emailletsencrypt

if test $? -eq 0 ; then
  test ! -d /etc/haproxy/ssl/letsencrypt/${dom}/current/ && mkdir -p /etc/haproxy/ssl/letsencrypt/${dom}/current/
  test -f /etc/haproxy/ssl/letsencrypt/${dom}/current/${dom}.pem && rm -f /etc/haproxy/ssl/letsencrypt/${dom}/current/${dom}.pem
  cat /etc/letsencrypt/live/${dom}/fullchain.pem >> /etc/haproxy/ssl/letsencrypt/${dom}/current/${dom}.pem
  cat /etc/letsencrypt/live/${dom}/privkey.pem >> /etc/haproxy/ssl/letsencrypt/${dom}/current/${dom}.pem
  test -f /etc/haproxy/ssl/dhparam.pem && cat /etc/haproxy/ssl/dhparam.pem >> /etc/haproxy/ssl/letsencrypt/$dom/current/${dom}.pem
  test test_config_haproxy && /etc/init.d/haproxy reload || send_mail_error $dom
else
  send_mail_error $dom
fi

# REMOVE TEMP DIRECTORY
test -d ${dir} && rm -rf ${dir}

done
