die() { echo "Error: $@" 1>&2 ; exit 1; }

kcadm=$JBOSS_HOME/bin/kcadm.sh
output=/var/opt/keycloak
www=/var/opt/www

baseurl=http://keycloak:8080

realm=$KC_REALM_NAME
[ -z "$realm" ] && die "Realm not set. Beware to call this script with Make!"

#########################################
# Login
#########################################
$kcadm config credentials --server $baseurl/auth --realm master --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
[ $? = 0 ] || die "Unable to login"

#########################################
# Test realm
#########################################
$kcadm get realms/$realm 1> /dev/null
if [ $? = 0 ]
then
  echo "Realm '$realm' already exists. Abort configuration."
  exit 0
fi

#########################################
# Clean output dir
#########################################
rm $output/{*.pem,keycloak.json} 2> /dev/null
[ $? = 0 ] && echo "Output directory cleaned!"

#########################################
# Create realm
#########################################
realm_id=$($kcadm create realms \
  -s realm=$realm \
  -s enabled=true -i)
[ $? = 0 ] || die "Unable to create realm"

echo "Realm '$realm_id' created."

$kcadm update realms/$realm \
  -s registrationAllowed=true \
  -s rememberMe=true
[ $? = 0 ] || die "Unable to configure realm"
echo "Realm '$realm_id' configured."

#########################################
# Create client
#########################################
client_id=$($kcadm create clients \
  -r $realm \
  -s clientId=$KC_CLIENT_ID \
  -s publicClient=true \
  -s baseUrl=$KC_CLIENT_BASEURL \
  -s "redirectUris=[\"$KC_CLIENT_BASEURL/*\"]" \
  -s "webOrigins=[\"+\"]" \
  -i)
[ $? = 0 ] || die "Unable to create client"

echo "Client '$client_id' created."

#########################################
# Create roles
#########################################
$kcadm create roles -r $realm \
  -s name=user \
  -s 'description=Regular user with limited set of permissions'
[ $? = 0 ] || die "Unable to create 'user' role"

$kcadm create roles -r $realm \
  -s name=admin \
  -s 'description=Regular admin with full set of permissions'
[ $? = 0 ] || die "Unable to create 'admin' role"

echo "Roles created."

#########################################
# Create users
#########################################
admin_uid=$($kcadm create users -r $realm \
  -s username=$KC_REALM_USERNAME \
  -s enabled=true \
  -i)
[ $? = 0 ] || die "Unable to create 'admin' user"

$kcadm update users/$admin_uid/reset-password \
  -r $realm \
  -s type=password \
  -s value=$KC_REALM_PASSWORD \
  -s temporary=true \
  -n
[ $? = 0 ] || die "Unable to set 'admin' password"

echo "Users created."

#########################################
# Create groups
#########################################
admin_gid=$($kcadm create groups -r $realm \
  -s name=Admin \
  -i)
[ $? = 0 ] || die "Unable to create 'Admin' group"

$kcadm create groups -r $realm -s name=User
[ $? = 0 ] || die "Unable to create 'User' group"

echo "Groups created."

#########################################
# Role affectation
#########################################
$kcadm add-roles -r $realm \
  --gname Admin --rolename admin
[ $? = 0 ] || die "Unable to affect 'admin' role to the 'Admin' group"
echo "Groups configured."

#########################################
# Group affectations
#########################################
$kcadm update users/$admin_uid/groups/$admin_gid \
  -r $realm \
  -s realm=$realm \
  -s userId=$admin_uid \
  -s groupId=$admin_gid \
  -n
[ $? = 0 ] || die "Unable to affect 'admin' user to the 'Admin' group"
echo "Admin user affected to the 'Admin' group."

#########################################
# Getting realm keys
#########################################
echo "Get realm keys..."
$kcadm get keys -r $realm > $output/keys.json
[ $? = 0 ] || die "Unable to get realm keys"
jq ".keys[0].publicKey" -r $output/keys.json > $output/pub.tmp
sed -e "1 i -----BEGIN PUBLIC KEY-----" -e "$ a -----END PUBLIC KEY-----" $output/pub.tmp > $output/pub.pem
rm $output/pub.tmp
jq ".keys[0].certificate" -r $output/keys.json > $output/cert.tmp
sed -e "1 i -----BEGIN CERTIFICATE-----" -e "$ a -----END CERTIFICATE-----" $output/cert.tmp > $output/cert.pem
rm $output/cert.tmp
rm $output/keys.json

#########################################
# Getting adapter configuration file
#########################################
echo "Get adapter configuration file..."
$kcadm get clients/$client_id/installation/providers/keycloak-oidc-keycloak-json \
  -r $realm \
  | jq ".[\"auth-server-url\"]=\"$PUBLIC_BASEURL/auth\"" \
  > $output/keycloak.json
[ $? = 0 ] || die "Unable to get configuration file"
mv $output/keycloak.json $www/keycloak.json

echo "Keycloak successfully configured."
