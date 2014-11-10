failuerCount=0;
time=`date '+%Y-%m-%d-%H-%M-%S'`
for((i=0;i<100;i++));
do

if [ ! -d "./$1" ]; then
    mkdir "./$1"
fi

if [ ! -d "./crash" ]; then
mkdir "./crash"
fi

echo "This is test $i"

adb -s $1 logcat -c
echo "Uninstall....."
adb -s $1 uninstall com.autonavi.minimap
echo 
sleep 3

echo "Install......."
adb -s $1 install $2 | grep "Success"
if [ $? != 0 ]
	then
       let failuerCount+=1;
       echo "Round "$failuerCount" FAIL" >> "fail_$time.txt"
       echo "INSTALL FAIL";
       continue;
	fi
sleep 3

echo "Open autonavi......."
adb -s $1 shell am start -n com.autonavi.minimap/.MapActivity
sleep 3
echo "kill autonavi......."
adb -s $1 shell am force-stop com.autonavi.minimap
sleep 3
echo "Reopen autonavi......."
adb -s $1 shell am start -n com.autonavi.minimap/.MapActivity

adb -s $1 shell monkey -p com.autonavi.minimap  --bugreport  --ignore-timeouts  --ignore-security-exceptions  --monitor-native-crashes  --kill-process-after-error -s $i  --pct-syskeys 1 --pct-motion 2 --pct-touch 80 --throttle 200  -v -v 100 | tee "./$1/compatibility-$i.txt"


echo "Reinstall......."
adb -s $1 install -r $2 | grep "Success"
if [ $? != 0 ]
then
let failuerCount+=1;
echo "Round "$failuerCount" FAIL" >> "fail_$time.txt"
echo "INSTALL FAIL";
continue;
fi
sleep 3

echo "Reopen autonavi again......."
adb -s $1 shell am start -n com.autonavi.minimap/.MapActivity
sleep 3

adb -s $1 logcat -d > "./$1/logcat-compatibility-$i.txt"

grep  -E "CRASH:|not responding|new native crash detected|native_crash|unexpected power cycle" "./$1/compatibility-$i.txt"
if [ $? == 0 ]
then
let failuerCount+=1;
echo "Crash Found in log ./$1/logcat-compatibility-$i.txt" >> "fail_$time.txt"
echo "Crash Found";
cp  ./$1/logcat-compatibility-$i.txt ./crash
cp  ./$1/logcat-compatibility-$i.txt ./crash
continue;
fi

done

echo "total failuer: "$failuerCount
