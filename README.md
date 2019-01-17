# ECS Deploy Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/plugins) to deploy ECS services.

Credentials for the command need to be added to the environment. You can use
another plugin to assume a specifc role (e.g [aws-assume-role-buildkite-plugin](https://github.com/Seedrs/aws-assume-role-buildkite-plugin))

This plugin will deploy a service without registering a new task definition. It will
force a new deploy using the current task definition. It assumes the task definition
configures its docker images tag has always being the latest tag.

```bash
aws ecs update-service --cluster <cluster-name> --service <service-name> --force-new-deployment
```

## Example

```yml
steps:
  - plugins:
      - seedrs/ecs-deploy#v0.1.0:
          cluster: "production-cluster-name"
          service: "production-service-name"
```

## Options

### `cluster`

The name of the ECS cluster.

### `service`

The service name you which to deploy.

### `region` (optional)

The AWS region where the service is deployed. It defaults to `eu-west-1`.
Alternatively, you could specify `AWS_DEFAULT_REGION` in your environment.

## Developing

To run the tests:

```bash
docker-compose run --rm tests
```

## License

MIT (see [LICENSE](LICENSE))
