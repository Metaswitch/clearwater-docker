# Liveness checker; tests whether this instance is live
set -e
PORTS=${1:-none}
ADDRESS=${MY_POD_IP:-127.0.0.1}
TIMEOUT=${2:-5}

if [ "$PORTS" = "none" ]
then
    echo "PORTS is not defined"
    exit 1
fi

echo "Reporting config"
echo "  ADDRESS=${ADDRESS}"
echo "  PORTS=${PORTS}"
echo "  TIMEOUT=${TIMEOUT}"

for PORT in $PORTS
do
    echo "Testing port ${PORT}"
    nc -n -z -w ${TIMEOUT} ${ADDRESS} ${PORT}
    echo "  port ${PORT} OK"
done

echo "Got to end - all must be OK"
exit 0
