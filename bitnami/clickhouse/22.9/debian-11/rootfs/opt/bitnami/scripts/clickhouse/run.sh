#!/bin/bash

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libos.sh
. /opt/bitnami/scripts/libvalidations.sh
. /opt/bitnami/scripts/libclickhouse.sh

# Load ClickHouse environment variables
. /opt/bitnami/scripts/clickhouse-env.sh
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && ZONE=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone` && if [[ "$ZONE"  = "eu-central-1a" ]] ; then export KAFKA_BROKER_LIST=kafka-cp-kafka-2.kafka-cp-kafka-headless.confluent; elif [[ "$ZONE"  = "eu-central-1b" ]]; then export KAFKA_BROKER_LIST=kafka-cp-kafka-1.kafka-cp-kafka-headless.confluent; else export KAFKA_BROKER_LIST=kafka-cp-kafka-0.kafka-cp-kafka-headless.confluent;fi

declare -a cmd=("${CLICKHOUSE_BASE_DIR}/bin/clickhouse-server")
declare -a args=("--config-file=${CLICKHOUSE_CONF_FILE}" "--pid-file=${CLICKHOUSE_PID_FILE}")
args+=("$@")

info "** Starting ClickHouse **"
if am_i_root; then
    exec gosu "$CLICKHOUSE_DAEMON_USER" "${cmd[@]}" "${args[@]}"
else
    exec "${cmd[@]}" "${args[@]}"
fi
