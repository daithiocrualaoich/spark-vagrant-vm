directory 'target'

puppetfiles = FileList['modules/**/*']

task :default => "target/spark.box"

task :clean do
  sh 'vagrant destroy -f'
  sh "vagrant box remove spark || true"
  sh 'rm -fr target'
end

file "target/spark.box" => (['target'] + puppetfiles) do
  sh "vagrant destroy -f"
  sh "vagrant box remove spark || true"
  sh "vagrant up"
  sh "vagrant package --output target/spark.box"
  sh "vagrant destroy -f"
end

