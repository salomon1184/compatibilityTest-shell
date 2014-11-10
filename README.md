compatibilityTest-shell
=======================

 执行逻辑：    
      1. 卸载app
      2.安装app(失败会写入fail.txt)
      3.打开
      4.关闭
      5.再打开
      6.跑几轮monkey
      7.覆盖安装app(失败写入fail.txt)
      8.重新打开
      9.扫描logcat，如果有fatal，写fail.txt


      支持多机，使用如下，目前只支持mac和linux系统(linux需要禁用dash sudo dpkg-reconfigure dash 选择no)
      sh compatibility.sh deviceserail apkpath
      eg:
      sh compatibility.sh 32304a51831210cd test.apk 

   第二版，支持多机，自动扫描手机
     sh compatibility2.sh  apkpath
     sh compatibility2.sh test.apk 
