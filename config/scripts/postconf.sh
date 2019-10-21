#!/bin/sh
# echo "Stopping Postfix service"
#
# supervisorctl stop postfix

echo "Reconfiguring Postfix runtime configs"

echo -e "**reset and readd the custom main configs"
cp /etc/postfix/main.cf.dist /etc/postfix/main.cf && \
cat /etc/rt4/scripts/postfix-main.cf >> /etc/postfix/main.cf

echo -e "**reset and readd the custom canonical config"
cat /etc/rt4/scripts/sender_canonical > /etc/postfix/sender_canonical

echo -e "**reset and readd the custom sasl_passwd config"
cat /etc/rt4/scripts/sasl_passwd > /etc/postfix/sasl_passwd

echo -e "**sasl_passwd hash"
postmap hash:/etc/postfix/sasl_passwd
echo -e "**generic hash"
postmap hash:/etc/postfix/generic
echo -e "**canonical sender hash"
postmap hash:/etc/postfix/sender_canonical
echo -e "**aliases setup"
postalias /etc/postfix/aliases

echo -e "**Reloading Postfix service"
supervisorctl restart postfix
