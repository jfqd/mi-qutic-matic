# mi-qutic-matic

use [jfqd/mi-qutic.base](https://github.com/jfqd/mi-qutic-base) to create a provisionable image

## description

image with mautic, nginx and php80.

## build the image

```
cd /opt/mibe/
git clone https://github.com/jfqd/mi-qutic-matic.git
BASE64_IMAGE_UUID=$(imgadm list | grep qutic-base-64 | tail -1 | awk '{ print $1 }')
TEMPLATE_ZONE_UUID=$(vmadm lookup alias='qutic-base-template-zone')
../bin/build_smartos $BASE64_IMAGE_UUID $TEMPLATE_ZONE_UUID mi-qutic-matic
```
