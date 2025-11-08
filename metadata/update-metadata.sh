#!/usr/pkg/bin/zsh

OUTPUT_DIR="../tex"
OUTPUT_FILE="${OUTPUT_DIR}/.env"
TEMP_FILE="${OUTPUT_FILE}.tmp$$"

if [ ! -f "metadata.yml" ]; then
	echo "metadata.yml file not found, can't continue!"
	exit 200
fi

if [ ! -d "${OUTPUT_DIR}" ]; then
	echo "output directory '${OUTPUT_DIR}' not found, can't continue!"
	exit 201
fi

TITLE="$(ggrep title metadata.yml | gsed 's/^title:\s+//')"
AUTHOR="$(ggrep author metadata.yml | gsed 's/^author:\s+//')"
LANGUAGE="$(ggrep lang metadata.yml | gsed 's/^lang:\s+//')"

echo "TITLE=${TITLE}" > "${TEMP_FILE}"
echo "AUTHOR=${AUTHOR}" >> "${TEMP_FILE}"
echo "LANGUAGE=${LANGUAGE}" >> "${TEMP_FILE}"

if [ -f "${OUTPUT_FILE}.bak" ]; then
	rm -f "${OUTPUT_FILE}.bak"
fi

if [ -f "${OUTPUT_FILE}" ]; then
	mv "${OUTPUT_FILE}" "${OUTPUT_FILE}.bak"
fi

mv "${TEMP_FILE}" "${OUTPUT_FILE}"
exit 0
