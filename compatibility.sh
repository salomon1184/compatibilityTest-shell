function getSerialNumber(){
serialNumber=$(echo ${1%$'\t'*})
}

failuerCount=0;

adb start-server



echo "This is test $i"
# Console output of "adb devices"
currentDevicesInfoRaw=$(adb devices)

# Delete useless text
currentDevicesInfo=${currentDevicesInfoRaw#*List of devices attached}
echo "$currentDevicesInfo"

numberOfLines=$(echo "$currentDevicesInfo" | wc -l)

for((i=0;i<100;i++));
do
   for((i=2;i<=$numberOfLines;i++))
    do
    deviceInfo=$(echo "$currentDevicesInfo" | awk NR==$i)
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
            echo $serialNumber" Round "$failuerCount" FAIL" >> "fail.txt"
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
        echo $serialNumber" Round "$failuerCount" FAIL" >> "fail.txt"
        echo "INSTALL FAIL";
        continue;
    fi
    sleep 3

    echo "Reopen autonavi again......."
    adb -s $serialNumber shell am start -n com.autonavi.minimap/.MapActivity
    sleep 3

    adb -s $serialNumber logcat -d > "./$serialNumber/logcat-compatibility-$i.txt"

    grep "FATAL" "./$serialNumber/logcat-compatibility-$i.txt"
    if [ $? == 0 ]
    then
    let failuerCount+=1;
    echo "Crash Found in log ./$$serialNumber/logcat-compatibility-$i.txt" >> "fail.txt"
    echo "Crash Found";
    continue;
    fi

    done    
done

echo "total failuer: "$failuerCount

