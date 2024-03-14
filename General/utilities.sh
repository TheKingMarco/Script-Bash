# enable strict mode: 
# Exits immediately if any command returns a non-zero exit status.
# Considers the entire pipeline as failed if any command within it fails.
set -euo pipefail

# Ottieni il percorso assoluto della directory dello script
SCRIPT_DIR=$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)

#timestamp "14/03/2024 19:45"
DATE=$(date +'%d/%m/%Y %H:%M')

# Check if the number of parameters passed is correct
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <parameter>"
    exit 1
fi