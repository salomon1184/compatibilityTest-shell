function getSerialNumber(){
serialNumber=$(echo ${1%$'\t'*})
}


if [ ! -d "./crash" ]; then
mkdir "./crash"
fi

failuerCount=0;

time=`date '+%Y-%m-%d-%H-%M-%S'`

adb start-server

# Console output of "adb devices"
currentDevicesInfoRaw=$(adb devices)

# Delete useless text
currentDevicesInfo=${currentDevicesInfoRaw#*List of devices attached}
echo "$currentDevicesInfo"

numberOfLines=$(echo "$currentDevicesInfo" | wc -l)

for((i=0;i<100;i++));
do
echo "This is test $i"
for((j=2;j<=$numberOfLines;j++))
do
deviceInfo=$(echo "$currentDevicesInfo" | awk NR==$j)
getSerialNumber "$deviceInfo"


if [ ! -d "./$serialNumber" ]; then
mkdir "./$serialNumber"
fi



adb -s $serialNumber logcat -c
echo "Uninstall....."
adb -s $serialNumber uninstall com.autonavi.minimap
echo
sleep 3

echo "Install......."
adb -s $serialNumber install $1 | grep "Success"
if [ $? != 0 ]
then
let failuerCount+=1;
echo $serialNumber" Round "$failuerCount" FAIL" >> "fail_$time.txt"
echo "INSTALL FAIL";
continue;
fi
sleep 3

echo "Open autonavi......."
adb -s $serialNumber shell am start -n com.autonavi.minimap/.MapActivity
sleep 3
echo "kill autonavi......."
adb -s $serialNumber shell am force-stop com.autonavi.minimap
sleep 3
echo "Reopen autonavi......."
adb -s $serialNumber shell am start -n com.autonavi.minimap/.MapActivity

adb -s $serialNumber shell monkey -p com.autonavi.minimap  --bugreport  --ignore-timeouts  --ignore-security-exceptions  --monitor-native-crashes  --kill-process-after-error -s $i  --pct-syskeys 1 --pct-motion 2 --pct-touch 80 --throttle 200  -v -v 100 | tee "./$serialNumber/compatibility-$i.txt"


echo "Reinstall......."
adb -s $serialNumber install -r $1 | grep "Success"
if [ $? != 0 ]
then
let failuerCount+=1;
echo $serialNumber" Round "$failuerCount" FAIL" >> "fail_$time.txt"
echo "INSTALL FAIL";
continue;
fi
sleep 3

echo "Reopen autonavi again......."
adb -s $serialNumber shell am start -n com.autonavi.minimap/.MapActivity
sleep 3

adb -s $serialNumber logcat -d > "./$serialNumber/logcat-compatibility-$i.txt"

grep  -E "CRASH:|not responding|new native crash detected|native_crash|unexpected power cycle" "./$serialNumber/compatibility-$i.txt"
if [ $? == 0 ]
then
let failuerCount+=1;
echo "Crash Found in log ./$serialNumber/logcat-compatibility-$i.txt" >> "fail_$time.txt"
echo "Crash Found";
cp  ./$serialNumber/logcat-compatibility-$i.txt ./crash
cp  ./$serialNumber/logcat-compatibility-$i.txt ./crash
continue;
fi

done
done

echo "total failuer: "$failuerCount
