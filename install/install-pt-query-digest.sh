#!/bin/bash

if ! command -v pt-query-digest &> /dev/null
then
    wget https://downloads.percona.com/downloads/percona-toolkit/3.5.1/binary/debian/bullseye/x86_64/percona-toolkit_3.5.1-2.bullseye_amd64.deb
    sudo apt-get install libdbd-mysql-perl libdbi-perl libio-socket-ssl-perl libnet-ssleay-perl libterm-readkey-perl
    sudo dpkg -i percona-toolkit_3.0.10-1.xenial_amd64.deb
else
    echo "pt-query-digest is already installed."
fi
