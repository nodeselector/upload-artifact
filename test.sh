# I removed all the code that obtains the url from gha and replaced it with a hardcode signed url.
# BLOB_SIGNATURE is passed in as an environment variable.

if [[ -z $BLOB_SIGNATURE ]]; then
    echo "no blob signature provided"
    exit 1
fi

if [[ -z $BLOB_NAME ]]; then
    echo "no blob name provided"
    exit 1
fi

if ! [[ -f '/tmp/data' ]]; then
    echo populating test data
        dd if=/dev/urandom of=/tmp/data1 bs=10M count=10
        dd if=/dev/urandom of=/tmp/data2 bs=10M count=10
        dd if=/dev/urandom of=/tmp/data3 bs=1G count=1
fi

export INPUT_PATH='/tmp/data*'
export INPUT_NAME="$BLOB_NAME"
export INPUT_OVERWRITE='false'
export INPUT_INCLUDE_HIDDEN_FILES='false'
export INPUT_UPLOAD_BLOB_URL="https://nodeselectortestdata.blob.core.windows.net/artifacts/${BLOB_NAME}${BLOB_SIGNATURE}"
echo $INPUT_UPLOAD_BLOB_URL

# running node with --prof was not very insightful. most of the time was "unaccounted"
# this will use Instruments.app to perform a CPU Profile.
# see https://www.jviotti.com/2024/01/29/using-xcode-instruments-for-cpp-cpu-profiling.html
# if we were investigating this on linux, we could reach for something less Apple-y, like perf

case $action in
  instruments)
    echo "Tracing with instruments profile."
    ./profile.sh \
        $(which node) ./dist/upload/index.js
    ;;
  nodeprof)
    echo "Node --prof mode"
    $(which node) --prof ./dist/upload/index.js
    ;;
  *)
    echo "running directly"
    $(which node) ./dist/upload/index.js
    ;;
esac