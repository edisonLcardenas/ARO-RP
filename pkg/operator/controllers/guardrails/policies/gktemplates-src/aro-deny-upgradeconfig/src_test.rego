package arodenyupgradeconfig

test_input_allowed_regularuser_upgradeconfig {
  input := { "review": fake_upgradeconfig("basic-user","test","UPDATE") }
  results := violation with input as input
  count(results) == 0
}

test_input_disallowed_regularuser_upgradeconfig {
  input := { "review": fake_upgradeconfig("basic-user","test","UPDATE") }
  results := violation with input as input
  count(results) == 1
}

test_input_allowed_systemuser_upgradeconfig {
  input := { "review": fake_upgradeconfig("system:admin","test","UPDATE") }
  results := violation with input as input
  count(results) == 0
}

test_delete_allowed_regularuser_upgradeconfig {
  input := { "review": fake_upgradeconfig("basic-user","test","DELETE") }
  results := violation with input as input
  count(results) == 0
}

test_delete_disallowed_regularuser_upgradeconfig {
  input := { "review": fake_upgradeconfig("basic-user","test","DELETE") }
  results := violation with input as input
  count(results) == 1
}

test_delete_allowed_systemuser_upgradeconfig {
  input := { "review": fake_upgradeconfig("system:admin","test","DELETE") }
  results := violation with input as input
  count(results) == 0
}

test_create_allowed_regularuser_upgradeconfig {
  input := { "review": fake_upgradeconfig("basic-user","test","CREATE") }
  results := violation with input as input
  count(results) == 0
}

test_create_disallowed_regularuser_upgradeconfig {
  input := { "review": fake_upgradeconfig("basic-user","test","CREATE") }
  results := violation with input as input
  count(results) == 1
}

test_create_allowed_systemuser_upgradeconfig {
  input := { "review": fake_upgradeconfig("system:admin","test","CREATE") }
  results := violation with input as input
  count(results) == 0
}

fake_upgradeconfig(group, username, operation) = output {
  output = {
    "object": {
        "apiVersion": "upgrade.managed.openshift.io/v1alpha1",
        "kind": "UpgradeConfig",
        "metadata": {
            "creationTimestamp": "2024-05-18T01:01:27Z",
            "generation": 2,
            "name": "managed-upgrade-config",
            "namespace": "openshift-managed-upgrade-operator",
            "resourceVersion": "60055",
            "uid": "236240df-2438-4afb-b9de-893f24a446b7"
        },
        "spec": {
            "PDBForceDrainTimeout": 60,
            "desired": {
                "channel": "stable-4.10",
                "version": "4.10.55"
            },
            "type": "ARO",
            "upgradeAt": "2023-05-18T07:56:00Z"
        },
    },
    "operation": operation,
    "userInfo":{
       "groups":[
          group
       ],
       "username": username # "system:admin"
    }
  }
}