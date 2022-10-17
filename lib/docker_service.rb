require "docker"

class DockerService
  def self.wait_for_healthy_services(services: [], except: [], reload_seconds: 60, interval_seconds: 10)
    container_ids = service_container_ids(only: services, except:)
    unhealthy_containers = []

    RetryWhileFalse.call(reload_seconds:, interval_seconds:) do
      container_ids.reject! { |_, id| container_is_healthy?(id) }
      unhealthy_containers = container_ids.keys
      unhealthy_containers.empty?
    end

    raise "Container(s) #{unhealthy_containers.join(',')} were unhealthy after 60 seconds" if unhealthy_containers.any?
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

  def self.service_container_ids(only:, except:)
    output = `docker-compose ps --services`
    raise "Failed to check docker compose services" unless $CHILD_STATUS.success?

    service_names = output.split("\n")

    unknown_services = (only + except) - service_names
    raise "Unknown services: #{unknown_services.join(',')}" if unknown_services.any?

    service_names.select! { |name| only.include?(name) } unless only.empty?
    service_names.reject! { |name| except.include?(name) } unless except.empty?

    service_names.each_with_object({}) do |name, memo|
      memo[name] = `docker-compose ps -q #{name}`.chomp
      raise "Failed to determine a container id for #{name}" unless $CHILD_STATUS.success?
    end
  end

  def self.container_is_healthy?(container_id)
    container_state = Docker::Container.get(container_id).json["State"]
    health = container_state["Health"]
    container_state["Status"] == "running" && (health.nil? || health["Status"] == "healthy")
  end
end
