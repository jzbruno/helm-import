# helm-import

## Overview

A Helm plugin to import existing Kubernetes resources so they can be managed by a Helm chart. The use case is to allow Helm to manage resources that already exist without the need to delete and recreate them. Currently the plugin updates the following on every found after running the template command on the chart.

* Annotations
  * meta.helm.sh/release-name=RELEASE_NAME
  * meta.helm.sh/release-namespace=NAMESPACE
* Labels
  * app.kubernetes.io/managed-by=Helm

**Note: We are using the helm template command and piping the output to kubectl. This means we cannot check if the resource already exists before adding the annotations and labels and must ignore errors. You must look at the output of the command to see if all resources were annotated and labelled properly. This allows the plugin to handle the use case where the chart will create a new resource as well as take over management of existing resources.**

## Install

```sh
helm plugin install https://github.com/jzbruno/helm-import/
```

## Usage

```sh
helm import RELEASE_NAME CHART [args ...]
```

## Test

This repo has an example chart that can be used for testing.

1. Create a Kubernetes deployment and service

    ```sh
    kubectl create ns test
    kubectl -n test apply -f ./charts/test/templates/deployment.yaml
    ```

2. Try to install the Helm chart

    ```sh
    helm upgrade --install test ./charts/test -n test
    ```

    You should see an error like

    ```sh
    Release "test" does not exist. Installing it now.
    Error: rendered manifests contain a resource that already exists. Unable to continue with install: Service "test" in namespace "test" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "test"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "test"
    ```

3. Run the import plugin

    ```sh
    helm import test ./charts/test -n test
    ```

4. Run the install again

    ```sh
    helm upgrade --install test ./charts/test -n test
    ```

    Now you should see success

    ```sh
    Release "test" does not exist. Installing it now.
    NAME: test
    LAST DEPLOYED: Wed Nov 16 08:43:04 2022
    NAMESPACE: test
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    ```

5. Cleanup

    ```sh
    helm uninstall -n test test
    ```
