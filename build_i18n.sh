#!/usr/bin/env bash

QMLJS_FILES=$(find qml/ -name "*.qml" -o -name "*.js" | grep -v ./tests)

mkdir -p po

echo "Updating po/ubuntutu.pot"

rm po/*.pot
# pot file for qmls
xgettext -o po/qml.pot --qt --c++ --add-comments=TRANSLATORS --keyword=tr --keyword=tr:1,2 $QMLJS_FILES --from-code=UTF-8

# pot file for shell scripts
bash_files=`ls ./utils/*.sh`
for script in $bash_files
do
    bash --dump-po-strings $script >> po/bash.pot
done

# pot file for python scripts
cd po && intltool-update --pot && cd ..
msgcat po/qml.pot po/bash.pot po/untitled.pot > ubuntutu.pot
rm po/*.pot
mv ubuntutu.pot po/

TARGET_LANGS="zh_CN pl_PL"

for lang in $TARGET_LANGS
do
    mkdir -p share/locale/$lang/LC_MESSAGES
    if [ -f po/$lang.po ]; then
        echo "Update po file for $lang"
        msgmerge po/$lang.po po/ubuntutu.pot > po/tmp.po
        mv po/tmp.po po/$lang.po
        echo Building translations for $lang
        msgfmt -o share/locale/$lang/LC_MESSAGES/ubuntutu.mo po/$lang.po
    fi
done
