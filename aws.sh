# This file is sourced in launching shell to make it easier to launch another
# shell with configured ssh-agent sourcing aws_ssh_agent.sh

export AWS_SECRET_ACCESS_KEY=XXX
export AWS_ACCESS_KEY_ID=XXX

if [ `basename $SHELL` = "zsh" ]; then
    unsetopt noclobber
fi

ldir=`dirname $0`
ssh-agent > $ldir/aws_ssh_agent.sh
source $ldir/aws_ssh_agent.sh
ssh-add $ldir/indigo_tests.pem
