#!/bin/bash

########################################################################
#
#   A script for automatic installation of interactive virtual printers for CUPS
#
#   File:  install.sh
#   ver 0.1.3 13/01/2011
#
#   Usage: sh ./install.sh <list of devices>
#   the list of devices can include djvu, pdf, ps - then the corresponding virtual printers are installed
#   if it is not djvu, pdf, ps, then the parameter is treated as a printer name and the script adds gtklp interface
#   with this printer being the default destination for gtklp
#
#   Example (installing djvu and pdf virtual printers and gtklp as CUPS backends; gtklp default destination is Xerox_3250 - 
#   assuming that this printer has been installed in CUPS, see lpstat -a): 
#   #sh ./install.sh djvu pdf Xerox_3250
#
#   Copyright:  (c) 2009 Oleg V. Motygin o dot v dot motygin at gmail dot com
#   License:  GPL
#
########################################################################

DEVICES=("$*")

if [[ "$PATH" =~ "/usr/local/bin" ]]; then
  RUNPATH="/usr/local/bin"
else
  RUNPATH="/usr/bin"
fi

#maybe it would be better to build virtprintd according to the list of devices
cp virtprintd "$RUNPATH"
chmod +x "$RUNPATH/virtprintd"

cp ps-vprinter /usr/lib/cups/backend
#chmod 700 /usr/lib/cups/backend/ps-vprinter

BACKENDRIGHTS=`stat --format=%a /usr/lib/cups/backend/lpd`
if [ $BACKENDRIGHTS = "" ]; then
  chmod 700 /usr/lib/cups/backend/ps-vprinter
else
  chmod $BACKENDRIGHTS /usr/lib/cups/backend/ps-vprinter
fi

ppddir="/usr/share/ppd"

if [ ! -d "$ppddir" ]; then
  ppddir="/usr/local/share/i-v-p-cups"
  mkdir "$ppddir" >& /dev/null
fi

cp CUPS-PDF.ppd "$ppddir"
PPD="$ppddir"/CUPS-PDF.ppd

# Adobe ppd instead of CUPS-PDF
# wget http://download.adobe.com/pub/adobe/printerdrivers/win/all/ppdfiles/adobe.zip
# unzip -d adobe.zip
# cp Adobe/ADIST5.PPD /usr/share/ppd/Acrobat-Distiller.ppd
# PPD=/usr/share/ppd/Acrobat-Distiller.ppd
# rmdir Adobe
# rm -f adobe.zip

for i in ${DEVICES[@]}; do 

 case $i in
# set djvu virtual printer in CUPS
 "djvu")
   cp printkit_djvu "$RUNPATH"
   chmod +x "$RUNPATH/printkit_djvu"
   lpadmin -p Save_as_DJVU -v ps-vprinter:/djvu -E -P "$PPD" -D "Print to a DJVU file" \
   -L "Interactive DJVU Backend"
 ;;
# set pdf virtual printer in CUPS
 "pdf")
   cp printkit_pdf "$RUNPATH"
   chmod +x "$RUNPATH/printkit_pdf"
   lpadmin -p Save_as_PDF -v ps-vprinter:/pdf -E -P "$PPD" -D "Print to a PDF file" \
   -L "Interactive PDF Backend"
 ;;
# set ps virtual printer in CUPS
 "ps")
   cp printkit_ps "$RUNPATH"
   chmod +x "$RUNPATH/printkit_ps"
   lpadmin -p Save_as_PS -v ps-vprinter:/ps -E -P "$PPD" -D "Print to a PS file" \
   -L "Interactive PS Backend"
 ;;
# set gtklp in CUPS with $i as the default printer
 *)
   lpadmin -p "$i"_via_gtklp -v "ps-vprinter:/printer->$i" \
   -E -P "$PPD" -D "Print to $i via gtklp" -L "Print to printer $i via gtklp"
 ;;
 esac
done
