## Start - Inserted by CoreOS-Vagrant Kubernetes Cluster App
# Automatically set the discovery token on 'vagrant up'
#
if File.exists?('user-data') && ARGV[0].eql?('up')
  require 'open-uri'
  require 'yaml'

  token = open('https://discovery.etcd.io/new').read

  data = YAML.load(IO.readlines('user-data')[1..-1].join)
  data['coreos']['etcd']['discovery'] = token

  yaml = YAML.dump(data)
  File.open('user-data', 'w') { |file| file.write("#cloud-config\n\n#{yaml}") }
end
#
## End - Inserted by CoreOS-Vagrant Kubernetes Cluster App
