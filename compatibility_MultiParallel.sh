function getSerialNumber(){
serialNumber=$(echo ${1%$'\t'*})
}

adb start-server

# Console output of "adb devices"
currentDevicesInfoRaw=$(adb devices)

# Delete useless text
currentDevicesInfo=${currentDevicesInfoRaw#*List of devices attached}
echo "$currentDevicesInfo"

numberOfLines=$(echo "$currentDevicesInfo" | wc -l)

for((j=2;j<=$numberOfLines;j++))
do {

deviceInfo=$(echo "$currentDevicesInfo" | awk NR==$j)
getSerialNumber "$deviceInfo"
sh compatibility.sh $serialNumber

}&
done

wait
echo "Finished!"
