#!/usr/bin/env sh
# don't crash out if there is an error
set +xe

set_password()
{
    # if bootrino user has not defined a password environment variable when launching then make a random one
    NEWPW=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c10`
    if ! [[ -z "${PASSWORD}" ]]; then
      NEWPW=${PASSWORD}
    fi
    echo "Password for tc user is ${NEWPW}"
    echo "tc:${NEWPW}" | chpasswd

}
set_password
