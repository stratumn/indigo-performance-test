#!/bin/sh
ratio=50
duration=1
export INDIGO_ETH_LIMITS=""
export NETWORK_SIZE=2
disable_vm_allocation=0
disable_install_playbook=0
disable_gatling_playbook=0
disable_vm_kill=0

while getopts "r:d:s:l:AIGKh" option; do
    case $option in
        r)
            ratio=$OPTARG
            ;;
        d)
            duration=$OPTARG
            ;;
        s)
            NETWORK_SIZE=$OPTARG
            ;;
        l)
            INDIGO_ETH_LIMITS="$OPTARG"
            ;;
        A)
            disable_vm_allocation=1
            ;;
        I)
            disable_install_playbook=1
            ;;
        G)
            disable_gatling_playbook=1
            ;;
        K)
            disable_vm_kill=1
            ;;
        *)
            echo "Usage $0 [-AIGKh] [-S] [-d duration] [-r ratio] [-s network_size] [-l eth_limits]" 1>&2
            echo "Options:" 1>&2
            echo "  -d duration:     duration in minute (default is $duration)" 1>&2
            echo "  -r ratio:        number of map creation per minute (default is $ratio)" 1>&2
            echo "  -s network_size: number of blockchain nodes (default is $NETWORK_SIZE)" 1>&2
            echo "  -l eth_limits:  network limitation (see https://github.com/thombashi/tcconfig for options) (default is none)" 1>&2
            echo "  -A              disable VM allocation" 1>&2
            echo "  -I              disable install playbook" 1>&2
            echo "  -G              disable gatling playbook" 1>&2
            echo "  -K              disable VM deallocation" 1>&2
            echo "  -h              print this help" 1>&2
            exit 1
            ;;
    esac
done

# allocate AWS VMs
test $disable_vm_allocation -eq 1 || vagrant up

# install indigo
test $disable_install_playbook -eq 1 || ansible-playbook --inventory ansible/contrib/inventory/ec2.py --user ubuntu ansible/indigo-test.yml --private-key=indigo_tests.pem --limit "*_on_$NETWORK_SIZE"

if [ $disable_gatling_playbook -eq 0 ]; then
    # generate gatling scala commands
    gatling_command_file=simulations/indigo.scala
    tmpfile=`mktemp`
    sed "s/\(.*constantUsersPerSec\)([^)]*)\( during\)(.*)\(.*\)/\1($ratio)\2($duration minute)\3/" $gatling_command_file > $tmpfile
    mv $tmpfile $gatling_command_file

    # run gatling
    ansible-playbook --inventory ansible/contrib/inventory/ec2.py --user ubuntu ansible/run_gatling.yml --private-key=indigo_tests.pem --limit "*_on_$NETWORK_SIZE"

    # save report
    if [ $? -ne 130 ]; then
        now=`date +%Y%m%d_%H%M%S`
        restrictions=""
        if [ -n "$INDIGO_ETH_LIMITS" ]; then
            restrictions=`echo "$INDIGO_ETH_LIMITS" | sed 's/^-*/_/;s/ \{1,\}/_/g'`
        fi
        tarball_file_name=${now}_report_${ratio}_per_sec_during_${duration}_min_${NETWORK_SIZE}_nodes${restrictions}.tar.bz2
        tar jcf report_sav/${tarball_file_name} report
        echo "Saved report in ${tarball_file_name}"
        mkdir logs/${now} && mv logs/*.log logs/${now} && gzip logs/${now}/*.log
        echo "Saved logs in logs/${now}"
    fi
fi

# destroy AWS VMs
test $disable_vm_kill -eq 1 || vagrant destroy -f
