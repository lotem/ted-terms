@if exist output.txt del output.txt
node main.js %* < sample.xml > output.txt
@if exist output.txt notepad output.txt
