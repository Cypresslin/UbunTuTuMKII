#!/usr/bin/env bash

QMLJS_FILES=$(find qml/ -name "*.qml" -o -name "*.js" | grep -v ./tests)

mkdir -p po

echo "Updating po/ubuntutu.pot"
xgettext -o po/ubuntutu.pot --qt --c++ --add-comments=TRANSLATORS --keyword=tr --keyword=tr:1,2 $QMLJS_FILES --from-code=UTF-8
[ -f po/bash.pot ] && rm po/bash.pot
bash_files=`ls ./utils/*.sh`
for script in $bash_files
do
    bash --dump-po-strings $script >> po/bash.pot
done
msgcat po/ubuntutu.pot po/bash.pot > po/tmp.pot
mv po/tmp.pot po/ubuntutu.pot

TARGET_LANGS="zh_CN pl_PL"

for lang in $TARGET_LANGS
do
    mkdir -p share/locale/$lang/LC_MESSAGES
    if [ -f po/$lang.po ]; then
        echo Building translations for $lang
        msgfmt -o share/locale/$lang/LC_MESSAGES/ubuntutu.mo po/$lang.po
    fi
done
