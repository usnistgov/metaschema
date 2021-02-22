#!/bin/bash

# Copy this file to config.sh in the same directory, and uncomment and customize the variables below to override default configuration options for all scripts.

# The PROVIDER_DIR variable identifies the metaschema framework implementation to use.
# A valid provider will have an "init.sh" file in the specified directory which implements the following set of bash functions:
#
# generate_xml_schema <metaschema_file> <generated_schema_file>
# generate_json_schema <metaschema_file> <generated_schema_file>

PROVIDER_DIR="${METASCHEMA_SCRIPT_DIR}/../toolchains/xslt-M4"

# The location to write generated files to

#WORKING_DIR="${PWD}"

# The location to cache long-lived files used by scripts

#CACHE_DIR="${WORKING_DIR}/.metaschema-cache"

# Controls if scripts should produce verbose output

#VERBOSE=false

