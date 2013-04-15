#!/bin/bash

# specify the Xcode installation directory
xcode_path=/Applications/Xcode.app/Contents/Developer

# specify the docset bundle
doc_bundle="../../spring-framework.docset"

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
    sed -e '/<HEAD>/,/<\/HEAD>/d' -e 's/&/&amp;/g' ${indexPath} > clean.html

    # generate (from the clean HTML) and install a Tokens.xml file into the docset
    echo "generating Tokens-$theIndex.xml"
    xsltproc --html -o ${doc_bundle}/Contents/Resources/Tokens-${theIndex}.xml springdocsetm.xsl clean.html
    rm clean.html
done

# index the docset
echo "Indexing the docset ..."
${xcode_path}/usr/bin/docsetutil index -skip-text ${doc_bundle}

echo "END"