require_relative "../docker_service"

namespace :docker do
  task :wait_for_dbs do
    DockerService.wait_for_healthy_services(services: %w(elasticsearch mongo mysql postgres redis))
  end

  task :wait_for_rabbitmq do
    DockerService.wait_for_healthy_services(services: %w(rabbitmq))
  end

  task :wait_for_publishing_api do
    DockerService.wait_for_healthy_services(services: %w(publishing-api))
  end

  task :wait_for_whitehall_admin do
    DockerService.wait_for_healthy_services(services: %w(whitehall-admin), reload_seconds: 180)
  end

  task :wait_for_apps do
    DockerService.wait_for_healthy_services(except: %w(publishing-e2e-tests))
  end

  task :remove_built_app_images do
    removed_images = DockerService.remove_built_app_images
    puts "Removed #{removed_images.join(',')}" unless removed_images.empty?
  end
end
