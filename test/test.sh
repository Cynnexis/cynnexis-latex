#!/bin/bash

function clear_test() {
	rm -f *.pdf *.aux *.auxlock *.bbl *.blg *.fdb_latexmk *.fls *.lof *.lol *.lot *.out *.synctex *.synctex.gz *.pdfsync *.toc *.4ct *.4tc *.dvi *.idv *.lg *.tmp *.xref *.log
	rm -rf _minted-*/
}

if [[ ! -f "document.tex" ]]; then
	>&2 echo "Error: The LaTeX file doesn't exist."
	exit 1
fi

if [[ -f "document.pdf" ]]; then
	>&2 echo "Warning: The final document exists. It will be removed..."
	clear_test
	if [[ -f "document.pdf" ]]; then
		>&2 echo "Error: The final document still exists. It cannot be removed."
		exit 2
	fi
fi

echo "Compiling the LaTeX file using the Docker image \"$DOCKER_IMAGE\"..."
DOCKER_IMAGE="cynnexis/latex"
docker run --rm --name compile-latex-document -v "$(pwd):/root/latex" $DOCKER_IMAGE pdflatex -shell-escape -halt-on-error -file-line-error -output-directory "/root/latex/" "/root/latex/document.tex"
echo "Compilation done."

if [[ ! -f "document.pdf" ]]; then
	>&2 echo "Error: No PDF file were produced."
	if [[ -f "document.log" ]]; then
		>&2 echo "Last 25 lines of the log file:"
		>&2 tail -n 25 document.log
	fi
	clear_test
	exit 3
fi

file_size=$(stat --format=%s document.pdf)
re_number="^[0-9]+$"
if [[ ( ! $file_size =~ $re_number ) || $file_size -eq 0 ]]; then
	>&2 echo "Error: The document is not valid. Its size is $file_size B."
fi

clear_test
echo "Tests passed."
