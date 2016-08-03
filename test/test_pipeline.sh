set -e 
set -u

workfolder="/groups/umcg-gaf/tmp04/"

cd ${workfolder}/tmp/
if [ -d ${workfolder}/tmp/NGS_DNA ]
then
	rm -rf ${workfolder}/tmp/NGS_DNA/
fi

git clone https://github.com/molgenis/NGS_DNA.git
cd ${workfolder}/tmp/NGS_DNA

if [ ! -d ${workfolder}/rawdata/ngs/MY_TEST_BAM_PROJECT/ ] 
then
	cp -r test/rawdata/MY_TEST_BAM_PROJECT/ ${workfolder}/rawdata/ngs/
fi

if [ -d ${workfolder}/generatedscripts/PlatinumSubset ] 
then
	rm -rf ${workfolder}/generatedscripts/PlatinumSubset/
fi

if [ -d ${workfolder}/projects/PlatinumSubset ] 
then
	rm -rf ${workfolder}/projects/PlatinumSubset/
fi

mkdir ${workfolder}/generatedscripts/PlatinumSubset/

rm -f ${workfolder}/logs/PlatinumSubset.pipeline.finished
cp test/results/PlatinumSample.final.vcf /home/umcg-molgenis/PlatinumSample.final.vcf
cp test/autotest_generate_template.sh ${workfolder}/generatedscripts/PlatinumSubset/generate_template.sh
cp test/PlatinumSubset.csv ${workfolder}/generatedscripts/PlatinumSubset/

cd ${workfolder}/generatedscripts/PlatinumSubset/

sh generate_template.sh 

cd scripts

sh submit.sh

cd ${workfolder}/projects/PlatinumSubset/run01/jobs/
perl -pi -e 's|partition=ll|partition=devel|' *.sh
perl -pi -e 's|module load test|EBROOTNGS_DNA=/groups/umcg-gaf/tmp04/tmp/NGS_DNA/|' s24a_QCStats_0.sh  
perl -pi -e 's|module load test|#|' s24b_QCReport_0.sh
perl -pi -e 's|countShScripts-3\)\)|countShScripts-4))|' s25_CountAllFinishedFiles_0.sh

sh submit.sh

count=0
minutes=0
while [ ! -f /groups/umcg-gaf/tmp04/projects/PlatinumSubset/run01/jobs/s27_Autotest_0.sh.finished ]
do

        echo "not finished in $minutes minutes, going to sleep for 5 minutes"
    	sleep 300
        minutes=$((minutes+5))

        count=$((count+1))
        if [ $count -eq 50 ]
    	then
                echo "the test was not finished within 4 hours, let's kill it"
                exit 1
        fi
done