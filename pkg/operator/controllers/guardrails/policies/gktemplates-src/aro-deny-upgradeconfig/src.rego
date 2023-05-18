package arodenyupgradeconfig
import future.keywords.in

violation[{"msg": msg}] {
    input.review.operation in ["CREATE", "UPDATE", "DELETE"]
    name := input.review.object.metadata.name

    ## Check user type
    not is_exempted_account(input.review)

    ## Check pull-secret
    ## ns := input.review.object.metadata.namespace

    ## If regular user and
    ## has NO cloud.openshift.com entry in openshift-config/pull-secret Secret
    ## ALLOW EDITING
    secret := data.kubernetes.secret.

    ## If regular user and 
    ## HAS cloud.openshift.com entry in openshift-config/pull-secret Secret
    ## NOT ALLOWED

    msg := "Modifying the UpgradeConfig is not allowed for regular users. This can include creating, deleting, and updating UpgradeConfig."
}
