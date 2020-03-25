#!/bin/bash

doc=`echo ${TDR_TMP_DIR} | awk -F/ '{print $(NF-2)}'`

if [[ -f "${TDR_TMP_DIR}/${doc}_temp.pdf" ]]; then
	open ${TDR_TMP_DIR}/${doc}_temp.pdf
else
	echo "Can't find ${TDR_TMP_DIR}/${doc}_temp.pdf"
	echo "Perhaps you haven't compiled the document yet?"
fi