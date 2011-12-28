ext_name=$1
for i in `ls -1tr src/main/locale/`;
do
    install_rdf="${install_rdf}        <em:locale>locale/$i/$ext_name/</em:locale>\n"
    chrome="${chrome}locale	$ext_name	$i	jar:chrome/$ext_name.jar!/locale/$i/$ext_name/\n"
    install_js="$install_js\"$i\", "
    extension="$extension        <locale pos=\"\" code=\"$i\" />\n"
    mark_list="$mark_list[ ] $i\n"
done

rm -f /tmp/$1_locales.txt

echo -e "$install_rdf" >/tmp/$1_locales.txt
echo -e "$chrome" >>/tmp/$1_locales.txt
echo -e "$install_js" >>/tmp/$1_locales.txt
echo -e "$extension" >>/tmp/$1_locales.txt
echo -e "$mark_list" >>/tmp/$1_locales.txt

echo Locales written on /tmp/$1_locales.txt

#        <em:locale>locale/en-US/@EXT_NAME@/</em:locale>
#locale	richfeedbutton	en-US	jar:chrome/richfeedbutton.jar!/locale/en-US/richfeedbutton/
#var locales             = new Array("en-US", "it-IT", "fr-FR", "es-ES", 

