require 'docker'
require 'docker/compose'

class DockerService
  def self.wait_for_healthy_services(services: [], except: [], reload_seconds: 60, interval_seconds: 10)
    unhealthy_containers = get_services_containers(only: services, except: except)

    RetryWhileFalse.call(reload_seconds: reload_seconds, interval_seconds: interval_seconds) do
      unhealthy_containers = unhealthy_containers.reject { |service_container| container_is_healthy(service_container) }
      unhealthy_containers.empty?
    end

    unhealthy_container_names = unhealthy_containers.map(&:name)
    raise "Container(s) #{unhealthy_container_names.join(',')} were unhealthy after 60 seconds" if unhealthy_containers.any?
  end

  def self.remove_built_app_images
    built_app_images.map do |image|
      image.remove
      image.info["RepoTags"].first
    end
  end

  def self.built_app_images
    # A repo digest is a unique identifier for an image made up of the tag name + hash
    # e.g. govuk/publishing-api@sha256:a5e459c5e6f855a4ce3684d333312848768676a23651ad1a46cefe7e4c64b11a
    # Images are only assigned digests after being pushed to a registry.
    # If an image doesn't have a digest, it must have been built locally.
    app_images.reject do |image|
      image.info["RepoDigests"]
    end
  end

  def self.app_images
    Docker::Image.all.select do |image|
      Array(image.info["RepoTags"]).any? do |tag|
        tag.start_with?("govuk/")
      end
    end
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
