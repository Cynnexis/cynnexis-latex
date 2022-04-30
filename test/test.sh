#!/bin/bash
set -euo pipefail

function clear_test() {
	rm -f *.pdf *.aux *.auxlock *.bbl *.blg *.fdb_latexmk *.fls *.lof *.lol *.lot *.out *.synctex *.synctex.gz *.pdfsync *.toc *.4ct *.4tc *.dvi *.idv *.lg *.tmp *.xref *.log
	rm -rf _minted-*/
}

# Trap exit signal to clear test
trap 'clear_test' EXIT

if [[ ! -f "document.tex" ]]; then
	echo "Error: The LaTeX file doesn't exist." 1>&2
	exit 1
fi

if [[ -f "document.pdf" ]]; then
	echo "Warning: The final document exists. It will be removed..." 1>&2
	clear_test
	if [[ -f "document.pdf" ]]; then
		echo "Error: The final document still exists. It cannot be removed." 1>&2
		exit 2
	fi
fi

DOCKER_IMAGE="cynnexis/latex"
echo "Compiling the LaTeX file using the Docker image \"$DOCKER_IMAGE\"..."
mkdir -p build

PS4='$ '
set -x
time docker run \
	-i \
	--rm \
	--name compile-latex-document \
	-v "$(pwd):/root/latex" \
	--entrypoint=bash \
	"$DOCKER_IMAGE:latest" \
		-c 'time pdflatex -shell-escape -halt-on-error -file-line-error -output-directory "/root/latex/" "/root/latex/document.tex"' \
	|& tee build/test.log

{ set +x; } 2> /dev/null

echo "Compilation done."

# Check the document exists
if [[ ! -f "document.pdf" ]]; then
	echo "Error: No PDF file were produced." 1>&2
	if [[ -f "document.log" ]]; then
		echo "Last 25 lines of the log file:" 1>&2
		tail -n 25 document.log 1>&2
	fi
	clear_test
	exit 3
fi

file_size=$(stat --format=%s document.pdf)
re_number="^[0-9]+$"
if [[ ( ! $file_size =~ $re_number ) || $file_size -eq 0 ]]; then
	echo "Error: The document is not valid. Its size is $file_size B." 1>&2
fi

# Clear tests
clear_test
# Reset exit Trap
trap - EXIT

echo "Tests passed."
