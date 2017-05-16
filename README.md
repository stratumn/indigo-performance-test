# indigo-performance-test

## Development

```
# update ansible dependencies
ansible-galaxy install -r ansible/requirements.yml -p ansible/roles/

# install jmeter
brew cask install java
brew install jmeter --with-plugins

# launch jmeter gui
open /usr/local/bin/jmeter
```

Install jmeter plugin manager from https://jmeter-plugins.org/wiki/PluginsManager/ and make sure Perfmon is installed

## Warning

To update the INDIGO_TESTS_PEM environment variable on Travis, one should transform the new private key so that:
- All new lines are replaced with \\n
- All spaces are escaped
