package arodenyupgradeconfig
import future.keywords.in

violation[{"msg": msg}] {
    input.review.operation in ["UPDATE"]
    name := input.review.object.metadata.name
    regex.match("^.+(-master|-worker|-master-.+|-worker-.+|-kubelet|-container-runtime|-aro-.+|-ssh|-generated-.+)$", name)
    msg := "Modify UpgradeConfig is not allowed"

    ## Check user type
    not is_exempted_account(input.review)
    userinfo := get_user_info(input.review)

    ## Check pull-secret
    ns := input.review.object.metadata.namespace

    ## If regular user and
    ## has NO cloud.openshift.com entry in openshift-config/pull-secret Secret
    ## ALLOW EDITING

    ## If regular user and 
    ## HAS cloud.openshift.com entry in openshift-config/pull-secret Secret
    ## NOT ALLOWED

}
