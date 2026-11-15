
## SourceTracker2

#qiime2
biom convert -i otu.txt -o table.from_txt_json.biom --table-type="OTU table" --to-json

#SourceTracker2.0
sourcetracker2 -i table.from_txt_json.biom -m metadata.txt -o output

