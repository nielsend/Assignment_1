# Assignment_1
##Unix Assignment for BCB 546X

###This markdown file serves to document progress on the first assignment.
<br>
###*Saturday, 04. February 2017 05:26PM*
Files were inspected were cloned and inspected using standard linux commands. 
<br>
###*Sunday, 05. February 2017 01:03PM* 

The following commands were used in processing the files:
 - awk -f transposase.awk fang_et_al_genotypes.txt > transposed_genotypes.txt
 - cut -f 1  transposed_genotypes.txt
 Note: No matter how long I wait, the awk command always times out..
 
 <br>
###*Sunday, 05. February 2017 02:49PM* 
- sort -k1,1 snp_position.txt > sorted_snp
- sort -k1,1 transposed_genotypes.txt > sorted_transposed_gegnotypes. txt
- join -1 1 -2 1 sorted_transposed_genotypes. txt sorted_snp > sorted
-cut -f 1 sorted | less

<br>
### *Sunday, 05. February 2017 02:59PM*
I am unsure that this output is correct, and I am still attempting to figure out what to do.
-sort -c is erroring out, and this reveals that sorted_transposed_genotypes and sorted_snp are not really sorted.
It appears like there are two less items when cut -f 1 [file name] is piped into word count.

<br>
### *Sunday, 05. February 2017 03:14PM*
Attempted gjoin, like always, it does not work.
I will attempt more work on this at a later time.
<br>
### *Monday, 06. February 2017 08:45AM* 
After giving the project some thought, I have decided to change directions in how I layout my work.

Since it appears that the sample IDs needed to be grabbed with the group files, grep should be used first.
- grep -E 'ZMMIL|ZMMLR|ZMMMR' fang_et_al_genotypes.txt > fang_maize.txt
- grep -E 'ZMPBA|ZMPIL|ZMPJA' fang_et_al_genotypes.txt > fang_teosinte.txt

However, the first line of files is now missing. Therefore,
we need to get the header. This can be done by:
head -n 1 fang_et_al_genotypes.txt > header.txt

The files now need to be concatenated, and it is bad to overwrite files. So, instead of overwriting, I'll just add my code from a temp file and move it.

cat header.txt fang_maize > temp.txt
mv temp.txt fang_maize.txt
cat header. txt fang_teosinte.txt > temp.txt
 mv temp.txt fang_teosinte.txt

<br>
###*Monday, 06. February 2017 10:30AM*
The unwanted groups should be gone, so it is now time to transpose.

 awk -f transpose.awk fang_maize.txt > transposed_fang_maize.txt
awk -f transpose.awk fang_teosinte.txt > transposed_fang_teosinte.txt

The transposed files must now be sorted: 
sort -k1,1 transposed_fang_maize.txt > sorted_transposed_fang_maize.txt
sort -k1,1 transposed_fang_teosinte.txt > sorted_transposed_fang_teosinte.txt


<br>
###*Monday, 06. February 2017 11:01AM* 
Since I now should have everythinig I want to join, it is time to join the files together.

join snp_position.txt sorted_transposed_fang_maize.txt > snp_maize.txt
join snp_position.txt sorted_transposed_fang_teosinte.txt > snp_teosinte.txt

New directories were created to deal with the new files being split out from the old files. These directories are maize and teosinte. Both contain forward (fwd) and reverse folders for sorting. We want to sort forward and reverse by column 4 so:
sort -n -k4 snp_maize.txt > ./maize/sorted_maize.txt
sort -n -k4 -r snp_maize.txt > ./maize/reverse_maize.txt
sort -n -k4 snp_teosinte.txt > ./teosinte/sorted_teosinte.txt
sort -n -k4 -r snp_teosinte.txt > ./teosinte/sorted_teosinte.txt

awk '{filename = "./fwd/maize" $3 ".txt"; print > filename}' sorted_maize.txt
<br>
###*Monday, 06. February 2017 12:04PM* 
The command appears to have worked liked it should have, but there are missing files. I only see chromosomes 1, 2, 3, 4, 9, and unknown for the forward data.
It occurs to me that I should re-sort the original files including snp, maize, and teosinate

###*Monday, 06. February 2017 01:12PM* 
I resorted and rejoined my files:

sort -k1,1 snp_position.txt > sorted_snp_position.txt

join sorted_snp_position.txt sorted_transposed_fang_maize.txt > snp_maize.txt
join sorted_snp_position.txt sorted_transposed_fang_teosinte.txt > snp_teosinte.txt
 
 Then, I completed all the steps presented at 11:01 AM on February 6th, 2017 (changing snp_position to sorted_snp_position).
 
 The command appears to have worked since there are 12 maize files including maize1-10 as well as maizemultiple.txt and maizeunknown.txt.
 
 Therefore, I used the same command on the other forward files. Teosinte forward files were completed next with:
 awk '{filename = "./fwd/teosinte" $3 ".txt"; print > filename}' sorted_teosinte.txt
 <br>
 
###*Monday, 06. February 2017 01:35PM* 
Following the success of the forward files, the reverse files were "broken out" by using:
awk '{gsub(/\?/,"-"); filename = "./reverse/maize" $3 ".txt"; print > filename}' reverse_maize.txt 	from the maize directory 

 awk '{gsub(/\?/,"-"); filename = "./reverse/teosinte" $3 ".txt"; print > filename}' reverse_teosinte.txt	from the teosinte directory.
 
 gsub was used because it substitutes characters, and the forward slashes were needed because the question mark is a special character.
 
 The maize and teosinte reverse directories contained the files 1-10 as well as the unknown and multiple files.
 <br>
 
 
### *Monday, 06. February 2017 01:57PM*
  **All 40 files for submission were moved into a directory at ~/Assignment_1/Submission in the appropriate maize or teosinte directory, and the Assignment_1 directory was uploaded to Github. The submission file did not include the unknown or multiple files.**
 
 
 
 
 
 
 
 
