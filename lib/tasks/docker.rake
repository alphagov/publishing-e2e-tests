require_relative "../docker_service"

namespace :docker do
  desc "Wait for services to be healthy"
  task :wait_for, [:services, :reload_seconds] do |_task, args|
    args.with_defaults(reload_seconds: 60)
    services = args[:services].split(" ")
    DockerService.wait_for_healthy_services(services: services, reload_seconds: args[:reload_seconds].to_i)
  end

  desc "Wait until database containers are indicating they are healthy"
  task :wait_for_dbs do
    DockerService.wait_for_healthy_services(services: %w[elasticsearch6 mongo-2.6 mongo-3.6 mysql postgres redis])
  end

  desc "Wait for all apps to indicate they are healthy"
  task :wait_for_apps do
    DockerService.wait_for_healthy_services(except: %w[publishing-e2e-tests])
  end

  desc "Remove images built locally for this run"
  task :remove_built_app_images do
    removed_images = DockerService.remove_built_app_images
    puts "Removed #{removed_images.join(',')}" unless removed_images.empty?
  end
end
