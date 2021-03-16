#!/bin/bash
set -x #echo on

#REMOTE_SETUP="exprom-dell2"
REMOTE_SETUP="sw-mtx-034-065"

ip xfrm s f
ip xfrm p f

ssh root@$REMOTE_SETUP /bin/bash << EOF
	ip xfrm s f
	ip xfrm p f
EOF

