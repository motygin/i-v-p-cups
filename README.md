CUPS backends are known to be a good way to add functionality to printer dialogues. An example is CUPS-PDF backend that allows a user to print to pdf file from any application. The problem is that CUPS does not allow its backends to be interactive. So it is difficult to ask user where to save the output pdf file.

This project is an attempt to solve the problem. The approach is as follows: new CUPS backend (ps-vprinter) prints to a ps file and place a semaphore file with the name of the ps file in a directory. A daemon which is run by a user regularly checks the semaphore file (located in tmpfs so it does not disturb hard disk) and invoke interactive virtual printers for further post-processing driven by user through dialogues.

Four virtual printers can be defined in cups: interactive printer spooler gtklp and pseudo-printers for printing to pdf, djvu, and ps files. For pdf and djvu pseudo-printers when choosing an existing file for saving, it is possible to add converted material to the file.

The project language is Bash shell scripts. Needed software: zenity; netpbm (>=10.21), psutils, and djvulibre for djvu pseudo-printer; pdftk for pdf pseudo-printer. 
