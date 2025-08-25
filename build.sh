#!/usr/bin/env bash

set -e

print_help() {
	echo ""
	echo "usage: $0 <worker-config> [command]"
	echo ""
	echo "  The script automatically builds, packages, and deploys the given EdgeWorker."
	echo ""
	echo "  <worker-config> is a path to an extended bundle.json file with two additional fields:"
	echo "    - edgeworker-id: Akamai EdgeWorker ID (number)"
	echo "    - main: the entrypoint (e.g.: ./src/worker.ts), path is relative to the config file location"
	echo ""
	echo "  The [command] is an optional argument (defaults to build) that allows choosing what action to perform:"
	echo ""
	echo "  - build (default if not specified)"
    echo "       increment the version number,"
    echo "       build (bundle) the worker's code (uses the main field that specifies the entrypoint),"
    echo "      and output the final bundle to dist/<edgeworker-id>/bundle.tgz"
    echo ""
    echo "  - status"
    echo "      show the current deployment status (and history) across all Akamai networks"
    echo ""
    echo "  - open"
    echo "      open the Akamai Control Panel in browser and navigate to the worker's details page"
    echo ""
    echo "  - sandbox"
    echo "      build the bundle (same as build) and update the worker"
    echo "      in the default Akamai sandbox using the that bundle"
    echo ""
    echo "  - staging"
    echo "      build the bundle (same as build) and deploy the worker"
    echo "      to the Akamai staging network in one single step"
    echo ""
    echo "  - production"
    echo "      build the bundle (same as build) and deploy the worker"
    echo "      to the Akamai production network in one single step"
    echo ""
}

ew_config_file=$1
target=$2

if [[ -z $ew_config_file ]]; then
	echo "missing the required argument <worker-config>" 1>&2
	print_help
	exit 1
fi

# read the two extra fields from the config
ew_id=$(jq --raw-output '.["edgeworker-id"]' "$ew_config_file")
echo "edgeworker-id = $ew_id"
main=$(jq --raw-output '.["main"]' "$ew_config_file")
echo "main = $main"

if [[ $target == "status" ]]; then
	akamai edgeworkers status "$ew_id"
	exit 0
fi

if [[ $target == "open" ]]; then
	open "https://control.akamai.com/apps/edgeworkers/#/ids/${ew_id}/versions"
	exit 0
fi

# increment the patch number (by 1) in the edgeworker-version field
# e.g.: 1.5.1 > 1.5.2
mkdir -p "dist/akamai/$ew_id"
echo "updating $ew_config_file ..."
jq --tab '.["edgeworker-version"] |= (split(".") | .[2] = (.[2] | tonumber | . + 1 | tostring) | join("."))' \
	"$ew_config_file" >"dist/akamai/$ew_id/config.tmp.json"
cp "dist/akamai/$ew_id/config.tmp.json" "$ew_config_file"

# read the updated version
version=$(jq --raw-output '.["edgeworker-version"]' "$ew_config_file")
echo "bundle version = $version"

# remove the two extra fields from the config to create a valid bundle.json file
jq 'del(.main, .["edgeworker-id"])' "dist/akamai/$ew_id/config.tmp.json" >"dist/akamai/$ew_id/bundle.json"
rm "dist/akamai/$ew_id/config.tmp.json"

# esbuild
# docs: https://esbuild.github.io/
echo "running esbuild ..."
./node_modules/.bin/esbuild "$(dirname "$ew_config_file")/$main" \
	--bundle \
	--minify \
	--define:VERSION=\""$version"\" \
	--sourcemap \
	--platform=neutral \
	--packages=external \
	--outfile="dist/akamai/$ew_id/main.js"

# create the tar gz bundle
echo "creating bundle.tgz ..."
cd "dist/akamai/$ew_id" || exit 1
rm -f "bundle.tgz"
tar -czvf bundle.tgz main.js bundle.json

# if the target is specified, update in sandbox or deploy
if [[ -n $target ]]; then
	if [[ $target == 'sandbox' ]]; then
		echo "updating worker $ew_id in the default Akamai sandbox ..."
		akamai sandbox update-edgeworker "$ew_id" bundle.tgz
	elif [[ $target == 'staging' || $target == 'production' ]]; then
		echo "deploying worker $ew_id bundle version $version to Akamai $target network ..."
		akamai edgeworkers create-version "$ew_id" --bundle bundle.tgz
		akamai edgeworkers activate "$ew_id" "$target" "$version"
		akamai edgeworkers status "$ew_id" --versionId "$version"
	else
		echo "no deployment target specified for worker $ew_id"
		echo "possible targets: sandbox, staging, production"
	fi
fi
