### Docker image for ci/cd

Based on docker, includes kubectl and helm, python3 and npm

#### to build image

```shell
docker build . -t nikitosnik/ci-builder:v0.1.0
docker tag nikitosnik/ci-builder:v0.1.0 nikitosnik/ci-builder:latest
docker push nikitosnik/ci-builder:v0.1.0 && docker push nikitosnik/ci-builder:latest
```

#### kubeconfig path:

```shell
/config/.kube/config
```

#### cmd to run locally:

```shell
docker run -v /home/nikita/.kube:/config/.kube --rm -it nikitosnik/ci-builder:latest sh
```

