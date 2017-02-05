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
###*Sunday, 05. February 2017 02:59PM*
I am unsure that this output is correct, and I am still attempting to figure out what to do...
-sort -c is erroring out, and this reveals that sorted_transposed_genotypes and sorted_snp are not really sorted.
It appears like there are two less items when cut -f 1 [file name] is piped into word count.
<br>
###*Sunday, 05. February 2017 03:14PM*
Attempted gjoin, like always, it does not work.
I am defeated and am giving up for now.