
#!/bin/bash
set -e 

rm -rf $1.zip $1/v-env
zip -r9 $1.zip empty.txt
