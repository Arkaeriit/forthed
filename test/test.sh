#!/bin/sh

ed < commands
mv output-file reference
seforth ../forthed.frt < commands
diff reference output-file || exit 1

