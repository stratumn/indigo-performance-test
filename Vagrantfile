require 'yaml'

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version '>= 1.6.0'
VAGRANTFILE_API_VERSION = '2'.freeze

PRIVATE_KEY_PATH = 'indigo_tests.pem'.freeze
NETWORK_SIZE = (ENV['NETWORK_SIZE'] || 2).to_i

unless File.exist?(PRIVATE_KEY_PATH)
  File.open(PRIVATE_KEY_PATH, 'w', 0o600) do |f|
    f.write(ENV['INDIGO_TESTS_PEM'].split('\n').join("\n"))
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  keys = YAML.load(IO.read('keys.yml'))
  name = "indigo_tests_controller_on_#{NETWORK_SIZE}"
  define_srv(config, name, Name: name, Type: 'indigo_tests_controller')

  NETWORK_SIZE.times do |i|
    name = "indigo_tests_#{i}_on_#{NETWORK_SIZE}"
    tags = keys[i].merge(
      Name: name,
      Type: 'indigo_tests'
    )
    define_srv(config, name, tags)
  end
end

def define_srv(config, name, tags)
  config.vm.define name do |srv|
    srv.vm.box = 'aws-dummy'

    config.vm.synced_folder(
      '.',
      '/vagrant',
      type: 'rsync',
      rsync__exclude: ['.git/', 'agent', '.rubocop.yml', '.travis.yml',
                       'dummy.box', 'LICENSE', '*.log', 'ansible',
                       'report/', 'report_sav/', 'logs/']
    )

    srv.vm.provider 'aws' do |aws, override|
      # Read AWS authentication information from environment variables
      aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
      aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']

      aws.keypair_name = 'indigo.tests'
      aws.region = 'eu-west-1'
      aws.instance_type = 'm3.medium'
      aws.ami = 'ami-405f7226' # Ubuntu 16.04
      aws.security_groups = ['sg-25e3ad5c']
      aws.subnet_id = 'subnet-afa941e6'
      aws.terminate_on_shutdown = true
      aws.associate_public_ip = true

      # Specify username and private key path
      override.ssh.username = 'ubuntu'
      override.ssh.private_key_path = PRIVATE_KEY_PATH

      aws.tags = tags
    end
  end
end
