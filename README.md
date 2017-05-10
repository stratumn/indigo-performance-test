# indigo-performance-test

ansible-galaxy install -r ansible/requirements.yml -p ansible/roles/

# Warning

To update the INDIGO_TESTS_PEM environment variable on Travis, one should transform the new private key so that:
- All new lines are replaced with \\n
- All spaces are escaped
