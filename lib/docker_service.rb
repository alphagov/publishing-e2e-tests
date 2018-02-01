require 'docker'
require 'docker/compose'

class DockerService
  def self.wait_for_healthy_services(services:)
    unhealthy_containers = get_services_containers(service_names: services)

    RetryWhileFalse.call(reload_seconds: 60, interval_seconds: 1) do
      unhealthy_containers = unhealthy_containers.reject { |service_container| container_is_healthy(service_container) }
      unhealthy_containers.empty?
    end

    unhealthy_container_names = unhealthy_containers.map(&:name)
    raise "Container(s) #{unhealthy_container_names.join(',')} were unhealthy after 60 seconds" if unhealthy_containers.any?
  end

  def self.get_services_containers(service_names:)
    docker_compose_labels = service_names.map { |service| "com.docker.compose.service=#{service}" }

    compose = Docker::Compose.new
    compose.ps.find_all do |container|
      (container.labels & docker_compose_labels).any?
    end
  end

  def self.container_is_healthy(container)
    container_state = Docker::Container.get(container.id).json["State"]
    health = container_state["Health"]
    container_state["Status"] == "running" && (health.nil? || health["Status"] == "healthy")
  end
end
