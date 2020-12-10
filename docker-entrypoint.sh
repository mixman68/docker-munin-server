#!/bin/bash
mkdir -p /var/log/munin/ \
    && chown -R munin:munin /var/log/munin/

mkdir -p /var/lib/munin/ \
    && chown -R munin:munin /var/lib/munin/

#On fait un coup de munin-cron pour générer les graph
su - munin --shell=/bin/bash munin-cron 2>&1 | grep "There is nothing to do here"
[ $? == 0 ] && {
    #Rien est défini, on démarre un noeud local pour le test
    munin-node &
    su - munin --shell=/bin/bash munin-cron
}

exec "$@"