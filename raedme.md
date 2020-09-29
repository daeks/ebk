# needed to persist filebeat tracking data :
 - "filebeat_data:/usr/share/filebeat/data:rw"
# needed to access all docker logs (read only) :
 - "/var/lib/docker/containers:/usr/share/docker/data:ro"
# needed to access additional informations about containers
 - "/var/run/docker.sock:/var/run/docker.sock"

volumes:
# create a persistent volume for Filebeat
  filebeat_data:
