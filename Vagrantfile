require 'yaml'

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version '>= 1.6.0'
VAGRANTFILE_API_VERSION = '2'.freeze

PRIVATE_KEY_PATH = 'indigotests.pem'.freeze
NETWORK_SIZE = 2

File.open(PRIVATE_KEY_PATH, 'w') do |f|
  f.write(ENV['INDIGO_TESTS_PEM'].split('\n').join("\n"))
end

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  keys = YAML.load(IO.read('keys.yml'))

  1.upto(NETWORK_SIZE) do |i|
    name = "indigo-tests-#{i}"

    config.vm.define name do |srv|
      srv.vm.box = 'aws-dummy'

      srv.vm.provider 'aws' do |aws, override|
        # Read AWS authentication information from environment variables
        aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
        aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']

        # Specify SSH keypair to use
        aws.keypair_name = 'indigo.tests'

        # Specify region, AMI ID, and security group(s)
        aws.region = 'eu-west-1'
        # Ubuntu 16.04
        aws.ami = 'ami-405f7226'
        aws.security_groups = ['sg-25e3ad5c']
        aws.subnet_id = 'subnet-afa941e6'
        aws.associate_public_ip = true
        aws.terminate_on_shutdown = true

        # Specify username and private key path
        override.ssh.username = 'ubuntu'
        override.ssh.private_key_path = PRIVATE_KEY_PATH

        aws.tags = keys[i].merge(
          Name: name,
          Type: 'indigo-tests'
        )
      end
    end
  end
end
