require 'rbnacl/libsodium'
require 'digest'
require 'yaml'

MAX_NETWORK_SIZE = 200

# Functions that help generating tendermint creds
module Crypto
  # PREFIX comes from the way tendermint serializes public keys
  PREFIX = '010120'.freeze

  def self.generate_tendermint_keys
    s1 = RbNaCl::SigningKey.generate
    s2 = RbNaCl::SigningKey.generate

    {
      address: to_address(s1.verify_key),
      public_key: to_hex(s1.verify_key),
      private_key: to_hex(s1) + to_hex(s2)
    }
  end

  def self.to_hex(binary_string)
    binary_string.to_bytes.unpack('H*').first
  end

  def self.to_address(binary_string)
    Digest::RMD160.hexdigest([(PREFIX + to_hex(binary_string))].pack('H*'))
  end
end

keys = 1.upto(MAX_NETWORK_SIZE).map do
  Crypto.generate_tendermint_keys
end

File.open('keys.yml', 'w') { |f| f.write(keys.to_yaml) }
