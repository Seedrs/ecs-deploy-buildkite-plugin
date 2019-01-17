#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Uncomment to enable stub debugging
#export AWS_STUB_DEBUG=/dev/tty

@test "deploys a service and waits for desired state" {
  export BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER="my-cluster"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE="my-service"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_REGION="eu-west-1"

  stub aws \
    "ecs update-service --cluster my-cluster --service my-service --force-new-deployment --region eu-west-1 : cat tests/response.json" \
    "ecs wait services-stable --cluster my-cluster --services my-service --region eu-west-1 : echo ok"

  run $PWD/hooks/command

  assert_output --partial "--- :ecs: Deploying my-service"
  assert_output --partial "--- :ecs: Waiting for my-service desired service state"
  assert_output --partial "--- :ecs: Service my-service is up :rocket:"

  assert_success
  unstub aws
}

@test "missing required parameters" {
  run $PWD/hooks/command

  assert_output --partial "Missing BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER or BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE"
}

@test "cluster not found" {
  export BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER="my-cluster"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE="my-service"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_REGION="eu-west-1"

  stub aws \
    "ecs update-service --cluster my-cluster --service my-service --force-new-deployment --region eu-west-1 : echo 'An error occurred (ClusterNotFoundException) when calling the UpdateService operation: Cluster not found.'"

  run $PWD/hooks/command

  assert_output --partial "ClusterNotFoundException"

}

@test "service not found" {
  export BUILDKITE_PLUGIN_ECS_DEPLOY_CLUSTER="my-cluster"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_SERVICE="my-service"
  export BUILDKITE_PLUGIN_ECS_DEPLOY_REGION="eu-west-1"

  stub aws \
    "ecs update-service --cluster my-cluster --service my-service --force-new-deployment --region eu-west-1 : echo 'An error occurred (ServiceNotFoundException) when calling the UpdateService operation:'"

  run $PWD/hooks/command

  assert_output --partial "ServiceNotFoundException"

}
