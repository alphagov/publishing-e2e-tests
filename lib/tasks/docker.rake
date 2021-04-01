require_relative "../docker_service"

namespace :docker do
  desc "Wait until database containers are indicating they are healthy"
  task :wait_for_dbs do
    DockerService.wait_for_healthy_services(services: %w[elasticsearch6 mongo mongo-2.6 mysql postgres redis])
  end

  desc "Wait for the RabbitMQ container to indicate it is healthy"
  task :wait_for_rabbitmq do
    DockerService.wait_for_healthy_services(services: %w[rabbitmq])
  end

  desc "Wait for the Publishing API container to indicate it is healthy"
  task :wait_for_publishing_api do
    DockerService.wait_for_healthy_services(services: %w[publishing-api])
  end

  desc "Wait for the Whitheall Admin container to indicate it is healthy"
  task :wait_for_whitehall_admin do
    DockerService.wait_for_healthy_services(services: %w[whitehall-admin], reload_seconds: 180)
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
