
<#noparse>

if [ -d ${MC_tmpFolder:-} ]; then
	echo -n "INFO: Removing MC_tmpFolder ${MC_tmpFolder} ..."
	rm -rf ${MC_tmpFolder}
	echo 'done.'
fi

tS=${SECONDS:-0}
tM=$((SECONDS / 60 ))
tH=$((SECONDS / 3600))
echo "On $(date +"%Y-%m-%d %T") ${MC_jobScript} finished successfully after ${tM} minutes." >> molgenis.bookkeeping.log
printf '%s:\t%d seconds\t%d minutes\t%d hours\n' "${MC_jobScript}" "${tS}" "${tM}" "${tH}" >> molgenis.bookkeeping.walltime

#
# Request OS to flush IO buffers/caches to disk.
#
sync

mv "${MC_jobScript}.started" "${MC_jobScript}.finished"

mydate_stop=$(date +"%Y-%m-%dT%H:%M:%S+0200")

</#noparse>
step=$(echo "${taskId}" | awk -F'_' '{print $1"_"$2}')

<#noparse>

CURLRESPONSE=$(curl -H "Content-Type: application/json" -X POST -d "{"username"="${USERNAME}", "password"="${PASSWORD}"}" https://${MOLGENISSERVER}/api/v1/login)
TOKEN=${CURLRESPONSE:10:32}

curl -H "Content-Type:application/json" -H "x-molgenis-token:${TOKEN}"</#noparse> -X PUT -d '{"job":"${taskId}","project_job":"${project}_${taskId}",<#noparse>"step":"'"${step}"'"</#noparse>,"project":"${project}",<#noparse>"started_date":"'"${mydate_start}"'","finished_date":"'"${mydate_stop}"'","status":"Finished"}' https://${MOLGENISSERVER}/api/v1/status_jobs/</#noparse>${project}_${taskId}
trap - EXIT
exit 0

