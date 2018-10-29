require 'rake'
require 'rspec/core/rake_task'
require 'shellwords'

task :spec    => ['spec:all', 'bats:all']
task :default => :spec

namespace :spec do
  targets = []
  Dir.glob('./spec/*').each do |dir|
    next unless File.directory?(dir)
    targets << File.basename(dir)
  end

  task :all     => targets
  task :default => :all

  targets.each do |target|
    desc "Run serverspec tests to #{target}"
    RSpec::Core::RakeTask.new(target.to_sym) do |t|
      ENV['TARGET_HOST'] = target
      t.pattern = "spec/#{target}/*_spec.rb"
    end
  end
end

def get_stack_ident_parts(ident)
  return ident.split('-')
end

namespace :hive do

  desc "Build an image for a specific stack"
  task :build, [:stack_ident] => [:buildbase] do |task,args|
    puts "Building image for #{args[:stack_ident]}"
    product, environment = get_stack_ident_parts(args[:stack_ident])

    # Create a bespoke configuration for this stack_ident
    # TODO: All of it.

    # Produce a bespoke container image for that product and environment
    sh "docker build . -f Dockerfile.configured --build-arg PRODUCT=#{product} --build-arg ENVIRONMENT=#{environment} -t td-agent:#{product}.#{environment}"
    sh "docker tag td-agent:#{product}.#{environment} 728193454066.dkr.ecr.eu-west-1.amazonaws.com/td-agent:#{product}.#{environment}"
    sh "docker push 728193454066.dkr.ecr.eu-west-1.amazonaws.com/td-agent:#{product}.#{environment}"
  end

  desc "Build an image for all stacks"
  task :buildall do |task|
  stacks = %w(
    cb-dev
    cb-prod
    cb-usprod
    customersystems-dev
    hcam-dev
    hcam-prod
    hiveleak-dev
    hiveleak-prod
    honeycomb-beta
    honeycomb-dev
    honeycomb-prod
    honeycomb-staging
    ops-prod
  )
    stacks.each { |s| Rake::Task["hive:build"].execute(s) }
  end

  desc "Build the base image"
  task :buildbase do |task|
    puts "Building base image"
    sh "docker build . -f Dockerfile.base --no-cache -t td-agent"
    sh "docker tag td-agent:latest 728193454066.dkr.ecr.eu-west-1.amazonaws.com/td-agent:latest"
    sh "docker push 728193454066.dkr.ecr.eu-west-1.amazonaws.com/td-agent:latest"
  end
end

