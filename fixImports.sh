#!/bin/bash
imports=$(dub describe | jq ".packages[] | [(.path + .importPaths[])] | .[]" | sed 's/"//g')
for sock in $(ps x | grep dcd-server | egrep --only-matching "/tmp/workspace-d([^ ]+)"); do
	for import in $imports; do
		dcd-client --socketFile $sock -I $import
	done
done
