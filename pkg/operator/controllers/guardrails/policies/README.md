# Gatekeeper Policy development and testing

## What's Gatekeeper
official doc https://open-policy-agent.github.io/gatekeeper/website/docs/

## Guardrails folder structures

There are several folders under guardrails:

* gktemplates - the Constraint Templates used by gatekeeper, which are generated through generate.sh, do *not* modify them.
* gkconstraints - the Constraints that are used by gatekeeper together with Constraint Templates.

* gktemplates-src - the rego src file for Constraint Templates, consumed by generate.sh
* scripts - generate.sh will combine src.rego and *.tmpl to form actual Constraint Templates under gktemplates. test.sh executes the rego tests under each gktemplates-src subfolder.
* staticresources - yaml resources for gatekeeper deployment

## Policy structure
Each policy contains 2 parts, [ConstraintTemplate](https://open-policy-agent.github.io/gatekeeper/website/docs/constrainttemplates/) and [Constraint](https://open-policy-agent.github.io/gatekeeper/website/docs/howto/#constraints)

ConstraintTemplate, ie,. gktemplate/\$TEMPLATE_NAME.yaml, is generated by policies/scripts/generate.sh, who combines the yaml part, ie,. the gktemplates-src/\$TEMPLATE_NAME/\$TEMPLATE_NAME.tmpl and rego program (gktemplates-src/\$TEMPLATE_NAME/src.rego).
please dont edit the ConstraintTemplate directly, just provide the corresponding $TEMPLATE_NAME.tmpl and src.rego, the generate.sh will produce the ConstraintTemplate file.

Constraint is manually created

## Create new policy

* Create a new subfolder for each new Constraint Template under gktemplates-src
* Create a tmpl file with unique and meaningful name in above subfolder, which contains everything except for the rego, example:

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: aroprivilegednamespace
  annotations:
    metadata.gatekeeper.sh/title: "Privileged Namespace"
    metadata.gatekeeper.sh/version: 1.0.0
    description: >-
      Disallows creating, updating or deleting resources in privileged namespaces.
      including, ["^kube.*|^openshift.*|^default$|^redhat.*|^com$|^io$|^in$"]
spec:
  crd:
    spec:
      names:
        kind: AROPrivilegedNamespace
      validation:
        # Schema for the `parameters` field
        openAPIV3Schema:
          type: object
          description: >-
            Disallows creating, updating or deleting resources in privileged namespaces.
            including, ["^kube.*|^openshift.*|^default$|^redhat.*|^com$|^io$|^in$"]
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
{{ file.Read "gktemplates-src/aro-deny-privileged-namespace/src.rego" | strings.Indent 8 | strings.TrimSuffix "\n" }}
```


* Create the src.rego file in the same folder, howto https://www.openpolicyagent.org/docs/latest/policy-language/, example:
```
package aroprivilegednamespace

violation[{"msg": msg, "details": {}}] {
  input_priv_namespace(input.review.object.metadata.namespace)
  msg := sprintf("Operation in privileged namespace %v is not allowed", [input.review.object.metadata.namespace])
}

input_priv_namespace(ns) {
  any([ns == "default",
  ns == "com",
  ns == "io",
  ns == "in",
  startswith(ns, "openshift"),
  startswith(ns, "kube"),
  startswith(ns, "redhat")])
}
```
* Create src_test.rego for unit tests in the same foler, which will be called by test.sh, howto https://www.openpolicyagent.org/docs/latest/policy-testing/, example:
```
package aroprivilegednamespace

test_input_allowed_ns {
  input := { "review": input_ns(input_allowed_ns) }
  results := violation with input as input
  count(results) == 0
}

test_input_disallowed_ns1 {
  input := { "review": input_review(input_disallowed_ns1) }
  results := violation with input as input
  count(results) == 1
}

input_ns(ns) = output {
  output = {
    "object": {
      "metadata": {
        "namespace": ns
      }
    }
  }
}

input_allowed_ns = "mytest"

input_disallowed_ns1 = "openshift-config"
```

* Create [Constraint](https://open-policy-agent.github.io/gatekeeper/website/docs/howto/#constraints) for the policy, example:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: AROPrivilegedNamespace
metadata:
  name: aro-privileged-namespace-deny
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Service",
        "Pod",
        "Deployment",
        "Namespace",
        "ReplicaSet",
        "StatefulSets",
        "DaemonSet",
        "Jobs",
        "CronJob",
        "ReplicationController",
        "Role",
        "ClusterRole",
        "roleBinding",
        "ClusterRoleBinding",
        "Secret",
        "ServiceAccount",
        "CustomResourceDefinition",
        "PodDisruptionBudget",
        "ResourceQuota",
        "PodSecurityPolicy"]
```

## Test the rego

* install opa cli, refer https://www.openpolicyagent.org/docs/v0.11.0/get-started/

* after _test.go is done, test it out, and fix the problem
  ```sh
  opa test *.rego [-v] #-v for verbose
  ```

## Generate the Constraint Templates

* install gomplate which is used by generate.sh, see https://docs.gomplate.ca/installing/

* execute generate.sh under policies, which will generate the acutal Constraint Templates under gktemplates folder, example:

  ```sh
  ARO-RP/pkg/operator/controllers/guardrails/policies$ ./scripts/generate.sh 
  Generating gktemplates/aro-deny-delete.yaml from gktemplates-src/aro-deny-delete/aro-deny-delete.tmpl
  Generating gktemplates/aro-deny-privileged-namespace.yaml from gktemplates-src/aro-deny-privileged-namespace/aro-deny-privileged-namespace.tmpl
  Generating gktemplates/aro-deny-labels.yaml from gktemplates-src/aro-deny-labels/aro-deny-labels.tmpl
  ```

## gator test

Create suite.yaml and testcases in gator-test folder under the folder created for the new policy, refer example below:

```yaml
kind: Suite
apiVersion: test.gatekeeper.sh/v1alpha1
metadata:
  name: privileged-namespace
tests:
- name: privileged-namespace
  template: ../../gktemplates/aro-deny-privileged-namespace.yaml
  constraint: ../../gkconstraints-test/aro-priv-ns-operations.yaml
  cases:
  - name: ns-allowed-pod
    object: gator-test/ns_allowed_pod.yaml
    assertions:
    - violations: no
  - name: ns-disallowed-pod
    object: gator-test/ns_disallowed_pod.yaml
    assertions:
    - violations: yes
      message: User test-user not allowed to operate in namespace openshift-config
  - name: ns-disallowed-deploy
    object: gator-test/ns_disallowed_deploy.yaml
    assertions:
    - violations: yes
      message: User test-user not allowed to operate in namespace openshift-config
```
gkconstraints-test here stores the target yaml files after expanding "{{.Enforcement}}" symbol.

gator tests ConstraintTemplate and Constraint together, items under cases keyword are test cases indicator, everyone pointing to a yaml file in gator-test, which provides test input for one scenario, example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: allowed
  namespace: test
spec:
  serviceAccountName: test-user
  containers:
    - name: test
      image: openpolicyagent/opa:0.9.2
      args:
        - "run"
        - "--server"
        - "--addr=localhost:8080"
      resources:
        limits:
          cpu: "100m"
          memory: "30Mi"
```
the assertions section is the expected result

gator test is done via cmd:

test.sh executes both opa test and gator verify
```sh
ARO-RP/pkg/operator/controllers/guardrails/policies$ ./scripts/test.sh
```

or below cmd after test.sh has been executed:
```sh
gator verify . [-v] #-v for verbose
```