 #!/bin/sh
 # -*- mode: shell-script; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 #
 # Copyright (C) 2018 Emc Logic.
 # Authored-by:  Fernando Luiz Cola <fernando.cola@emc-logic.com>
 #
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License version 2 as
 # published by the Free Software Foundation.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License along
 # with this program; if not, write to the Free Software Foundation, Inc.,
 # 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 #

PROGNAME="docker-backup-tool"
DATE=$(date +%F-%s)

usage()
{
    echo -e "\n $PROGNAME -b <volume-name>
    <volume-name>: docker volume to backup"
}

backup()
{
    docker run -v $VOLUME_NAME:/volume --rm loomchild/volume-backup backup - > $VOLUME_NAME-$DATE.tar.bz2
}

restore()
{
    if [ -n $file ]; then
        if [ -n $volume ]; then
            echo -e "Starting restore of $file to volume $volume"
            cat $file | docker run -i -v $volume:/volume --rm loomchild/volume-backup restore -
        fi
    else
        echo -e " Please "
    fi
}

stop_containers()
{
    echo -e "\n Stopping Containers"
    docker stop $(docker ps -a -q)
}


# get command line options
OLD_OPTIND=$OPTIND
while getopts "hb:r:v:" options
do
    case $options in
        h)
            usage
            $DATE
            #clean_up
            return 0
            ;;
        b)
            VOLUME_NAME=$OPTARG
            echo -e "Starting Backup of $VOLUME_NAME"
            stop_containers
            backup
            ;;
        r)
            file=$OPTARG
            stop_containers
            #restore ${array[0]} ${array[1]}
            restore_opt=true
            ;;
        v)
            volume=$OPTARG
            ;;
        ?)
            usage
            exit -1
            ;;
    esac
done

cat << EOF

Welcome to the Docker Volume Backup Tool

Learn more about Docker Volumes on:
https://docs.docker.com/storage/volumes/

EOF

if [ $restore_opt ]; then
    restore
fi

