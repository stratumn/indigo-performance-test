# indigo-performance-test

## Development

```
# update ansible dependencies
ansible-galaxy install -r ansible/requirements.yml -p ansible/roles/
```

## Warning

To update the INDIGO_TESTS_PEM environment variable on Travis, one should transform the new private key so that:
- All new lines are replaced with \\n
- All spaces are escaped


## To enhance your own test environment
Sourcing script `aws.sh` generates a script named `aws_ssh_agent.sh`. This script sourced in another shell script set the ssh-agent environment variables to make easier connection on a node to read logs.
Think to update `aws.sh` with AWS access key

Two scripts are build over vagrant and ansible
1. `launch_gatling.sh`
  - This script
    - provides servers on cloud
    - installs indigo and other stuff on their
    - runs gatling to perform test
    - resiliates all servers
  - Help is available using `-h` option
```
Usage ./launch_gatling.sh [-AIGKh] [-S] [-d duration] [-r ratio] [-s network_size] [-l eth_limits]
Options:
  -d duration:     duration in minute (default is 1)
  -r ratio:        number of map creation per minute (default is 50)
  -s network_size: number of blockchain nodes (default is 2)
  -l eth_limits:  network limitation (see https://github.com/thombashi/tcconfig for options) (default is none)
  -A              disable VM allocation
  -I              disable install playbook
  -G              disable gatling playbook
  -K              disable VM deallocation
  -h              print this help
```
2. `meta_launch_gatling.sh`
  - This script is an example to orchestrate `launch_gatling.sh`
    - Provide and install _X_ servers
    - Launch several test with parameter changes
    - Resiliate _X_ servers