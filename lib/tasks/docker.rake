require_relative "../docker_service"

namespace :docker do
  task :wait_for_dbs do
    DockerService.wait_for_healthy_services(services: %w(elasticsearch mongo mysql postgres))
  end

  task :wait_for_rabbitmq do
    DockerService.wait_for_healthy_services(services: %w(rabbitmq))
  end

  task :wait_for_publishing_api do
    DockerService.wait_for_healthy_services(services: %w(publishing-api redis))
  end

  task :wait_for_whitehall_admin do
    DockerService.wait_for_healthy_services(services: %w(whitehall-admin))
  end

  task :wait_for_apps do
    DockerService.wait_for_healthy_services(except: %w(publishing-e2e-tests))
  end
end
