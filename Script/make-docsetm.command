#!/bin/bash

# specify the Xcode installation directory
xcode_path=/Applications/Xcode.app/Contents/Developer/

# specify the output archive file name
archive_name=../../spring-framework.docset.xar

# specify the docset bundle
doc_bundle=../

# construct the location to store the documents within the doc bundle
doc_path=${doc_bundle}/Contents/Resources/Documents

# change directory to the location of this script
base_dir=${0%/*}
echo "change directory to: $base_dir"
cd $base_dir

# cleanup index-all.html to remove offending text
index_root=${doc_path}/api/index-files
for indexFile in `ls $index_root` ; do
	file_tail=${indexFile##*-}
	theIndex=${file_tail%*.html}
	indexPath=${index_root}/${indexFile}
	
	# clean the index file by stripping the header and escaping ampersands
	echo "cleaning $indexPath ..."
	sed -e '/<HEAD>/,/<\/HEAD>/d' -e 's/&/&amp;/g' -e '/<SCRIPT/,/<\/SCRIPT>/d' -e '/<code>/,/<\/code>/d' -e '/<cod>/,/<\/code>/d' -e '/<CODE>/,/<\/CODE>/d' -e '/<emphasis>/,/<\/emphasis>/d' ${indexPath} > clean.html
	
	# generate (from the clean HTML) and install a Tokens.xml file into the docset
	echo "generating Tokens-$theIndex.xml"
	xsltproc --html -o ${doc_bundle}/Contents/Resources/Tokens-${theIndex}.xml springdocsetm.xsl clean.html
	rm clean.html
done

# index the docset
echo "Indexing the docset ..."
${xcode_path}/usr/bin/docsetutil index ${doc_bundle}

# archive the docset for publishing to feed
echo "archiving the docset ..."
${xcode_path}/usr/bin/docsetutil package -output ${archive_name} ${doc_bundle}
