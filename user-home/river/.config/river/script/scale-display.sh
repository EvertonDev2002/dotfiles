#!/bin/bash
wlr-randr --json | jq -r '.[] | .name' | while read output_name; do
   wlr-randr --output "$output_name" --scale 1.5
done