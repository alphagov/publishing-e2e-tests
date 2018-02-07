require 'docker'
require 'docker/compose'

class DockerService
  def self.wait_for_healthy_services(services: [], except: [])
    unhealthy_containers = get_services_containers(only: services, except: except)

    RetryWhileFalse.call(reload_seconds: 60, interval_seconds: 1) do
      unhealthy_containers = unhealthy_containers.reject { |service_container| container_is_healthy(service_container) }
      unhealthy_containers.empty?
    end

    unhealthy_container_names = unhealthy_containers.map(&:name)
    raise "Container(s) #{unhealthy_container_names.join(',')} were unhealthy after 60 seconds" if unhealthy_containers.any?
  end

  def self.get_services_containers(only:, except:)
    containers = Docker::Compose.new.ps

    unless only.empty?
      only_labels = docker_compose_labels(only)
      containers = containers.find_all do |container|
        (container.labels & only_labels).any?
      end
    end

    unless except.empty?
      except_labels = docker_compose_labels(except)
      containers = containers.find_all do |container|
        (container.labels & except_labels).empty?
      end
    end

    containers
  end

  def self.docker_compose_labels(services)
    services.map { |service| "com.docker.compose.service=#{service}" }
  end

  def self.container_is_healthy(container)
    container_state = Docker::Container.get(container.id).json["State"]
    health = container_state["Health"]
    container_state["Status"] == "running" && (health.nil? || health["Status"] == "healthy")
  end
end
