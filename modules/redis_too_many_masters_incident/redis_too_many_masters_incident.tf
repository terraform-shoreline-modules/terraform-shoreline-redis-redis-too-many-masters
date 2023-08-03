resource "shoreline_notebook" "redis_too_many_masters_incident" {
  name       = "redis_too_many_masters_incident"
  data       = file("${path.module}/data/redis_too_many_masters_incident.json")
  depends_on = [shoreline_action.invoke_redis_cluster_health_check,shoreline_action.invoke_redis_cluster_node_reduction]
}

resource "shoreline_file" "redis_cluster_health_check" {
  name             = "redis_cluster_health_check"
  input_file       = "${path.module}/data/redis_cluster_health_check.sh"
  md5              = filemd5("${path.module}/data/redis_cluster_health_check.sh")
  description      = "Network connectivity issues between Redis nodes, causing nodes to become isolated and designate themselves as master nodes."
  destination_path = "/agent/scripts/redis_cluster_health_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "redis_cluster_node_reduction" {
  name             = "redis_cluster_node_reduction"
  input_file       = "${path.module}/data/redis_cluster_node_reduction.sh"
  md5              = filemd5("${path.module}/data/redis_cluster_node_reduction.sh")
  description      = "Reduce the number of master nodes in the Redis cluster to the recommended maximum, which varies based on the size and complexity of the system."
  destination_path = "/agent/scripts/redis_cluster_node_reduction.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_redis_cluster_health_check" {
  name        = "invoke_redis_cluster_health_check"
  description = "Network connectivity issues between Redis nodes, causing nodes to become isolated and designate themselves as master nodes."
  command     = "`chmod +x /agent/scripts/redis_cluster_health_check.sh && /agent/scripts/redis_cluster_health_check.sh`"
  params      = ["REDIS_CLUSTER_IP","REDIS_PORT"]
  file_deps   = ["redis_cluster_health_check"]
  enabled     = true
  depends_on  = [shoreline_file.redis_cluster_health_check]
}

resource "shoreline_action" "invoke_redis_cluster_node_reduction" {
  name        = "invoke_redis_cluster_node_reduction"
  description = "Reduce the number of master nodes in the Redis cluster to the recommended maximum, which varies based on the size and complexity of the system."
  command     = "`chmod +x /agent/scripts/redis_cluster_node_reduction.sh && /agent/scripts/redis_cluster_node_reduction.sh`"
  params      = ["REDIS_CLUSTER_NAME","MAX_NUMBER_OF_MASTERS"]
  file_deps   = ["redis_cluster_node_reduction"]
  enabled     = true
  depends_on  = [shoreline_file.redis_cluster_node_reduction]
}

